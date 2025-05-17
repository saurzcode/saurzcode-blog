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

<h2>Resilient Distributed Datasets -RDDs in Spark</h2>
Apcahe Spark has already taken over Hadoop (MapReduce)  because of plenty of benefits it provides in terms of faster execution in iterative processing algorithms such as Machine learning.

In this post, we will try to understand what makes Spark RDDs so useful in batch analytics .
<h2>Why RDD ?</h2>
When it comes to iterative distributed computing, i.e. processing data over multiple jobs in computations such as  Logistic Regression, K-means clustering, Page rank algorithms, it is fairly common to reuse or share the data among multiple jobs or it may involve multiple ad-hoc queries over a shared data set.This makes it very important to have a very good data sharing architecture so that we can perform fast computations.

<!--more-->

There is an underlying problem with data reuse or data sharing in existing distributed computing systems (such as MapReduce) and that is , you need to store data in some intermediate stable distributed store such as HDFS or Amazon S3. This makes the overall computations of jobs slower since it involves multiple IO operations, replications and serializations in the process.

[caption id="attachment_983" width="708" align="aligncenter"]<a href="https://saurzcode.in//wp-content/uploads/2015/10/Spark-HDFS-Write.png"><img class="wp-image-983 size-full" src="https://saurzcode.in//wp-content/uploads/2015/10/Spark-HDFS-Write.png" alt="Spark-HDFS-Write" width="708" height="247"></a> Iterative Processing in MapReduce[/caption]

RDDs , try to solve these problems by enabling <span style="text-decoration: underline;">fault tolerant distributed</span> <span style="text-decoration: underline;">In-memory</span> computations.

[caption id="attachment_985" width="711" align="aligncenter"]<a href="https://saurzcode.in//wp-content/uploads/2015/10/Spark-RDD.png"><img class="wp-image-985 size-full" src="https://saurzcode.in//wp-content/uploads/2015/10/Spark-RDD.png" alt="Spark-RDD" width="711" height="259"></a> Iterative Processing in Spark[/caption]

Now, lets understand what is RDD and how it helps to achieve fast and fault tolerant In-memory computations.
<h2>RDD - Resilient Distributed Datasets</h2>
RDDs are huge collections of records with following properties -
<ul>
	<li>Immutable</li>
	<li>Partitioned</li>
	<li>Fault tolerant</li>
	<li>Created by coarse grained operations</li>
	<li>Lazily evaluated</li>
	<li>Can be persisted</li>
</ul>
Let's try to understand these characteristics -
<h3>Immutability and partitioning</h3>
RDDs composed of collection of records which are partitioned. Partition is basic unit of parallelism in a RDD, and each partition is one logical division of data which is immutable and created through some transformations on existing partitions.Immutability helps to achieve consistency in computations.

Users can define their own criteria for partitioning based on keys on which they want to join multiple datasets if needed.
<h3>Coarse grained operations</h3>
Coarse grained operations are operations which are applied to all elements in datasets. For example - a map, or filter or groupBy operation which will be performed on all elements in a partition of RDD.
<h3>Transformations and actions</h3>
RDDs can only be created by reading data from a stable storage such as HDFS or by transformations on existing RDDs. All computations on RDDs are either transformations or actions.
<h3><a href="https://saurzcode.in//wp-content/uploads/2015/10/saurzcode_RDD_Transformation_Action-final.png"><img class="aligncenter wp-image-1049 size-full" src="https://saurzcode.in//wp-content/uploads/2015/10/saurzcode_RDD_Transformation_Action-final.png" alt="saurzcode-rdd-transformation-action" width="629" height="295"></a></h3>
<h3>Fault Tolerance</h3>
Since RDDs are created over a set of transformations , it logs those transformations, rather than actual data.Graph of these transformations to produce one RDD is called as <i>Lineage Graph</i>.

For example -
<pre class="lang:scala decode:true">firstRDD=spark.textFile("hdfs://...")

secondRDD=firstRDD.filter(someFunction);

thirdRDD = secondRDD.map(someFunction);

result = thirdRDD.count()</pre>

[caption id="attachment_987" width="173" align="alignleft"]<a href="https://saurzcode.in//wp-content/uploads/2015/10/RDD.png"><img class="wp-image-987 size-full" src="https://saurzcode.in//wp-content/uploads/2015/10/RDD.png" alt="RDD" width="173" height="221"></a> Spark RDD Lineage Graph[/caption]

 

 

 

 

 

 

In case of we lose some partition of RDD , we can replay the transformation on that partition  in lineage to achieve the same computation, rather than doing data replication across multiple nodes.This characteristic is biggest benefit of RDD , because it saves a lot of efforts in data management and replication and thus achieves faster computations.
<h3>Lazy evaluations</h3>
Spark computes RDDs lazily the first time they are used in an action, so that it can pipeline transformations. So , in above example RDD will be evaluated only when <i>count(</i>) action is invoked.
<h3>Persistence</h3>
Users can indicate which RDDs they will reuse and choose a storage strategy for them (e.g., in-memory storage or on Disk etc.)

These properties of RDDs make them useful for fast computations.

Reference: <a href="https://www.usenix.org/system/files/conference/nsdi12/nsdi12-final138.pdf">https://www.usenix.org/system/files/conference/nsdi12/nsdi12-final138.pdf</a>



Related -

<a href="https://saurzcode.in/2018/06/spark-common-dataframe-operations/">Spark Dataframe Operations</a>