---
id: 872
title: 'Hive : SORT BY vs ORDER BY vs DISTRIBUTE BY vs CLUSTER BY'
date: '2015-01-27T06:43:20-07:00'
author: saurzcode

guid: 'https://saurzcode.in//?p=872'
permalink: /2015/01/hive-sort-order-distribute-cluster/
meta-checkbox:
    - ''
dsq_thread_id:
    - '3487179596'
ampforwp_custom_content_editor:
    - ''
ampforwp_custom_content_editor_checkbox:
    - null
ampforwp-amp-on-off:
    - default
categories:
    - 'Big Data'
    - Hive
    - Java
    - Technology
tags:
    - bigdata
    - 'cluster by'
    - 'distribute by'
    - hadoop
    - hive
    - 'hive interview'
    - Hiveql
    - 'order by'
    - 'sort by'
    - spark
    - 'spark sql'
---

In Apache Hive HQL, you can decide to order or sort your data differently based on ordering and distribution requirement. In this post we will look at how **SORT BY**, **ORDER BY**, **DISTRIBUTE BY** and **CLUSTER BY** behave differently in Hive. Let's get started -

![Sort By vs Order By vs Group By vs Cluster By in Hive]({{base.url}}/assets/uploads/2015/01/images.jpg)

## SORT BY

Hive uses the columns in `SORT BY` to sort the rows before feeding the rows to a reducer. The sort order will be dependent on the column types. If the column is of numeric type, then the sort order is also in numeric order. If the column is of string type, then the sort order will be lexicographical order.

**Ordering:** It orders data at each of 'N' reducers, but each reducer can have overlapping ranges of data.

**Outcome:** N or more sorted files with overlapping ranges.

Let's understand with an example of below query:

```sql
hive> SELECT emp_id, emp_salary FROM employees SORT BY emp_salary DESC;
```

Let's assume the number of reducers was set to 2 and the output of each reducer is as follows -

**Reducer 1:**

```
emp_id | emp_salary
10             5000
16             3000
13             2600
19             1800
```

**Reducer 2:**

```
emp_id | emp_salary
11             4000
17             3100
14             2500
20             2000
```

As we can see, values in each reducer output are ordered but total ordering is missing since we end up with multiple outputs per reducer and data within one reducer is sorted in descending order.

## ORDER BY

This is similar to ORDER BY in SQL Language.

In Hive, `ORDER BY` guarantees total ordering of data, but for that, it has to be passed on to a single reducer, which is normally performance-intensive and therefore in strict mode, Hive makes it compulsory to use LIMIT with ORDER BY so that reducer doesn't get overburdened.

**Ordering:** Total Ordered data.

**Outcome:** Single output i.e. fully ordered.

For example:

```sql
hive> SELECT emp_id, emp_salary FROM employees ORDER BY emp_salary DESC;
```

**Reducer:**

```
emp_id | emp_salary
10             5000
11             4000
17             3100
16             3000
13             2600
14             2500
20             2000
19             1800
```

## DISTRIBUTE BY

Hive uses the columns in `DISTRIBUTE BY` to distribute the rows among reducers. All rows with the same `DISTRIBUTE BY` columns will go to the same reducer.

It ensures each of N reducers gets non-overlapping ranges of the column, but doesn't sort the output of each reducer. You end up with N or more unsorted files with non-overlapping ranges.

Example (taken directly from Hive wiki):

We are **Distributing By x** on the following 5 rows to 2 reducers:

```
x1 x2 x4 x3 x1
```

**Reducer 1**

```
x1 x2 x1
```

**Reducer 2**

```
x4 x3
```

Note that all rows with the same key x1 are guaranteed to be distributed to the same reducer (reducer 1 in this case), but they are not guaranteed to be clustered in adjacent positions.

## CLUSTER BY

`CLUSTER BY` is a short-cut for both `DISTRIBUTE BY` and `SORT BY`.

`CLUSTER BY x` ensures each of N reducers gets non-overlapping ranges, then sorts by those ranges at the reducers.

**Ordering:** Global ordering between multiple reducers.

**Outcome:** N or more sorted files with non-overlapping ranges.

For the same example as above, if we use **Cluster By x**, the two reducers will further sort rows on x:

**Reducer 1:**

```
x1 x1 x2
```

**Reducer 2:**

```
x3 x4
```

Instead of specifying `CLUSTER BY`, the user can specify `DISTRIBUTE BY` and `SORT BY`, so the partition columns and sort columns can be different.

---

### References

1. [Hive Cluster By vs Order By vs Sort By (StackOverflow)](http://stackoverflow.com/questions/13715044/hive-cluster-by-vs-order-by-vs-sort-by)
2. [Hive Language Manual: SortBy](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+SortBy#LanguageManualSortBy-SyntaxofOrderBy)

---

You may also be interested in some other BigData posts:

- [CatBoost on Spark - Machine Learning](https://saurzcode.in/2021/05/how-to-train-and-score-catboost-model-on-spark/)
- [Spark: How to Run Spark Applications on Windows](https://saurzcode.in/2019/09/running-spark-application-on-windows/)
- [Getting started with Spark Development](https://saurzcode.in/2017/10/configure-spark-application-eclipse/)
- [Getting started with MapReduce development](https://saurzcode.in//2015/01/setup-development-environment-hadoop-mapreduce/)
- [Multithreaded Mappers in MapReduce](https://wp.me/p5pWDa-iX)
- [Spark Dataframe Operations](https://saurzcode.in/2018/06/spark-common-dataframe-operations/)