---
id: 1192
title: 'Dataframe Operations in  Spark using Scala'
date: '2018-06-07T20:42:30-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in/?p=1192'
permalink: /2018/06/spark-common-dataframe-operations/
meta-checkbox:
    - ''
image: assets/uploads/2017/10/spark-logo.png
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

Dataframe in Apache Spark is a distributed collection of data, organized in the form of columns. Dataframes can be transformed into various forms using DSL operations defined in [Dataframes API](https://spark.apache.org/docs/1.6.1/api/scala/index.html#org.apache.spark.sql.DataFrame), and its various functions. In this post, let's understand various join operations, that are regularly used while working with Dataframes - To understand these operations lets create a set of dataframes -

val saurzDF1 = Seq(
(101, "sachin",40),
(102, "zahir",41),
(103, "virat",29),
(104, "saurav",41),
(105,"rohit",30)
).toDF("id", "name","age")

saurzDF1: org.apache.spark.sql.DataFrame = \[id: int, name: string, age: int\]


saurzDF1.show()


+---+------+---+
| id| name|age|
+---+------+---+
|101|sachin| 40|
|102| zahir| 41|
|103| virat| 29|
|104|saurav| 41|
|105| rohit| 30|
+---+------+---+

val saurzDF2 = Seq(
(101, "batsman"),
(102, "bowler"),
(103, "batsman"),
(104, "batsman")
).toDF("id", "skill")


saurzDF2: org.apache.spark.sql.DataFrame = \[id: int, skill: string\]

saurzDF2.show()

+---+-------+
| id| skill|
+---+-------+
|101|batsman|
|102| bowler|
|103|batsman|
|104|batsman|
+---+-------+

val saurzDF3 = Seq(
  (101, "sachin",100),
  (103, "virat",50),
  (104,  "saurav",45),
  (105,"rohit",35)
).toDF("id", "name","centuries")

saurzDF3: org.apache.spark.sql.DataFrame = \[id: int, name: string, centuries: int\]

saurzDF3.show()

+---+------+---------+
| id|  name|centuries|
+---+------+---------+
|101|sachin|      100|
|103| virat|       50|
|104|saurav|       45|
|105| rohit|       35|
+---+------+---------+

* * *

Now our dataframes are ready , lets try out some operations -

JOIN Operations on Dataframe
----------------------------

### Cartesion Join

This join is very expensive to perform as it creates (m\*n) combination of rows , where m is number of rows in DF1 and n is number of rows in DF2.

val saurzJoinDF1 = saurzDF1.join(saurzDF2)
saurzJoinDF1.show()

+---+------+---+---+-------+
| id|  name|age| id|  skill|
+---+------+---+---+-------+
|101|sachin| 40|101|batsman|
|102| zahir| 41|101|batsman|
|103| virat| 29|101|batsman|
|104|saurav| 41|101|batsman|
|105| rohit| 30|101|batsman|
|101|sachin| 40|102| bowler|
|102| zahir| 41|102| bowler|
|103| virat| 29|102| bowler|
|104|saurav| 41|102| bowler|
|105| rohit| 30|102| bowler|
|101|sachin| 40|103|batsman|
|102| zahir| 41|103|batsman|
|103| virat| 29|103|batsman|
|104|saurav| 41|103|batsman|
|105| rohit| 30|103|batsman|
|101|sachin| 40|104|batsman|
|102| zahir| 41|104|batsman|
|103| virat| 29|104|batsman|
|104|saurav| 41|104|batsman|
|105| rohit| 30|104|batsman|
+---+------+---+---+-------+

### Inner Join Using Column

This join behaves exactly like INNER join in SQL and in the result, join column will appear exactly once.

val saurzJoinDF2 = saurzDF1.join(saurzDF2,"id")
saurzJoinDF2.show()

+---+------+---+-------+
| id|  name|age|  skill|
+---+------+---+-------+
|101|sachin| 40|batsman|
|102| zahir| 41| bowler|
|103| virat| 29|batsman|
|104|saurav| 41|batsman|
+---+------+---+-------+

### Inner Join using Sequence of Columns

This is also equivalent to SQL INNER Join, but using a sequence of columns, and join columns will appear exactly once.

val saurzJoinDF8= saurzDF1.join(saurzDF3,Seq("id", "name"))
saurzJoinDF8.show()

+---+------+---+---------+
| id|  name|age|centuries|
+---+------+---+---------+
|101|sachin| 40|      100|
|103| virat| 29|       50|
|104|saurav| 41|       45|
|105| rohit| 30|       35|
+---+------+---+---------+

### Left Outer Join Using Sequence of columns

This is also equivalent to SQL LEFT OUTER Join, but using a sequence of columns, and join columns will appear exactly once.

val saurzJoinDF9= saurzDF1.join(saurzDF3,Seq("id", "name"),"left\_outer")
saurzJoinDF9.show()

+---+------+---+---------+
| id|  name|age|centuries|
+---+------+---+---------+
|101|sachin| 40|      100|
|102| zahir| 41|     null|
|103| virat| 29|       50|
|104|saurav| 41|       45|
|105| rohit| 30|       35|
+---+------+---+---------+

### Left Semi Join using Sequence of Columns

This is also equivalent to SQL LEFT SEMI Join, and the output contains only columns from left data frame.

val saurzJoinDF10= saurzDF1.join(saurzDF3,Seq("id", "name"),"leftsemi")
saurzJoinDF10.show()

+---+------+---+
| id|  name|age|
+---+------+---+
|101|sachin| 40|
|103| virat| 29|
|104|saurav| 41|
|105| rohit| 30|
+---+------+---+

### Outer Join Using Sequence of Columns

This is also equivalent to SQL OUTER Join, but using a sequence of columns, and join columns will appear exactly once.

val saurzJoinDF11= saurzDF1.join(saurzDF3,Seq("id", "name"),"outer")
saurzJoinDF11.show()

+---+------+---+---------+
| id|  name|age|centuries|
+---+------+---+---------+
|104|saurav| 41|       45|
|103| virat| 29|       50|
|101|sachin| 40|      100|
|102| zahir| 41|     null|
|105| rohit| 30|       35|
+---+------+---+---------+

### Right Outer Join Using Sequence of Columns

This is also equivalent to SQL RIGHT OUTER JOIN, but using a sequence of columns, and join columns will appear exactly once.

val saurzJoinDF12= saurzDF1.join(saurzDF3,Seq("id", "name"),"right\_outer")
saurzJoinDF12.show()

+---+------+---+---------+
| id|  name|age|centuries|
+---+------+---+---------+
|101|sachin| 40|      100|
|103| virat| 29|       50|
|104|saurav| 41|       45|
|105| rohit| 30|       35|
+---+------+---+---------+

### Inner join Using Join Expressions

It performs INNER join operation using a join expression. Joins using expressions, produce join columns from both data frames and it is required to explicitly select the columns from output or the undesired column can be dropped later.

val saurzJoinDF7= saurzDF1.join(saurzDF2,saurzDF1("id")===saurzDF2("id"),"inner")
saurzJoinDF7.show()

+---+------+---+---+-------+
| id|  name|age| id|  skill|
+---+------+---+---+-------+
|101|sachin| 40|101|batsman|
|102| zahir| 41|102| bowler|
|103| virat| 29|103|batsman|
|104|saurav| 41|104|batsman|
+---+------+---+---+-------+

### Outer Join Using Join Expressions

Similar to above, it performs  OUTER JOIN.

val saurzJoinDF3 = saurzDF1.join(saurzDF2,saurzDF1("id")===saurzDF2("id"),"outer")
saurzJoinDF3.show()

+---+------+---+----+-------+
| id|  name|age|  id|  skill|
+---+------+---+----+-------+
|101|sachin| 40| 101|batsman|
|102| zahir| 41| 102| bowler|
|103| virat| 29| 103|batsman|
|104|saurav| 41| 104|batsman|
|105| rohit| 30|null|   null|
+---+------+---+----+-------+

### Left Outer Join using Join Expressions

Similar to above, it performs LEFT OUTER JOIN.

val saurzJoinDF4 = saurzDF1.join(saurzDF2,saurzDF1("id")===saurzDF2("id"),"left\_outer")
saurzJoinDF4.show()

+---+------+---+----+-------+
| id|  name|age|  id|  skill|
+---+------+---+----+-------+
|101|sachin| 40| 101|batsman|
|102| zahir| 41| 102| bowler|
|103| virat| 29| 103|batsman|
|104|saurav| 41| 104|batsman|
|105| rohit| 30|null|   null|
+---+------+---+----+-------+

### Right Outer Join using Join Expressions

Similar to above , it performs RIGHT OUTER JOIN.

val saurzJoinDF5 = saurzDF1.join(saurzDF2,saurzDF1("id")===saurzDF2("id"),"right\_outer")
saurzJoinDF5.show()

+---+------+---+---+-------+
| id|  name|age| id|  skill|
+---+------+---+---+-------+
|101|sachin| 40|101|batsman|
|102| zahir| 41|102| bowler|
|103| virat| 29|103|batsman|
|104|saurav| 41|104|batsman|
+---+------+---+---+-------+

### Left Semi Join using Join Expressions

Similar to above, it performs LEFT SEMI JOIN. Please note the difference between LEFT SEMI JOIN and INNER JOIN here - LEFT SEMI JOIN , will do an inner join and only give columns from the left data frame, while INNER join will give columns from both the data frames.

val saurzJoinDF6= saurzDF1.join(saurzDF2,saurzDF1("id")===saurzDF2("id"),"leftsemi")
saurzJoinDF6.show()

+---+------+---+
| id|  name|age|
+---+------+---+
|101|sachin| 40|
|102| zahir| 41|
|103| virat| 29|
|104|saurav| 41|
+---+------+---+

In this post, we saw various types of JOIN operations that can be performed on data frames. Please also, check some interesting posts below - [How to Configure Spark Application ( Scala and Java 8 Version with Maven ) in Eclipse.](https://saurzcode.in/2017/10/configure-spark-application-eclipse/) 
[How to Use MultiThreadedMapper in MapReduce](https://saurzcode.in/2018/05/how-to-use-multithreadedmapper-in-mapreduce/) 
[What is RDD in Spark ? and Why do we need it?](https://saurzcode.in/2015/10/what-is-rdd-in-spark-and-why-do-we-need-it/)