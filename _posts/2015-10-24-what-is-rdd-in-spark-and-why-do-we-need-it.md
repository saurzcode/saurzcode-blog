---
id: 982
title: 'What is RDD in Spark ? and Why do we need it ?'
date: '2015-10-24T09:50:10-07:00'
author: saurzcode

guid: 'https://saurzcode.in//?p=982'
permalink: /2015/10/what-is-rdd-in-spark-and-why-do-we-need-it/
meta-checkbox:
    - ''
dsq_thread_id:
    - '4255509268'
categories:
    - 'Big Data'
    - Spark
tags:
    - bigdata
    - fast
    - hadoop
    - rdd
    - spark
---

# What is RDD in Spark? And Why Do We Need It?

A developer-friendly guide to understanding Resilient Distributed Datasets (RDDs) in Apache Spark, their properties, and why they are fundamental for fast, fault-tolerant distributed computing.

---

## Table of Contents

- [What is RDD in Spark? And Why Do We Need It?](#what-is-rdd-in-spark-and-why-do-we-need-it)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Why RDD?](#why-rdd)
  - [What is an RDD?](#what-is-an-rdd)
  - [Key Properties of RDDs](#key-properties-of-rdds)
    - [Immutability and Partitioning](#immutability-and-partitioning)
    - [Coarse-Grained Operations](#coarse-grained-operations)
    - [Transformations and Actions](#transformations-and-actions)
    - [Fault Tolerance and Lineage](#fault-tolerance-and-lineage)
    - [Lazy Evaluation](#lazy-evaluation)
    - [Persistence](#persistence)
  - [RDDs vs. MapReduce](#rdds-vs-mapreduce)
  - [Summary](#summary)
  - [References \& Related Reading](#references--related-reading)

---

## Introduction

Apache Spark has become a popular alternative to Hadoop MapReduce for big data processing, especially for iterative algorithms in machine learning and analytics. The core abstraction that enables Spark's speed and flexibility is the **Resilient Distributed Dataset (RDD)**.

---

## Why RDD?

In iterative distributed computing (e.g., logistic regression, k-means clustering, PageRank), it's common to reuse or share data across multiple jobs or queries. Traditional systems like MapReduce require storing intermediate data in distributed storage (HDFS, S3), which slows down computation due to repeated I/O, replication, and serialization.

**Problem with MapReduce:**
- Data sharing between jobs is slow due to reliance on disk-based storage
- Multiple I/O operations and serialization overhead

**Spark's Solution:**
- RDDs enable fast, fault-tolerant, in-memory computations
- Reduce the need for repeated disk I/O

---

## What is an RDD?

An **RDD (Resilient Distributed Dataset)** is a fundamental data structure in Spark representing an immutable, distributed collection of objects that can be processed in parallel.

---

## Key Properties of RDDs

### Immutability and Partitioning

- RDDs are **immutable**: once created, they cannot be changed
- Data is **partitioned** across the cluster for parallel processing
- Each partition is a logical chunk of data processed independently
- Users can define custom partitioning (e.g., by key)

### Coarse-Grained Operations

- Operations are **coarse-grained**: applied to all elements in the dataset
- Examples: `map`, `filter`, `groupBy`
- These operations are performed on each partition in parallel

### Transformations and Actions

- **Transformations** create a new RDD from an existing one (e.g., `map`, `filter`)
- **Actions** trigger computation and return a result (e.g., `count`, `collect`)
- RDDs are created by reading data from storage or by transforming other RDDs

**Example:**

```scala
val textRDD = spark.textFile("hdfs://...")
val filteredRDD = textRDD.filter(line => line.contains("error"))
val count = filteredRDD.count()
```

### Fault Tolerance and Lineage

- RDDs track the sequence of transformations (the **lineage graph**) used to build them
- If a partition is lost, Spark can recompute it using the lineage
- No need for data replication across nodes

**Example Lineage:**

```scala
val firstRDD = spark.textFile("hdfs://...")
val secondRDD = firstRDD.filter(someFunction)
val thirdRDD = secondRDD.map(someFunction)
val result = thirdRDD.count()
```

If a partition of `thirdRDD` is lost, Spark can recompute it by replaying the transformations from `firstRDD`.

### Lazy Evaluation

- Transformations are **lazy**: Spark doesn't compute them until an action is called
- Allows Spark to optimize the execution plan and pipeline transformations

### Persistence

- RDDs can be **persisted** (cached) in memory or on disk
- Users can choose the storage strategy (e.g., memory-only, memory-and-disk)
- Useful for iterative algorithms that reuse the same data

**Example:**

```scala
val cachedRDD = filteredRDD.persist()
```

---

## RDDs vs. MapReduce

| Feature                | RDD (Spark)         | MapReduce (Hadoop)   |
|------------------------|---------------------|----------------------|
| Data Sharing           | In-memory, fast     | Disk-based, slow     |
| Fault Tolerance        | Lineage-based       | Data replication     |
| Computation Model      | Transformations     | Map/Reduce steps     |
| Iterative Processing   | Efficient           | Inefficient          |
| API                    | Functional, rich    | Limited, verbose     |

---

## Summary

- RDDs are the core abstraction in Spark for fast, fault-tolerant, distributed data processing
- They enable in-memory computation, lazy evaluation, and efficient data sharing
- RDDs are ideal for iterative algorithms and interactive analytics

---

## References & Related Reading

- [Spark RDD Programming Guide](https://spark.apache.org/docs/latest/rdd-programming-guide.html)
- [USENIX Paper: Resilient Distributed Datasets](https://www.usenix.org/system/files/conference/nsdi12/nsdi12-final138.pdf)
- [Spark DataFrame Operations](https://saurzcode.in/2018/06/spark-common-dataframe-operations/)