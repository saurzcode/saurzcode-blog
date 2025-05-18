---
id: 823
title: 'What is Apache HCatalog ?'
date: '2015-10-18T16:44:35-07:00'
author: saurzcode
layout: medium
guid: 'https://saurzcode.in//?p=823'
permalink: /2015/10/what-is-apache-hcatalog/
meta-checkbox:
    - ''
dsq_thread_id:
    - '4236853097'
categories:
    - 'Big Data'
    - Hive
    - Java
tags:
    - bigdata
    - hadoop
    - hcatalog
    - hive
---

**What is HCatalog ?**
----------------------

Apache HCatalog is a Storage Management Layer for Hadoop that helps to users of different data processing tools in Hadoop ecosystem like Hive, Pig and MapReduce easily read and write data from the cluster.HCatalog enables with relational view of data from RCFile format, Parquet, ORC files, Sequence files stored on HDFS. It also exposes REST API exposed to external systems to access the metadata. [![Capture](https://saurzcode.in//assets/uploads/2015/10/Capture.png)](https://saurzcode.in//assets/uploads/2015/10/Capture.png)

**HCatalog Functions -**
------------------------

Apache HCatalog provides the following benefits :-

*   Frees the user from having to know where the data is stored, with the table abstraction
*   Enables notifications of data availability
*   Provides visibility for data cleaning and archiving tools

How It Works ?
--------------

HCatalog supports reading and writing files in any format for which a Hive SerDe (serializer-deserializer) can be written. By default, HCatalog supports RCFile,Parquet, ORCFile CSV, JSON, and SequenceFile formats. To use a custom format, you must provide the InputFormat, OutputFormat, and SerDe. HCatalog is built on top of the Hive metastore and incorporates components from the Hive DDL. HCatalog provides read and write interfaces for Pig and MapReduce and uses Hive's command line interface for issuing data definition and metadata exploration commands. It also presents a REST interface to allow external tools access to Hive DDL (Data Definition Language) operations, such as "create table" and "describe table". HCatalog presents a relational view of data. Data is stored in tables and these tables can be placed into databases. Tables can also be partitioned on one or more keys. For a given value of a key (or set of keys) there will be one partition that contains all rows with that value (or set of values).

You can also checkout [HCatalog integration with Pig](https://saurzcode.in//2015/01/use-hcatalog-pig/) here.

* * *

  Reference - https://cwiki.apache.org/confluence/display/Hive/HCatalog