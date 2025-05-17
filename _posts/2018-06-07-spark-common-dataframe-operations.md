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
image: /wp-content/uploads/2017/10/spark-logo.png
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

Dataframe in Apache Spark is a distributed collection of data, organized in the form of columns. Dataframes can be transformed into various forms using DSL operations defined in <a href="https://spark.apache.org/docs/1.6.1/api/scala/index.html#org.apache.spark.sql.DataFrame" target="_blank" rel="noopener">Dataframes API</a>, and its various functions.

In this post, let's understand various join operations, that are regularly used while working with Dataframes -

<!--more-->

To understand these operations lets create a set of dataframes -
<pre class="lang:scala decode:true">val saurzDF1 = Seq(
(101, "sachin",40),
(102, "zahir",41),
(103, "virat",29),
(104, "saurav",41),
(105,"rohit",30)
).toDF("id", "name","age")</pre>
<pre class="lang:scala decode:true">saurzDF1: org.apache.spark.sql.DataFrame = [id: int, name: string, age: int]


saurzDF1.show()


+---+------+---+
| id| name|age|
+---+------+---+
|101|sachin| 40|
|102| zahir| 41|
|103| virat| 29|
|104|saurav| 41|
|105| rohit| 30|
+---+------+---+</pre>
<pre class="lang:scala decode:true">val saurzDF2 = Seq(
(101, "batsman"),
(102, "bowler"),
(103, "batsman"),
(104, "batsman")
).toDF("id", "skill")


saurzDF2: org.apache.spark.sql.DataFrame = [id: int, skill: string]

saurzDF2.show()

+---+-------+
| id| skill|
+---+-------+
|101|batsman|
|102| bowler|
|103|batsman|
|104|batsman|
+---+-------+

</pre>
<pre class="lang:scala decode:true">val saurzDF3 = Seq(
  (101, "sachin",100),
  (103, "virat",50),
  (104,  "saurav",45),
  (105,"rohit",35)
).toDF("id", "name","centuries")

saurzDF3: org.apache.spark.sql.DataFrame = [id: int, name: string, centuries: int]

saurzDF3.show()

+---+------+---------+
| id|  name|centuries|
+---+------+---------+
|101|sachin|      100|
|103| virat|       50|
|104|saurav|       45|
|105| rohit|       35|
+---+------+---------+</pre>

<hr />

Now our dataframes are ready , lets try out some operations -
<h2>JOIN Operations on Dataframe</h2>
<h3>Cartesion Join</h3>
This join is very expensive to perform as it creates (m*n) combination of rows , where m is number of rows in DF1 and n is number of rows in DF2.
<pre class="lang:scala decode:true">val saurzJoinDF1 = saurzDF1.join(saurzDF2)
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
+---+------+---+---+-------+</pre>
<h3>Inner Join Using Column</h3>
This join behaves exactly like INNER join in SQL and in the result, join column will appear exactly once.
<pre class="lang:scala decode:true">val saurzJoinDF2 = saurzDF1.join(saurzDF2,"id")
saurzJoinDF2.show()

+---+------+---+-------+
| id|  name|age|  skill|
+---+------+---+-------+
|101|sachin| 40|batsman|
|102| zahir| 41| bowler|
|103| virat| 29|batsman|
|104|saurav| 41|batsman|
+---+------+---+-------+</pre>
<h3>Inner Join using Sequence of Columns</h3>
This is also equivalent to SQL INNER Join, but using a sequence of columns, and join columns will appear exactly once.
<pre class="lang:scala decode:true">val saurzJoinDF8= saurzDF1.join(saurzDF3,Seq("id", "name"))
saurzJoinDF8.show()

+---+------+---+---------+
| id|  name|age|centuries|
+---+------+---+---------+
|101|sachin| 40|      100|
|103| virat| 29|       50|
|104|saurav| 41|       45|
|105| rohit| 30|       35|
+---+------+---+---------+</pre>
<h3>Left Outer Join Using Sequence of columns</h3>
This is also equivalent to SQL LEFT OUTER Join, but using a sequence of columns, and join columns will appear exactly once.
<pre class="lang:scala decode:true">val saurzJoinDF9= saurzDF1.join(saurzDF3,Seq("id", "name"),"left_outer")
saurzJoinDF9.show()

+---+------+---+---------+
| id|  name|age|centuries|
+---+------+---+---------+
|101|sachin| 40|      100|
|102| zahir| 41|     null|
|103| virat| 29|       50|
|104|saurav| 41|       45|
|105| rohit| 30|       35|
+---+------+---+---------+</pre>
<h3>Left Semi Join using Sequence of Columns</h3>
This is also equivalent to SQL LEFT SEMI Join, and the output contains only columns from left data frame.
<pre class="lang:scala decode:true">val saurzJoinDF10= saurzDF1.join(saurzDF3,Seq("id", "name"),"leftsemi")
saurzJoinDF10.show()

+---+------+---+
| id|  name|age|
+---+------+---+
|101|sachin| 40|
|103| virat| 29|
|104|saurav| 41|
|105| rohit| 30|
+---+------+---+</pre>
<h3>Outer Join Using Sequence of Columns</h3>
This is also equivalent to SQL OUTER Join, but using a sequence of columns, and join columns will appear exactly once.
<pre class="lang:scala decode:true">val saurzJoinDF11= saurzDF1.join(saurzDF3,Seq("id", "name"),"outer")
saurzJoinDF11.show()

+---+------+---+---------+
| id|  name|age|centuries|
+---+------+---+---------+
|104|saurav| 41|       45|
|103| virat| 29|       50|
|101|sachin| 40|      100|
|102| zahir| 41|     null|
|105| rohit| 30|       35|
+---+------+---+---------+</pre>
<h3>Right Outer Join Using Sequence of Columns</h3>
This is also equivalent to SQL RIGHT OUTER JOIN, but using a sequence of columns, and join columns will appear exactly once.
<pre class="lang:scala decode:true">val saurzJoinDF12= saurzDF1.join(saurzDF3,Seq("id", "name"),"right_outer")
saurzJoinDF12.show()

+---+------+---+---------+
| id|  name|age|centuries|
+---+------+---+---------+
|101|sachin| 40|      100|
|103| virat| 29|       50|
|104|saurav| 41|       45|
|105| rohit| 30|       35|
+---+------+---+---------+</pre>
<h3>Inner join Using Join Expressions</h3>
It performs INNER join operation using a join expression. Joins using expressions, produce join columns from both data frames and it is required to explicitly select the columns from output or the undesired column can be dropped later.
<pre class="lang:scala decode:true">val saurzJoinDF7= saurzDF1.join(saurzDF2,saurzDF1("id")===saurzDF2("id"),"inner")
saurzJoinDF7.show()

+---+------+---+---+-------+
| id|  name|age| id|  skill|
+---+------+---+---+-------+
|101|sachin| 40|101|batsman|
|102| zahir| 41|102| bowler|
|103| virat| 29|103|batsman|
|104|saurav| 41|104|batsman|
+---+------+---+---+-------+</pre>
<h3>Outer Join Using Join Expressions</h3>
Similar to above, it performs  OUTER JOIN.
<pre class="lang:scala decode:true">val saurzJoinDF3 = saurzDF1.join(saurzDF2,saurzDF1("id")===saurzDF2("id"),"outer")
saurzJoinDF3.show()

+---+------+---+----+-------+
| id|  name|age|  id|  skill|
+---+------+---+----+-------+
|101|sachin| 40| 101|batsman|
|102| zahir| 41| 102| bowler|
|103| virat| 29| 103|batsman|
|104|saurav| 41| 104|batsman|
|105| rohit| 30|null|   null|
+---+------+---+----+-------+</pre>
<h3>Left Outer Join using Join Expressions</h3>
Similar to above, it performs LEFT OUTER JOIN.
<pre class="lang:scala decode:true ">val saurzJoinDF4 = saurzDF1.join(saurzDF2,saurzDF1("id")===saurzDF2("id"),"left_outer")
saurzJoinDF4.show()

+---+------+---+----+-------+
| id|  name|age|  id|  skill|
+---+------+---+----+-------+
|101|sachin| 40| 101|batsman|
|102| zahir| 41| 102| bowler|
|103| virat| 29| 103|batsman|
|104|saurav| 41| 104|batsman|
|105| rohit| 30|null|   null|
+---+------+---+----+-------+</pre>
<h3>Right Outer Join using Join Expressions</h3>
Similar to above , it performs RIGHT OUTER JOIN.
<pre class="lang:scala decode:true">val saurzJoinDF5 = saurzDF1.join(saurzDF2,saurzDF1("id")===saurzDF2("id"),"right_outer")
saurzJoinDF5.show()

+---+------+---+---+-------+
| id|  name|age| id|  skill|
+---+------+---+---+-------+
|101|sachin| 40|101|batsman|
|102| zahir| 41|102| bowler|
|103| virat| 29|103|batsman|
|104|saurav| 41|104|batsman|
+---+------+---+---+-------+</pre>
<h3>Left Semi Join using Join Expressions</h3>
Similar to above, it performs LEFT SEMI JOIN. Please note the difference between LEFT SEMI JOIN and INNER JOIN here - LEFT SEMI JOIN , will do an inner join and only give columns from the left data frame, while INNER join will give columns from both the data frames.
<pre class="lang:scala decode:true">val saurzJoinDF6= saurzDF1.join(saurzDF2,saurzDF1("id")===saurzDF2("id"),"leftsemi")
saurzJoinDF6.show()

+---+------+---+
| id|  name|age|
+---+------+---+
|101|sachin| 40|
|102| zahir| 41|
|103| virat| 29|
|104|saurav| 41|
+---+------+---+</pre>
In this post, we saw various types of JOIN operations that can be performed on data frames.

Please also, check some interesting posts below -

<a href="https://saurzcode.in/2017/10/configure-spark-application-eclipse/">How to Configure Spark Application ( Scala and Java 8 Version with Maven ) in Eclipse.</a>

<a href="https://saurzcode.in/2018/05/how-to-use-multithreadedmapper-in-mapreduce/">How to Use MultiThreadedMapper in MapReduce</a>

<a href="https://saurzcode.in/2015/10/what-is-rdd-in-spark-and-why-do-we-need-it/">What is RDD in Spark ? and Why do we need it?</a>