---
id: 1192
title: 'Dataframe Operations in  Spark using Scala'
date: '2018-06-07T20:42:30-07:00'
author: saurzcode

guid: 'https://saurzcode.in/?p=1192'
permalink: /2018/06/spark-common-dataframe-operations/
meta-checkbox:
    - ''
categories:
    - 'Big Data'
    - Scala
    - Spark
    - Technology
tags:
    - apache-spark
    - bigdata
    - scala
    - spark
---

# DataFrame Operations in Spark using Scala

A comprehensive, developer-friendly guide to common DataFrame operations in Apache Spark using Scala, with code examples and explanations for each join type.

---

## Table of Contents

- [DataFrame Operations in Spark using Scala](#dataframe-operations-in-spark-using-scala)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Creating Example DataFrames](#creating-example-dataframes)
  - [Join Operations](#join-operations)
    - [Cartesian Join](#cartesian-join)
    - [Inner Join (Single Column)](#inner-join-single-column)
    - [Inner Join (Multiple Columns)](#inner-join-multiple-columns)
    - [Left Outer Join (Multiple Columns)](#left-outer-join-multiple-columns)
    - [Left Semi Join (Multiple Columns)](#left-semi-join-multiple-columns)
    - [Outer Join (Multiple Columns)](#outer-join-multiple-columns)
    - [Right Outer Join (Multiple Columns)](#right-outer-join-multiple-columns)
    - [Inner Join (Join Expressions)](#inner-join-join-expressions)
    - [Outer Join (Join Expressions)](#outer-join-join-expressions)
    - [Left Outer Join (Join Expressions)](#left-outer-join-join-expressions)
    - [Right Outer Join (Join Expressions)](#right-outer-join-join-expressions)
    - [Left Semi Join (Join Expressions)](#left-semi-join-join-expressions)
  - [Summary](#summary)

---

## Introduction

A DataFrame in Apache Spark is a distributed collection of data organized into named columns. DataFrames can be transformed and queried using a rich set of operations provided by the Spark DataFrame API. This guide covers the most common join operations you'll use when working with DataFrames in Scala.

---

## Creating Example DataFrames

Let's create some example DataFrames to use in our join operations:

```scala
val saurzDF1 = Seq(
  (101, "sachin", 40),
  (102, "zahir", 41),
  (103, "virat", 29),
  (104, "saurav", 41),
  (105, "rohit", 30)
).toDF("id", "name", "age")

saurzDF1.show()
```

```
+---+------+---+
| id| name|age|
+---+------+---+
|101|sachin| 40|
|102| zahir| 41|
|103| virat| 29|
|104|saurav| 41|
|105| rohit| 30|
+---+------+---+
```

```scala
val saurzDF2 = Seq(
  (101, "batsman"),
  (102, "bowler"),
  (103, "batsman"),
  (104, "batsman")
).toDF("id", "skill")

saurzDF2.show()
```

```
+---+-------+
| id| skill|
+---+-------+
|101|batsman|
|102| bowler|
|103|batsman|
|104|batsman|
+---+-------+
```

```scala
val saurzDF3 = Seq(
  (101, "sachin", 100),
  (103, "virat", 50),
  (104, "saurav", 45),
  (105, "rohit", 35)
).toDF("id", "name", "centuries")

saurzDF3.show()
```

```
+---+------+---------+
| id|  name|centuries|
+---+------+---------+
|101|sachin|      100|
|103| virat|       50|
|104|saurav|       45|
|105| rohit|       35|
+---+------+---------+
```

---

## Join Operations

### Cartesian Join

Creates all possible combinations (m * n) of rows from both DataFrames. **Use with caution!**

```scala
val saurzJoinDF1 = saurzDF1.join(saurzDF2)
saurzJoinDF1.show()
```

### Inner Join (Single Column)

Equivalent to SQL INNER JOIN. The join column appears only once in the result.

```scala
val saurzJoinDF2 = saurzDF1.join(saurzDF2, "id")
saurzJoinDF2.show()
```

### Inner Join (Multiple Columns)

Equivalent to SQL INNER JOIN using multiple columns.

```scala
val saurzJoinDF8 = saurzDF1.join(saurzDF3, Seq("id", "name"))
saurzJoinDF8.show()
```

### Left Outer Join (Multiple Columns)

Equivalent to SQL LEFT OUTER JOIN using multiple columns.

```scala
val saurzJoinDF9 = saurzDF1.join(saurzDF3, Seq("id", "name"), "left_outer")
saurzJoinDF9.show()
```

### Left Semi Join (Multiple Columns)

Equivalent to SQL LEFT SEMI JOIN. Only columns from the left DataFrame are included.

```scala
val saurzJoinDF10 = saurzDF1.join(saurzDF3, Seq("id", "name"), "leftsemi")
saurzJoinDF10.show()
```

### Outer Join (Multiple Columns)

Equivalent to SQL OUTER JOIN using multiple columns.

```scala
val saurzJoinDF11 = saurzDF1.join(saurzDF3, Seq("id", "name"), "outer")
saurzJoinDF11.show()
```

### Right Outer Join (Multiple Columns)

Equivalent to SQL RIGHT OUTER JOIN using multiple columns.

```scala
val saurzJoinDF12 = saurzDF1.join(saurzDF3, Seq("id", "name"), "right_outer")
saurzJoinDF12.show()
```

### Inner Join (Join Expressions)

Performs an INNER JOIN using a join expression. Both DataFrames' join columns are included in the result.

```scala
val saurzJoinDF7 = saurzDF1.join(saurzDF2, saurzDF1("id") === saurzDF2("id"), "inner")
saurzJoinDF7.show()
```

### Outer Join (Join Expressions)

Performs an OUTER JOIN using a join expression.

```scala
val saurzJoinDF3 = saurzDF1.join(saurzDF2, saurzDF1("id") === saurzDF2("id"), "outer")
saurzJoinDF3.show()
```

### Left Outer Join (Join Expressions)

Performs a LEFT OUTER JOIN using a join expression.

```scala
val saurzJoinDF4 = saurzDF1.join(saurzDF2, saurzDF1("id") === saurzDF2("id"), "left_outer")
saurzJoinDF4.show()
```

### Right Outer Join (Join Expressions)

Performs a RIGHT OUTER JOIN using a join expression.

```scala
val saurzJoinDF5 = saurzDF1.join(saurzDF2, saurzDF1("id") === saurzDF2("id"), "right_outer")
saurzJoinDF5.show()
```

### Left Semi Join (Join Expressions)

Performs a LEFT SEMI JOIN using a join expression. Only columns from the left DataFrame are included.

```scala
val saurzJoinDF6 = saurzDF1.join(saurzDF2, saurzDF1("id") === saurzDF2("id"), "leftsemi")
saurzJoinDF6.show()
```

---

## Summary

In this post, we explored various types of JOIN operations that can be performed on Spark DataFrames using Scala. Each join type is useful for different scenarios, and understanding them will help you write more efficient and expressive Spark code.

