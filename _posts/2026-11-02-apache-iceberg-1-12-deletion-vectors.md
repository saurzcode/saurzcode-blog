---
layout: post
title: "Apache Iceberg 1.12: What's New, What's Breaking, and Why Deletion Vectors Matter"
date: 2026-11-02
categories: [big-data, Apache-Iceberg, Data-Engineering]
tags: [Apache Iceberg, Iceberg 1.12, deletion vectors, format v3, Spark, Flink, lakehouse, data engineering]
description: "Apache Iceberg 1.12.0 deep dive: deletion vectors, streaming delete conversion, Variant and geospatial types, REST catalog additions, breaking changes and upgrade notes - with a runnable demo."
---

## Deleting One Row Just Rewrote Your Whole Data File

**Here is a question I got after my [streaming post](https://saurzcode.in/big-data/apache-iceberg/apache-kafka/spark/data-engineering/streaming-kafka-to-iceberg-lakehouse/): "my upsert pipeline deletes a few hundred rows per micro-batch - why is my table rewriting gigabytes of Parquet?"**

Welcome to the cost of row-level deletes in Iceberg format v2 - and to why **Apache Iceberg 1.12.0**, announced on October 1, 2026 (777 commits, 142 contributors since 1.11.0), is really the "deletion vectors" release. Let me show you the problem with actual code, then walk through what 1.12 changes, what breaks, and when to upgrade.

<!--more-->

## The Problem: What a Delete Costs in Format V2

Format v2 gave us row-level deletes two ways, and both have a price:

- **Copy-on-write**: rewrite every data file that contains a deleted row. Fast reads, expensive writes.
- **Merge-on-read**: write a small *position delete* file ("row 5 of file X is gone") or *equality delete* file ("rows where id = 2 are gone") and let readers reconcile. Fast writes, but every query pays the reconciliation cost - forever, until compaction.

You don't have to take my word for it. Run this with PyIceberg (0.12.0, Python 3.10 - this is the exact script and output from my machine):

```python
import pyarrow as pa
from pyiceberg.catalog import load_catalog

catalog = load_catalog("sql", **{
    "uri": "sqlite:////tmp/dvcatalog.db",
    "warehouse": "file:///tmp/dvwarehouse",
})
catalog.create_namespace_if_not_exists("demo")

schema = pa.schema([
    pa.field("id", pa.int64(), nullable=False),
    pa.field("city", pa.string()),
    pa.field("amount", pa.float64()),
])
table = catalog.create_table(
    "demo.payments", schema=schema,
    properties={"write.delete.mode": "merge-on-read"},  # ask for merge-on-read
)

data = pa.Table.from_pylist(
    [{"id": 1, "city": "Pune", "amount": 10.5},
     {"id": 2, "city": "Mumbai", "amount": 20.0},
     {"id": 3, "city": "Delhi", "amount": 15.75}],
    schema=table.schema().as_arrow(),
)
table.append(data)
table.delete(delete_filter="id == 2")

import json
meta = json.loads(open(table.metadata_location.replace("file://", "")).read())
for s in meta["snapshots"]:
    print(s["snapshot-id"], s.get("summary", {}))
```

And the real output:

```text
UserWarning: Merge on read is not yet supported, falling back to copy-on-write

6879586166998605593 {'operation': 'append',  'added-data-files': '1', 'added-records': '3',
                     'total-delete-files': '0', 'total-records': '3', 'added-files-size': '1358'}
7616888934898427757 {'operation': 'overwrite', 'added-data-files': '1', 'deleted-data-files': '1',
                     'removed-files-size': '1358', 'added-files-size': '1333',
                     'total-records': '2', 'total-position-deletes': '0'}
```

Read that second snapshot carefully: deleting **one row** removed a 1358-byte data file and wrote a brand-new 1333-byte one. That is copy-on-write. (Notice the warning, too: even PyIceberg 0.12 asked for merge-on-read and silently fell back. Engine maturity around deletes is still uneven - more on that below.)

Scale this up: a streaming upsert job that touches a few hundred rows per batch forces either full file rewrites on every commit, or an ever-growing pile of delete files that every query must open and apply. My [small-files field guide](https://saurzcode.in/big-data/apache-iceberg/spark/data-engineering/small-files-field-guide/) covered the compaction side; 1.12 goes after the delete mechanics themselves.

## The Star of 1.12: Deletion Vectors Grow Up

Format v3 replaces position-delete files with **deletion vectors**: compact bitmaps (stored in Puffin files) that mark deleted row positions within a data file. Instead of "open the delete file, join it against the data file," a reader checks a bitmap. Cheap to write, nearly free to read.

What 1.12.0 actually ships here:

- **Co-located DV access**: `DataFile.deletionVector()` lets a reader fetch a file's deletion vector together with the file metadata, plus fixes for DVs that share a Puffin file and preserved encryption metadata on merge.
- **`ConvertEqualityDeletes` (Flink)**: a new maintenance task that takes the equality deletes your streaming upsert sink produces, resolves them once into deletion vectors, and commits them next to the data files. Queries stop paying the equality-compare cost on every scan. It pairs with `IcebergSink`, which stages new files and equality deletes on a branch while conversion happens. Requires **format version 3** and runs on Flink 1.20, 2.1, 2.2, and 2.3.
- **Breaking change to match**: writing position-delete files that carry row data is removed, consistent with the v3 move to deletion vectors.

If you run streaming upserts into Iceberg, `ConvertEqualityDeletes` is the feature to try first.

## Variant and Geospatial Types

Two newer data types got serious attention:

**Variant** (semi-structured data): reading unshredded Variant columns in Spark 4.0 and 4.1 now goes through the vectorized Parquet path instead of row-at-a-time decoding. Shredded writes are no longer Spark-only - Flink, the Kafka Connect sink, and the generic record writer can all produce shredded Variant now. One behavior change to know: shredding switched from a majority-based rule to **type uniformity** - a field becomes a typed shredded column only when all values share a type family, so every typed column fully covers its field. Mixed-type fields stay in the untyped residual.

**Geospatial**: Spark 4.1 gets the first end-to-end geospatial path - `geometry` and `geography` read and write through Parquet, and row-level DELETE/UPDATE/MERGE work on geospatial columns, including the merge-on-read deletion-vector path on v3 tables. Current limits: Spark 4.1 only (not Spark 3.5/4.0, Flink, or ORC), row-based reader (no Arrow vector yet), and no spatial predicates yet.

## REST Catalog Additions

Last week I wrote about the [Iceberg REST catalog](https://saurzcode.in/big-data/apache-iceberg/data-engineering/iceberg-rest-catalog-one-catalog-many-engines/) - one endpoint, every engine. 1.12 extends that protocol:

- `VariantType` is now representable in the OpenAPI spec, so Variant columns can travel in schemas over REST.
- New **unregister-table** endpoint: detach a table from a catalog without deleting its data or metadata - handy for catalog migrations.
- Read-only list/load **function endpoints**, formalized **remote signing** configuration, and a `labels` field for catalog metadata enrichment.
- Spec-level: **read restrictions** on `loadTable` - a catalog can return column-masking actions plus a row filter as an Iceberg expression, with a fail-closed contract (a reader that can't apply a restriction must fail the query, not return raw rows). One honest caveat from the release notes: no Iceberg reader implements this yet in 1.12.0, so a catalog returning `ReadRestrictions` is silently ignored today. Design for it, don't depend on it.
- The REST client now retries idempotent-key POSTs on retriable errors (408, 500, 502, 503, 504) - fewer flaky commit failures.

## Performance, Reliability, Security

- Manifest **list** files are now cached in the manifest content cache (faster planning), and Parquet gets adaptive bloom filter sizing and per-column dictionary encoding.
- Vectorized Parquet reader fixes, including `int`-to-`long` promotion `ClassCastException`, decimals, and a direct-memory leak in the row-lineage readers.
- Sharper pruning: predicate pushdown fixed for **nanosecond timestamps** in Parquet and ORC; `notStartsWith` no longer skips row groups containing nulls.
- Security: two HIGH-severity `jackson-databind` CVEs (CVE-2026-54512, CVE-2026-54513) fixed by aligning Jackson across runtimes and bundles. If you run the Kafka Connect runtime, note that three Jackson findings remain there because they come from the copy shaded inside `parquet-jackson`.
- Spark maintenance: `rewrite_data_files` accepts `max-file-group-input-files` to cap inputs per group, `rewrite_manifests` gains `sort_by` on Spark 3.5/4.0, and Spark 4.1 gets **Hilbert-curve clustering** for data rewrites - a better sort order for multi-dimensional filter patterns than Z-order on many workloads.

## Breaking Changes - Read Before Upgrading

- **Spark 3.4 support removed**; 1.12.0 supports Spark 3.5, 4.0, and 4.1.
- **Flink 2.0 removed**; supported versions are Flink 1.20, 2.1, 2.2, and 2.3.
- Position-delete files **with row data** can no longer be written (the v3 deletion-vector direction).
- AWS users managing their own SDK classpath: the default AWS SDK HTTP client migrated to Apache HttpClient 5 - switch `software.amazon.awssdk:apache-client` to `apache5-client` (bundle users are unaffected).
- API removals include `DataReader` (use `PlannedDataReader`), the partition-stats read API (use the Partition Stats Scan API), AWS S3 signer classes, and several Spark/Flink utility methods.

## Should You Upgrade?

My take:

1. **Upgrade the libraries, stay on format v2 for existing tables** unless you need v3 features. The engine support matrix for v3 writes is still thin - as my demo showed, PyIceberg 0.12 can't write v3 at all yet ([issue #1551](https://github.com/apache/iceberg-python/issues/1551)), and its merge-on-read falls back to copy-on-write. Spark 4.1 and the Flink versions above are where v3 write paths are real today. Cloud catalogs are moving too - AWS Glue announced v3 table optimization, statistics, and crawler support on October 1.
2. **Plan the v3 move around deletes.** If your pain is streaming upserts and delete-heavy workloads, v3 deletion vectors plus `ConvertEqualityDeletes` are the reason to upgrade table format versions. If you're append-mostly, v2 remains fully supported and your compaction routine matters more.
3. **Check the breaking list against your stack first.** Spark 3.4 and Flink 2.0 shops have to move engine versions before they can move Iceberg.

## Wrapping Up

Iceberg 1.12.0 is a mechanics release: deletion vectors maturing, streaming deletes getting a one-time resolution path, Variant going multi-engine, and the REST protocol growing catalog-migration and security features. None of it is flashy, and all of it compounds - fewer file rewrites on write, less reconciliation on read, and a cleaner path to v3.

**Are you running v3 tables in production yet, or waiting for the client matrix to fill in? And if you've tried `ConvertEqualityDeletes` on a real upsert pipeline, I want to hear what it did to your read latencies - drop a comment!**

## References

- [Apache Iceberg 1.12.0 Release](https://iceberg.apache.org/blog/apache-iceberg-1.12.0-release/) (official release notes)
- [ANNOUNCE: Apache Iceberg release 1.12.0](https://lists.apache.org/thread/kst8b58yjnvfy353g2ysvb4fkx3xdcr9) (ASF mailing list, Oct 1, 2026)
- [Apache Iceberg Spec](https://iceberg.apache.org/spec/) (v3 deletion vectors, row lineage)
- [What's new in Apache Iceberg v3? - Google Open Source Blog](https://opensource.googleblog.com/2025/08/whats-new-in-iceberg-v3.html)
- [AWS Glue Data Catalog support for Iceberg v3 optimization](https://aws.amazon.com/about-aws/whats-new/2026/10/aws-glue-iceberg-v3-optimization/)
- [PyIceberg v3 write support tracking issue](https://github.com/apache/iceberg-python/issues/1551)
