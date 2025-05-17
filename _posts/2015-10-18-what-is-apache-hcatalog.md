---
id: 823
title: 'What is Apache HCatalog ?'
date: '2015-10-18T16:44:35-07:00'
author: saurzcode
layout: post
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

<h2><strong>What is HCatalog ?</strong></h2>
Apache HCatalog is a Storage Management Layer for Hadoop that helps to users of different data processing tools in Hadoop ecosystem like Hive, Pig and MapReduce easily read and write data from the cluster.HCatalog enables with relational view of data  from RCFile format, Parquet, ORC files, Sequence files stored on HDFS. It also exposes REST API exposed to external systems to access the metadata.<!--more-->

<a href="https://saurzcode.in//wp-content/uploads/2015/10/Capture.png"><img class="aligncenter wp-image-968 size-full" src="https://saurzcode.in//wp-content/uploads/2015/10/Capture.png" alt="Capture" width="746" height="452" /></a>
<h2><strong>HCatalog Functions -</strong></h2>
Apache HCatalog provides the following benefits :-
<ul>
	<li>Frees the user from having to know where the data is stored, with the table abstraction</li>
	<li>Enables notifications of data availability</li>
	<li>Provides visibility for data cleaning and archiving tools</li>
</ul>
<div class="grid">
<div class="col-3-4 maincontent">
<h2>How It Works ?</h2>
HCatalog supports reading and writing files in any format for which a Hive SerDe (serializer-deserializer) can be written. By default, HCatalog supports RCFile,Parquet, ORCFile CSV, JSON, and SequenceFile formats. To use a custom format, you must provide the InputFormat, OutputFormat, and SerDe.

HCatalog is built on top of the Hive metastore and incorporates components from the Hive DDL. HCatalog provides read and write interfaces for Pig and MapReduce and uses Hive’s command line interface for issuing data definition and metadata exploration commands. It also presents a REST interface to allow external tools access to Hive DDL (Data Definition Language) operations, such as “create table” and “describe table”.

HCatalog presents a relational view of data. Data is stored in tables and these tables can be placed into databases. Tables can also be partitioned on one or more keys. For a given value of a key (or set of keys) there will be one partition that contains all rows with that value (or set of values).

</div>
You can also checkout <a href="https://saurzcode.in//2015/01/use-hcatalog-pig/">HCatalog integration with Pig</a> here.

<hr />

</div>
&nbsp;

Reference - https://cwiki.apache.org/confluence/display/Hive/HCatalog