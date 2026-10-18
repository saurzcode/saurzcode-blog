---
layout: post
title: "The Small-Files Problem: A Field Guide"
date: 2026-10-18
categories: [big-data, Apache-Iceberg, Spark, Data-Engineering]
tags: [Apache Iceberg, Apache Spark, small files, compaction, lakehouse, data engineering]
description: Diagnose, prevent, and fix the small-files problem in Spark + Apache Iceberg lakehouse tables - with real numbers, working SQL, and a maintenance checklist.
---

## The Maintenance Chapter Your Streaming Pipeline Was Missing

**Your streaming job writes 2 MB Parquet files every two minutes. Six months later, your dashboard queries are ten times slower — and nobody changed the data. Sound familiar?**

Yesterday, in [Streaming from Kafka into an Iceberg Lakehouse, End to End](https://saurzcode.in/big-data/apache-iceberg/apache-kafka/spark/data-engineering/streaming-kafka-to-iceberg-lakehouse/), we built the whole pipeline — Kafka topic, Spark Structured Streaming, Iceberg table — and Step 6 ended with a warning: one-minute micro-batches create **lots of small files — the classic streaming lakehouse problem**. This post picks up exactly there. The pipeline works; the file layout is what's rotting underneath it.

Same stack as yesterday: **Kafka 4.3.1, Spark 4.2.0 (Scala 2.13), Iceberg 1.12.0**, PySpark — and the same `lakehouse.order_events` table, partitioned by `days(event_time)`.

In this post, we'll:

- See why small files hurt — with real numbers, not vibes

- Diagnose the problem using Iceberg's own metadata tables

- Stop writing small files at write time

- Fix the damage with compaction (`rewrite_data_files`, done right)

- Keep the layout healthy with a checklist that fits on an index card

---

## Step 1: Understand Why Small Files Hurt

It's tempting to treat file count as cosmetic. It isn't. Every file in your table is a tax paid four times: at plan time, at task-scheduling time, at request time, and at footer-read time.

**Query planning.** Iceberg query planning reads manifest files to decide which data files to scan — [the manifest and snapshot layer I broke down in the Iceberg intro](https://saurzcode.in/big-data/apache-iceberg/data-engineering/apache-iceberg/) is exactly what gets stressed here. Dremio's engineers [measured this directly](https://www.dremio.com/blog/apache-iceberg-small-files-problem-causes-fixes-and-prevention/): the same dataset stored in 2,000 files of 256 MB each typically plans in under one second, while a table fragmented into 100,000 files pays a planning cost an order of magnitude higher. Manifests fragment too — every micro-batch commit adds manifests, and the metadata tree stops being an index and becomes a maze.

**Task scheduling.** Each file becomes at least one execution task. Scheduling costs roughly 1–10 milliseconds per task — trivial, until you multiply: a query against 100,000 files creates at least 100,000 tasks. Even if partition pruning eliminates 95% of them, the surviving 5,000 tasks carry 5–50 seconds of pure scheduling overhead *before any data moves*. On JVM engines like Spark, giant task graphs also pile on GC pressure, adding unpredictable latency.

**Object-store requests.** S3 charges $0.0004 per 1,000 GET requests. Reading a file takes at minimum one GET, but Parquet readers also fetch the footer and individual row groups — conservatively, two requests per file. So 100,000 files means 200,000 requests, or $0.08 per query, in storage API costs alone. A table queried 10,000 times a day burns $800 a day — $24,000 a month — on requests. Compact to 2,000 files and that drops to about $1,600 a month, a 93% reduction ([source](https://www.dremio.com/blog/apache-iceberg-small-files-problem-causes-fixes-and-prevention/)).

**Footer reads.** Every Parquet file carries a footer — schema, row-group metadata, column statistics. Reading it is mandatory and costs roughly the same whether the file is 1 MB or 512 MB: one to several milliseconds plus a network round trip. For a 256 MB file that's noise; for a 1 MB file it dominates. If 95% of your read time goes to footers instead of column data, you have a severe small-files problem ([source](https://www.dremio.com/blog/apache-iceberg-small-files-problem-causes-fixes-and-prevention/)).

**How fast it accumulates.** Streaming engines checkpoint every 1–10 minutes, and each checkpoint commits new Parquet files — one per partition. A table with 100 partitions on 10-minute checkpoints produces **14,400 new files per day**, most of them a few megabytes each ([source](https://lakeops.dev/blog/reduce-aws-s3-cost-iceberg)). A table with 500,000 small files queried 50 times a day generates roughly 25 million GET requests a month. The write path that felt so elegant on day one is a liability by month six.

---

## Step 2: Diagnose — Is This Actually Your Problem?

Don't compact on vibes. Iceberg gives you metadata tables that answer the question directly:

```sql
-- File health at a glance: count, average size, smallest/largest
SELECT
  COUNT(*)                                        AS file_count,
  ROUND(AVG(file_size_in_bytes) / 1048576, 2)     AS avg_mb,
  ROUND(MIN(file_size_in_bytes) / 1048576, 2)     AS min_mb,
  ROUND(MAX(file_size_in_bytes) / 1048576, 2)     AS max_mb,
  SUM(CASE WHEN file_size_in_bytes < 134217728
           THEN 1 ELSE 0 END)                     AS files_under_128mb
FROM lakehouse.order_events.files
WHERE content = 0;   -- 0 = DATA files; 1/2 = delete files
```

If a large share of files sits under 128 MB — or you see thousands of files averaging a few MB — you have the problem. Next, find *where* it hurts most, so your first compaction pass buys the biggest win:

```sql
-- Worst partitions first: file count and avg size per partition
SELECT
  partition,
  COUNT(*)                                     AS file_count,
  ROUND(AVG(file_size_in_bytes) / 1048576, 2)  AS avg_mb
FROM lakehouse.order_events.files
WHERE content = 0
GROUP BY partition
ORDER BY file_count DESC
LIMIT 30;
```

Two more signals worth checking:

```sql
-- Are snapshots piling up from streaming appends?
SELECT snapshot_id, committed_at, operation, summary
FROM lakehouse.order_events.snapshots
ORDER BY committed_at DESC
LIMIT 20;
```

A wall of `append` snapshots with no `replace` (compaction) in sight confirms the diagnosis. And don't forget the `manifests` metadata table — if manifest count is climbing with file count, planning overhead is compounding.

Outside SQL, the symptoms are just as telling: Spark UI jobs where a stage fans out into tens of thousands of tiny tasks, query plans that take longer than the scan itself, and — the one people notice last — your S3 `GetObject`/`ListObjects` request metrics climbing month over month while data volume stays flat.

---

## Step 3: Fix It at Write Time

Compaction is corrective. The cheaper move is to stop writing small files in the first place. Three things worth knowing about the write path:

**1. Target file size.** The table property `write.target-file-size-bytes` defaults to 512 MB. Spark writers roll a new file when buffered data crosses this threshold — but only if a single task actually accumulates that much. A streaming micro-batch with 50 MB of data never reaches it, which is exactly how you get 2 MB files:

```sql
-- Set once at the table level (256 MB is a common streaming-table choice)
ALTER TABLE lakehouse.order_events
  SET TBLPROPERTIES ('write.target-file-size-bytes' = '268435456');
```

You can also override it per write with the `target-file-size-bytes` DataFrame option.

**2. Distribution mode.** `write.distribution-mode` decides how rows are shuffled before writing: `none` (no shuffle — each task writes whatever it has; the small-files factory), `hash` (hash-distribute by partition key), or `range` (range-distribute by partition or sort key). For streaming writes into a partitioned table, `hash` is usually the right call:

```python
(df.writeStream
   .format("iceberg")
   .option("checkpointLocation", checkpoint_path)
   .option("distribution-mode", "hash")   # shuffle by partition key before writing
   .option("fanout-enabled", "true")      # keep partition writers open across batches
   .toTable("lakehouse.order_events"))
```

**3. The fanout writer.** Streaming data arrives out of order across partitions. Without fanout, every partition switch inside a task closes the current file and opens a new one — file rollover churn. `write.spark.fanout.enabled` (default `false`) keeps multiple partition writers open simultaneously, at the cost of more memory. For streaming jobs, enable it.

> We used `fanout-enabled: true` in [the streaming job from yesterday's post](https://saurzcode.in/big-data/apache-iceberg/apache-kafka/spark/data-engineering/streaming-kafka-to-iceberg-lakehouse/) for exactly this reason — without it, out-of-order events across days would have multiplied our file count from the very first batch.

Two more write-path habits that pay off:

- **`repartition` before batch writes.** Line writers up with the partition spec so each task writes fewer, larger files:

```python
from pyspark.sql.functions import to_date

def write_batch(batch_df, batch_id):
    (batch_df
       .repartition(to_date("event_time"))  # align writers with days(event_time)
       .writeTo("lakehouse.order_events")
       .option("fanout-enabled", "true")
       .append())

(query.writeStream
   .foreachBatch(write_batch)
   .option("checkpointLocation", checkpoint_path)
   .trigger(availableNow=True)
   .start())
```

- **Trigger intervals.** [The one-minute trigger we used yesterday](https://saurzcode.in/big-data/apache-iceberg/apache-kafka/spark/data-engineering/streaming-kafka-to-iceberg-lakehouse/) is great for freshness demos and terrible for file layout — on a low-volume topic it guarantees tiny files. Prefer `Trigger.AvailableNow` or multi-minute processing-time triggers, and coalesce inside the batch function as above.

None of this eliminates compaction entirely — streaming tables will always drift — but it slows the drift from days to weeks.

---

## Step 4: Compact What's Already There

Yesterday's post showed [the one-line version](https://saurzcode.in/big-data/apache-iceberg/apache-kafka/spark/data-engineering/streaming-kafka-to-iceberg-lakehouse/) — `CALL lakehouse.system.rewrite_data_files(table => 'order_events')`. Here's the full picture. Iceberg's compaction primitive rewrites selected data files into fewer, larger ones and commits the result as a new snapshot — fully online, no downtime; readers keep working against the old snapshot until the new one commits.

**Binpack (default): fast and dumb, in a good way.** It groups small files by partition and concatenates them up to the target size. No shuffle, no reordering — the cheapest possible rewrite:

```sql
-- Compact only the files that need it: small files in recent partitions
CALL lakehouse.system.rewrite_data_files(
  table    => 'order_events',
  strategy => 'binpack',
  where    => 'event_time >= current_timestamp() - INTERVAL 7 DAYS',
  options  => map(
    'target-file-size-bytes', '268435456',   -- 256 MB
    'min-input-files',        '5'             -- skip groups already healthy
  )
);
```

**Sort: slower, but fixes layout too.** Binpack doesn't touch data ordering. If your queries filter on `event_time` and `customer_id` but files were written in arrival order, column statistics are weak and pruning suffers. The `sort` strategy globally sorts before allocating files to tasks, tightening min/max ranges per file:

```sql
-- Merge + cluster by the columns your queries actually filter on
CALL lakehouse.system.rewrite_data_files(
  table      => 'order_events',
  strategy   => 'sort',
  sort_order => 'event_time ASC NULLS LAST, customer_id ASC NULLS LAST',
  options    => map(
    'target-file-size-bytes',             '268435456',
    'partial-progress.enabled',           'true',
    'max-concurrent-file-group-rewrites', '5'
  )
);

-- For multi-column filters with no single dominant column, Z-order instead:
-- sort_order => 'zorder(event_time, customer_id)'
```

(Iceberg 1.12 also adds Hilbert-curve clustering as a newer alternative to Z-ordering — worth evaluating once your engine supports it.)

**The options that matter in production:**

| Option | Default | What it does |
|---|---|---|
| `target-file-size-bytes` | table's `write.target-file-size-bytes` (512 MB) | Output file size target |
| `min-input-files` | 5 | File groups with fewer files are skipped |
| `min-file-size-bytes` | 75% of target | Files below this are always candidates |
| `max-file-size-bytes` | 180% of target | Files above this are always candidates |
| `max-concurrent-file-group-rewrites` | 5 | Parallelism of the rewrite; raise for large tables |
| `max-file-group-size-bytes` | 100 GB | Splits the job into file groups |
| `partial-progress.enabled` | false | Commit file groups as they finish instead of one big commit |
| `partial-progress.max-commits` | 10 | Cap on commits when partial progress is on |
| `rewrite-all` | false | Force-rewrite everything, ignoring the filters above |
| `rewrite-job-order` | none | Order groups: `bytes-asc`, `bytes-desc`, `files-asc`, `files-desc` |

Two of these deserve emphasis. `partial-progress.enabled=true` is the difference between losing hours of rewrite work on a mid-job failure and keeping what finished — always turn it on for large tables. And `max-concurrent-file-group-rewrites` is the knob real teams reach for at scale: [Ancestry's data team](https://aws.amazon.com/blogs/big-data/how-ancestry-optimizes-a-100-billion-row-iceberg-table/) raised it from the default 5 to **100** to compact a 100-billion-row Iceberg table, because the default couldn't keep up with their update frequency.

**The follow-ups people forget.** Compaction creates a new snapshot but leaves the old files on disk — old snapshots pin them. Run the cleanup chain, in this order:

```sql
-- 1. Expire old snapshots so their files can actually be deleted
--    (defaults: older_than = 5 days ago, retain_last = 1)
CALL lakehouse.system.expire_snapshots(
  table       => 'order_events',
  older_than  => TIMESTAMP '2026-10-01 00:00:00',
  retain_last => 10
);

-- 2. Consolidate manifest files (metadata-only, fast)
CALL lakehouse.system.rewrite_manifests(table => 'order_events');

-- 3. Sweep up orphan files from failed/partial writes (default window: 3 days)
--    Use dry_run first, and never set older_than shorter than your longest write.
CALL lakehouse.system.remove_orphan_files(
  table      => 'order_events',
  older_than => TIMESTAMP '2026-10-10 00:00:00',
  dry_run    => true
);
```

> Compacting without ever expiring snapshots means storage grows forever. And `remove_orphan_files` with too aggressive a window can delete files from in-flight writes — multi-day windows are normal; hours are not.

---

## Step 5: Keep It Healthy — the Index-Card Checklist

The industry rule of thumb is **128–512 MB per file** for analytical workloads, and Iceberg's own defaults agree: `write.target-file-size-bytes` is 512 MB, and the read path combines splits toward 128 MB (`read.split.target-size`).

Five lines, taped to your monitor:

1. **Measure first.** Query `tbl.files` monthly (weekly for streaming tables). Alert when average file size drops below ~128 MB or file count crosses your threshold.
2. **Fix the writer.** Set `write.target-file-size-bytes`, use `distribution-mode=hash` and `fanout-enabled=true` on streaming writes, and size your trigger intervals to the data volume.
3. **Compact on a cadence that matches ingestion.** Streaming tables often need compaction every few hours, not nightly; batch tables can go weekly.
4. **Always expire snapshots and rewrite manifests after compacting.** Compaction without cleanup is half a job.
5. **Sweep orphans quarterly** with a safe `older_than` window — on mature streaming lakes, orphans routinely account for a quarter or more of billable storage ([source](https://lakeops.dev/blog/reduce-aws-s3-cost-iceberg)).

---

## Variations Worth Knowing

### Delete-heavy tables (merge-on-read)?

Watch delete-file counts in `tbl.files` too — compact position deletes with `rewrite_position_delete_files`, not just data files.

### Sub-hour freshness needs?

Don't chase 512 MB if it means holding micro-batches open. 128–256 MB is fine for streaming tables where freshness matters more than scan efficiency.

### Heavy point lookups?

Smaller files with tight clustering (sort/Z-order) beat larger unsorted ones. File size is a means to an end — the end is pruning.

---

## ✅ Conclusion

Small files are not a moral failing — they're the natural output of a healthy streaming pipeline. The failure is letting the write path run unsupervised. Measure the file layout like you'd measure query latency, and the problem stays a maintenance task instead of becoming an incident.

> If your Kafka-to-Iceberg pipeline is past the demo stage, its next chapter isn't a new feature — it's maintenance. Measure `tbl.files`, fix the writer, compact on cadence.

---

## 💬 Let's Discuss

Are you compacting on a schedule, or only when queries get slow? Binpack or sort — which strategy do you reach for first? And what's the worst small-files incident you've seen in production? Share your setup or war stories in the comments!

## Related reading

- [Unlocking Data Lakes with Apache Iceberg: The Open Table Format Revolutionizing Analytics]({% post_url 2025-05-25-apache-iceberg %})
- [MCP for Data Engineers: Connecting AI Agents to Your Iceberg Lakehouse]({% post_url 2026-10-18-mcp-for-data-engineers-iceberg-lakehouse %})
- [HDFS vs Object Storage: Deep Dive for Big Data Processing in the Cloud]({% post_url 2025-05-18-hdfs-vs-object-storage %})

## Additional Details

- **Description:** A field guide to diagnosing, preventing, and fixing the small-files problem in Spark + Apache Iceberg lakehouse tables — with real numbers, working SQL, and a maintenance checklist.
