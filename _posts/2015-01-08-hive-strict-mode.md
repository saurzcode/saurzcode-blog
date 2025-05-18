---
id: 802
title: 'Hive Strict Mode'
date: '2015-01-08T14:31:44-07:00'
author: saurzcode

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

![Sort By vs Order By vs Group By vs Cluster By in Hive]{{site.baseurl}}/assets/uploads/2015/01/images.jpg)

# What is Hive Strict Mode?

Hive Strict Mode (`hive.mapred.mode=strict`) enables Hive to restrict certain performance intensive operations. Such as:

- It restricts queries of partitioned tables without a **WHERE** clause.

```vim
hive> set hive.mapred.mode=strict;

hive> SELECT s.name, s.class FROM students s LIMIT 100;

FAILED: Error in semantic analysis: No partition predicate found for

Alias "s" Table "students"

hive> set hive.mapred.mode=nonstrict;

hive> SELECT s.name, s.class FROM students s LIMIT 100;
```

- It restricts **ORDER BY** operation without a **LIMIT** clause (since it uses a single reducer which can choke your processing if not handled properly).

Also for dynamic partitions:

```sh
hive.exec.dynamic.partition.mode=strict
```

This is a default setting and prevents all partitions to be dynamic and requires at least one static partition.

---

You may also like:

- [Top 20 Hadoop Big Data Books](https://saurzcode.in//2014/06/top-20-hadoop-bigdatabooks/)
- [Hive : SORT BY, DISTRIBUTE BY, CLUSTER BY](https://saurzcode.in//2015/01/hive-sort-vs-order-vs-distribute-vs-cluster/)