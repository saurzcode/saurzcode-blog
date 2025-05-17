---
id: 802
title: 'Hive Strict Mode'
date: '2015-01-08T14:31:44-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in//?p=802'
permalink: /2015/01/hive-strict-mode/
meta-checkbox:
    - ''
dsq_thread_id:
    - '4236077541'
categories:
    - 'Big Data'
    - Hive
    - Java
tags:
    - bigdata
    - hadoop
    - hbase
    - hive
---

<a href="https://saurzcode.in//wp-content/uploads/2015/01/images.jpg"><img class=" wp-image-797" src="https://saurzcode.in//wp-content/uploads/2015/01/images.jpg" alt="Sort By vs Order By vs Group By vs Cluster By in Hive" width="296" height="296" /></a>
<h1>What is Hive Strict Mode ?</h1>
Hive Strict Mode ( <strong>hive.mapred.mode=strict</strong>) enables hive to restrict certain performance intensive operations. Such as -
<ul>
	<li>It restricts queries of partitioned tables without a <strong>WHERE</strong> clause.</li>
</ul>
<pre class="lang:vim decode:true">hive&gt; set hive.mapred.mode=strict;

hive&gt; SELECT s.name, s.class FROM students s LIMIT 100;

FAILED: Error in semantic analysis: No partition predicate found for

Alias "s" Table "students"

hive&gt; set hive.mapred.mode=nonstrict;

hive&gt; SELECT s.name, s.class FROM students s LIMIT 100;</pre>
<ul>
	<li>It restricts <strong>ORDER BY</strong> operation without a <strong>LIMIT</strong> clause ( since it uses a single reducer which can choke your processing if not handled properly</li>
</ul>
Also for dynamic partitons -
<pre class="lang:sh decode:true">hive.exec.dynamic.partition.mode=strict</pre>
This is a default setting and prevents all partitions to be dynamic and requires at least one static partition.

<hr />

You may also like -
<ul>
	<li><a href="https://saurzcode.in//2014/06/top-20-hadoop-bigdatabooks/" target="_blank">Top 20 Hadoop Big Data Books</a></li>
	<li><a href="https://saurzcode.in//2015/01/hive-sort-vs-order-vs-distribute-vs-cluster/" target="_blank">Hive : SORTY BY , DISTRIBUTE BY, CLUSTER BY</a></li>
</ul>