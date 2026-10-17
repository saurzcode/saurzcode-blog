---
layout: post
title: "AI Is Only as Good as Your Data Pipelines: Data Engineering Concepts Behind Every ML and GenAI System"
date: 2026-10-17
categories: [big-data, AI, Data-Engineering]
tags: [AI, machine learning, data engineering, Apache Iceberg, Spark, Kafka, data lakes, feature engineering]
description: Every AI system sits on top of data engineering. Storage, table formats, streaming, Spark and reproducibility decide whether your models work in production. Here is how the classic concepts map to modern AI.
---

## Behind Every Great Model Is a Boring, Reliable Pipeline

**Models get the headlines. Pipelines decide whether they work.**

I started on Hadoop, Hive and Kafka, long before "AI" was on every slide. What strikes me now is how little the fundamentals changed. The model is the visible 10%. The other 90% is data engineering: where data lives, how it arrives, how it is versioned and how it is served.

In this post, we'll map the classic data engineering concepts to what AI teams need today:
- Storage: where training data lives
- Table formats: making data trustworthy and reproducible
- Streaming: fresh data for models and agents
- Distributed processing: features at scale
- A checklist for AI-ready data platforms

---
<!--more-->

## 1. Storage: Training Data Needs a Home

Large training sets, embeddings and logs are big, append-heavy and read by many jobs at once. That is the same workload that pushed the industry from HDFS to object stores. I covered the trade-offs in [HDFS vs Object Storage](https://saurzcode.in/big-data/cloud/storage/hdfs-vs-object-storage/).

For AI the argument gets stronger:
- **Decoupled storage and compute**: GPU clusters spin up for training and shut down after, while the data stays put.
- **Cost tiers**: raw logs and old snapshots move to cheaper storage.
- **One copy, many readers**: Spark, notebooks and training jobs read the same files.

The catch is that a pile of Parquet files in a bucket is not a dataset. That brings us to table formats.

---

## 2. Table Formats: Trustworthy and Reproducible Data

Ask a hard question of any ML system: *"Which exact data was this model trained on?"* Without versioned data, nobody can answer it.

This is where an open table format helps. In [Apache Iceberg: The Open Table Format Revolutionizing Analytics](https://saurzcode.in/big-data/apache-iceberg/data-engineering/apache-iceberg/) I wrote about snapshots, schema evolution and time travel. Here is why each one matters for AI:

| Iceberg feature | Why AI teams care |
|---|---|
| Snapshots and time travel | Re-create the exact training set for any past model |
| Atomic commits | Training jobs never read half-written data |
| Schema evolution | Add new features or columns without rewriting history |
| Partition evolution | Change layout as data volume grows, with no migration project |
| Row-level deletes | Honor deletion requests (for example privacy requests) in training data |

### Pin your training data to a snapshot

Iceberg supports time travel in Spark SQL with `TIMESTAMP AS OF` and `VERSION AS OF`. The `VERSION AS OF` clause accepts a snapshot ID or a named branch or tag.

```sql
-- Train on the table exactly as it was at a point in time
SELECT * FROM lake.ml.user_events
TIMESTAMP AS OF '2026-10-01 00:00:00';

-- Or pin by snapshot ID (replace with a real ID from the table's snapshots)
SELECT * FROM lake.ml.user_events
VERSION AS OF 1234567890123456789;
```

Log the snapshot ID next to the model version in your experiment tracker. When a model misbehaves in production, you can go back to the exact data it learned from. For longer-lived references, Iceberg also supports named tags on snapshots, which are easier to remember than a long ID.

---

## 3. Streaming: Fresh Data for Models and Agents

A fraud model that sees yesterday's data is a bad fraud model. Recommenders, anomaly detection and AI agents that answer from live data all need fresh events.

That is classic Kafka territory. My early post on [Kafka Producer using Twitter Stream](https://saurzcode.in/2015/02/kafka-producer-using-twitter-stream/) showed events flowing into a topic, and [Integrating Kafka with HDFS using Camus](https://saurzcode.in/2015/02/integrate-kafka-hdfs-using-camus-twitter-stream-example/) landed them in storage. The tools changed, the pattern did not:

1. Events arrive in Kafka.
2. A stream job cleans and enriches them.
3. The result lands in a table that both analysts and ML jobs read, today usually an Iceberg table instead of raw HDFS files.

That last step is the real upgrade. The same table serves your dashboards, your training jobs and your feature pipelines.

---

## 4. Distributed Processing: Features at Scale

Models do not consume raw data. They consume **features**: aggregates, ratios, counts over windows, encoded categories. Computing them over billions of rows is a Spark job.

If you are new to it, start with the building blocks:
- [What is RDD in Spark and why do we need it?](https://saurzcode.in/2015/10/what-is-rdd-in-spark-and-why-do-we-need-it/) explains the distributed data model underneath.
- [Dataframe Operations in Spark using Scala](https://saurzcode.in/2018/06/spark-common-dataframe-operations/) covers the select, filter, join and aggregate operations that feature pipelines are made of.

A typical feature job in PySpark:

```python
from pyspark.sql import SparkSession, functions as F

spark = SparkSession.builder.appName("user-features").getOrCreate()

events = spark.table("lake.ml.user_events")

features = (
    events
    .where(F.col("event_time") >= F.date_sub(F.current_date(), 30))
    .groupBy("user_id")
    .agg(
        F.count("*").alias("events_30d"),
        F.countDistinct("session_id").alias("sessions_30d"),
        F.avg("purchase_amount").alias("avg_purchase_30d"),
    )
)

features.writeTo("lake.ml.user_features").createOrReplace()
```

Training can run on the same cluster. In [How to Train and Score a CatBoost Model on Spark](https://saurzcode.in/2021/05/how-to-train-and-score-catboost-model-on-spark/) I showed distributed training and scoring with the Spark ML API. That post targets older Spark versions, so check the CatBoost Spark package's compatibility notes before using it on a current cluster.

A common failure to avoid is **training-serving skew**: features computed one way in training and another way in production. Define each feature once, in one pipeline, and reuse it for both.

---

## 5. What About GenAI?

Retrieval-augmented generation, agents and fine-tuning look new, but the data problems are familiar:

- **Ingestion and cleaning**: documents, tickets and logs need parsing, deduplication and quality checks before they are chunked and embedded.
- **Freshness**: if the source changes, the index must change. That is an incremental pipeline problem, not an AI problem.
- **Lineage**: when an answer is wrong, you need to trace it to the source record.
- **Access control**: an assistant must only retrieve what the asking user is allowed to see.

The model is swappable. The pipeline that feeds it is the part you will maintain for years.

---

## An AI-Ready Data Platform Checklist

- [ ] Data lives in durable, cheap, decoupled storage
- [ ] Tables use an open format with snapshots and schema evolution
- [ ] Every model run records the data snapshot it used
- [ ] Streaming ingestion feeds the same tables batch jobs read
- [ ] Features are defined once and shared between training and serving
- [ ] Data quality checks run before data reaches a model
- [ ] Lineage and access control are tracked end to end

---

## Conclusion

AI did not replace data engineering. It raised the stakes. Better models do not fix unreliable data, they just make confident mistakes faster.

If you are building in this space, invest in the foundations: storage, table formats, streaming and reproducible processing. The older posts linked above are a good place to start.

---

## 💬 Let's Discuss

How does your team track which data a model was trained on? Share your approach in the comments.
