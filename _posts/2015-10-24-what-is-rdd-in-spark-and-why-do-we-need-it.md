---
id: 982
title: 'What is RDD in Spark ? and Why do we need it ?'
date: '2015-10-24T09:50:10-07:00'
author: saurzcode
layout: post
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

Resilient Distributed Datasets -RDDs in Spark
---------------------------------------------

Apcahe Spark has already taken over Hadoop (MapReduce) because of plenty of benefits it provides in terms of faster execution in iterative processing algorithms such as Machine learning. In this post, we will try to understand what makes Spark RDDs so useful in batch analytics .

Why RDD ?
---------

When it comes to iterative distributed computing, i.e. processing data over multiple jobs in computations such as Logistic Regression, K-means clustering, Page rank algorithms, it is fairly common to reuse or share the data among multiple jobs or it may involve multiple ad-hoc queries over a shared data set.This makes it very important to have a very good data sharing architecture so that we can perform fast computations. There is an underlying problem with data reuse or data sharing in existing distributed computing systems (such as MapReduce) and that is , you need to store data in some intermediate stable distributed store such as HDFS or Amazon S3. This makes the overall computations of jobs slower since it involves multiple IO operations, replications and serializations in the process. \[caption id="attachment\_983" width="708" align="aligncenter"\][![Spark-HDFS-Write](https://saurzcode.in//assets/uploads/2015/10/Spark-HDFS-Write.png)](https://saurzcode.in//assets/uploads/2015/10/Spark-HDFS-Write.png) Iterative Processing in MapReduce\[/caption\] RDDs , try to solve these problems by enabling fault tolerant distributed In-memory computations. \[caption id="attachment\_985" width="711" align="aligncenter"\][![Spark-RDD](https://saurzcode.in//assets/uploads/2015/10/Spark-RDD.png)](https://saurzcode.in//assets/uploads/2015/10/Spark-RDD.png) Iterative Processing in Spark\[/caption\] Now, lets understand what is RDD and how it helps to achieve fast and fault tolerant In-memory computations.

RDD - Resilient Distributed Datasets
------------------------------------

RDDs are huge collections of records with following properties -

*   Immutable
*   Partitioned
*   Fault tolerant
*   Created by coarse grained operations
*   Lazily evaluated
*   Can be persisted

Let's try to understand these characteristics -

### Immutability and partitioning

RDDs composed of collection of records which are partitioned. Partition is basic unit of parallelism in a RDD, and each partition is one logical division of data which is immutable and created through some transformations on existing partitions.Immutability helps to achieve consistency in computations. Users can define their own criteria for partitioning based on keys on which they want to join multiple datasets if needed.

### Coarse grained operations

Coarse grained operations are operations which are applied to all elements in datasets. For example - a map, or filter or groupBy operation which will be performed on all elements in a partition of RDD.

### Transformations and actions

RDDs can only be created by reading data from a stable storage such as HDFS or by transformations on existing RDDs. All computations on RDDs are either transformations or actions.

### [![saurzcode-rdd-transformation-action](https://saurzcode.in//assets/uploads/2015/10/saurzcode_RDD_Transformation_Action-final.png)](https://saurzcode.in//assets/uploads/2015/10/saurzcode_RDD_Transformation_Action-final.png)

### Fault Tolerance

Since RDDs are created over a set of transformations , it logs those transformations, rather than actual data.Graph of these transformations to produce one RDD is called as _Lineage Graph_. For example -

firstRDD=spark.textFile("hdfs://...")

secondRDD=firstRDD.filter(someFunction);

thirdRDD = secondRDD.map(someFunction);

result = thirdRDD.count()

\[caption id="attachment\_987" width="173" align="alignleft"\][![RDD](https://saurzcode.in//assets/uploads/2015/10/RDD.png)](https://saurzcode.in//assets/uploads/2015/10/RDD.png) Spark RDD Lineage Graph\[/caption\] In case of we lose some partition of RDD , we can replay the transformation on that partition in lineage to achieve the same computation, rather than doing data replication across multiple nodes.This characteristic is biggest benefit of RDD , because it saves a lot of efforts in data management and replication and thus achieves faster computations.

### Lazy evaluations

Spark computes RDDs lazily the first time they are used in an action, so that it can pipeline transformations. So , in above example RDD will be evaluated only when _count(_) action is invoked.

### Persistence

Users can indicate which RDDs they will reuse and choose a storage strategy for them (e.g., in-memory storage or on Disk etc.) These properties of RDDs make them useful for fast computations. Reference: [https://www.usenix.org/system/files/conference/nsdi12/nsdi12-final138.pdf](https://www.usenix.org/system/files/conference/nsdi12/nsdi12-final138.pdf) 

Related - [Spark Dataframe Operations](https://saurzcode.in/2018/06/spark-common-dataframe-operations/)