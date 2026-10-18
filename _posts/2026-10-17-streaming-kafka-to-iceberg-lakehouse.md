---
layout: post
title: "Streaming from Kafka into an Iceberg Lakehouse, End to End"
date: 2026-10-17
categories: [big-data, Apache-Iceberg, Apache-Kafka, Spark, Data-Engineering]
tags: [Apache Kafka, Apache Iceberg, Spark Structured Streaming, lakehouse, data engineering, streaming]
description: "Stream Apache Kafka into an Apache Iceberg lakehouse with Spark Structured Streaming: working code, exactly-once writes and table maintenance tips."
---

## From Kafka Topics to a Lakehouse Table, the Right Way

**Still landing Kafka data into HDFS or S3 as raw files and batching it later?**

Back in 2015, I wrote about [moving Twitter streams from Kafka to HDFS with Camus](https://saurzcode.in/2015/02/integrate-kafka-hdfs-using-camus-twitter-stream-example/). A decade later, the goal is the same - get streaming data durably into storage - but the destination has changed completely. Today, we write straight into an **Apache Iceberg table** and get ACID commits, schema evolution, and time travel for free.

In this post, we'll build the whole pipeline end to end:

- A Kafka topic producing JSON events
- A Spark Structured Streaming job that consumes the topic
- Streaming writes into an Iceberg table with exactly-once semantics
- Querying and maintaining the table (compaction, snapshots)

---
<!--more-->

## The Architecture

```
Producers --> Kafka topic --> Spark Structured Streaming --> Iceberg table (S3/HDFS)
                                                              |
                                                              +--> Query with Spark / Trino
```

Three moving parts:

1. **Kafka** - the durable, replayable event log
2. **Spark Structured Streaming** - micro-batch processing with checkpointing
3. **Iceberg** - the table format that turns object storage into a transactional lakehouse

The key idea: Spark's checkpointing and Iceberg's atomic commits together give you **exactly-once** delivery into the table.

---

## What We'll Use

| Component | Version |
|-----------|---------|
| Apache Kafka | 4.3.1 (KRaft mode, no ZooKeeper) |
| Apache Spark | 4.2.0 (Scala 2.13) |
| Apache Iceberg | 1.12.0 (`iceberg-spark-runtime-4.0_2.13`) |
| Language | Python (PySpark) |

> The Iceberg runtime jar must match your Spark major version. For Spark 4.x, that is `org.apache.iceberg:iceberg-spark-runtime-4.0_2.13:1.12.0`.

---

## Step 1: Start Kafka and Create the Topic

With Kafka 4.x, ZooKeeper is gone. A single-node KRaft broker is one Docker container:

```bash
docker run -d --name kafka -p 9092:9092 \
  apache/kafka:4.3.1
```

Create the topic and produce a few test events:

```bash
docker exec kafka /opt/kafka/bin/kafka-topics.sh \
  --create --topic order-events \
  --bootstrap-server localhost:9092 --partitions 3

docker exec -it kafka /opt/kafka/bin/kafka-console-producer.sh \
  --topic order-events --bootstrap-server localhost:9092
```

Each message is a JSON order event:

```json
{"order_id": "o-1001", "customer_id": "c-42", "amount": 249.50, "currency": "USD", "event_time": "2026-10-17T10:15:00Z"}
```

---

## Step 2: Create the Iceberg Table

We'll use a Hadoop catalog pointed at object storage for simplicity. In production you'd more likely use a REST catalog, Glue, or Nessie - the streaming code below is identical either way.

Start `pyspark` with the two packages we need:

```bash
pyspark --packages \
  org.apache.iceberg:iceberg-spark-runtime-4.0_2.13:1.12.0,\
org.apache.spark:spark-sql-kafka-0-10_2.13:4.2.0
```

Configure the catalog and create the table:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("kafka-to-iceberg") \
    .config("spark.sql.extensions",
            "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
    .config("spark.sql.catalog.lakehouse",
            "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.lakehouse.type", "hadoop") \
    .config("spark.sql.catalog.lakehouse.warehouse",
            "s3a://my-lakehouse/warehouse") \
    .getOrCreate()

spark.sql("""
CREATE TABLE IF NOT EXISTS lakehouse.order_events (
  order_id     STRING,
  customer_id  STRING,
  amount       DOUBLE,
  currency     STRING,
  event_time   TIMESTAMP
)
USING iceberg
PARTITIONED BY (days(event_time))
""").show()
```

Notice the partition spec: `days(event_time)` is **hidden partitioning**. Producers and consumers never write partition columns by hand - Iceberg derives them from the timestamp.

---

## Step 3: The Streaming Job

Now the core of the pipeline - read from Kafka, parse JSON, write to Iceberg:

```python
from pyspark.sql.functions import col, from_json
from pyspark.sql.types import StructType, StructField, StringType, DoubleType, TimestampType

schema = StructType([
    StructField("order_id", StringType()),
    StructField("customer_id", StringType()),
    StructField("amount", DoubleType()),
    StructField("currency", StringType()),
    StructField("event_time", TimestampType()),
])

# 1. Read the stream from Kafka
raw = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", "order-events") \
    .option("startingOffsets", "earliest") \
    .load()

# 2. Parse the JSON payload
events = raw.select(
    from_json(col("value").cast("string"), schema).alias("e")
).select("e.*")

# 3. Write micro-batches into the Iceberg table
query = events.writeStream \
    .format("iceberg") \
    .outputMode("append") \
    .trigger(processingTime="1 minute") \
    .option("checkpointLocation", "s3a://my-lakehouse/checkpoints/order_events") \
    .option("fanout-enabled", "true") \
    .toTable("lakehouse.order_events")

query.awaitTermination()
```

Three details worth pausing on:

- **`checkpointLocation` is not optional.** Spark stores Kafka offsets and query progress there. After a restart, the job resumes from the last committed offset - no duplicates, no gaps.
- **`fanout-enabled: true`** - Iceberg normally requires data sorted by partition within each task. For streaming, that repartition/sort adds latency to every micro-batch. The fanout writer keeps one file writer open per partition instead, which is the right trade for partitioned streaming sinks.
- **`outputMode("append")`** is what you want for event ingestion. Iceberg also supports `complete`, but append is the natural fit here.

Submit it the same way as the shell:

```bash
spark-submit --packages \
  org.apache.iceberg:iceberg-spark-runtime-4.0_2.13:1.12.0,\
org.apache.spark:spark-sql-kafka-0-10_2.13:4.2.0 \
  kafka_to_iceberg.py
```

---

## Step 4: Why This Is Exactly-Once

Each micro-batch goes through this sequence:

1. Spark reads a range of Kafka offsets for the batch.
2. The batch is written to Iceberg data files.
3. Iceberg commits the new snapshot **atomically** - readers either see the whole batch or none of it.
4. Only then does Spark record the offsets in the checkpoint.

If the job crashes mid-batch, the uncommitted Iceberg files are orphaned (and cleaned up by later maintenance), the offsets were never checkpointed, and the next run re-reads the same Kafka range. Every event lands in the table **exactly once**.

This is a huge upgrade over the old `Kafka -> HDFS files` pattern, where exactly-once required careful staging directories and atomic renames.

---

## Step 5: Query the Table

Data is queryable as soon as each snapshot commits - no waiting for a nightly batch:

```python
spark.sql("""
SELECT date(event_time) AS day, currency,
       COUNT(*) AS orders, SUM(amount) AS revenue
FROM lakehouse.order_events
GROUP BY 1, 2
ORDER BY 1 DESC
""").show()
```

And because it's Iceberg, time travel works out of the box:

```sql
SELECT * FROM lakehouse.order_events
VERSION AS OF 73481290481;
```

---

## Step 6: Don't Skip Table Maintenance

Streaming ingestion with one-minute micro-batches creates **lots of small files** - the classic streaming lakehouse problem. Schedule periodic maintenance:

```sql
-- Compact small files
CALL lakehouse.system.rewrite_data_files(table => 'order_events');

-- Expire old snapshots (keep 7 days)
CALL lakehouse.system.expire_snapshots(
  table => 'order_events',
  older_than => TIMESTAMP '2026-10-10 00:00:00'
);
```

A simple hourly Spark job (or your orchestrator's equivalent) keeps read performance healthy.

---

## Variations Worth Knowing

### Need upserts instead of append?
Use `foreachBatch` with Iceberg's `MERGE INTO` for CDC-style pipelines where Kafka carries updates and deletes, not just inserts.

### Not a Spark shop?
The same topology works with **Flink + Iceberg sink** (stronger for low-latency and upserts) or **Kafka Connect with the Iceberg sink connector** if you'd rather not run streaming jobs at all.

---

## ✅ Conclusion

The pipeline we built - Kafka topic, Spark Structured Streaming, Iceberg table - is the modern answer to a problem I was solving with Camus and HDFS in 2015. The difference is what the destination gives you now: atomic commits, exactly-once semantics, schema evolution, and time travel, all on cheap object storage.

> If your streaming data still lands as raw files and waits for a batch job to become queryable, a Kafka-to-Iceberg pipeline is the highest-leverage upgrade you can make to your platform.

---

## Related reading

- [Unlocking Data Lakes with Apache Iceberg: The Open Table Format Revolutionizing Analytics]({% post_url 2025-05-25-apache-iceberg %})
- [The Small-Files Problem: A Field Guide]({% post_url 2026-10-18-small-files-field-guide %})
- [MCP for Data Engineers: Connecting AI Agents to Your Iceberg Lakehouse]({% post_url 2026-10-18-mcp-for-data-engineers-iceberg-lakehouse %})
- [HDFS vs Object Storage: Deep Dive for Big Data Processing in the Cloud]({% post_url 2025-05-18-hdfs-vs-object-storage %})

## 💬 Let's Discuss

Are you running Kafka into Iceberg in production? Which catalog are you using - REST, Glue, Nessie? And how are you handling compaction for high-throughput topics? Share your setup or questions in the comments!
