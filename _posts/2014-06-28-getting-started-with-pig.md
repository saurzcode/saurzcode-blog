---
id: 602
title: 'Hadoop : Getting Started with Pig'
date: '2014-06-28T19:10:39-07:00'
author: saurzcode
layout: medium
guid: 'https://saurzcode.in//?p=602'
permalink: /2014/06/getting-started-with-pig/
geo_public:
    - '0'
publicize_google_plus_url:
    - 'https://plus.google.com/107786853692055665005/posts/NJHqX1sZur2'
publicize_linkedin_url:
    - 'http://www.linkedin.com/updates?discuss=&scope=23596248&stype=M&topic=5888646971744354304&type=U&a=g2pK'
meta-checkbox:
    - ''
dsq_thread_id:
    - '3494385908'
categories:
    - 'Big Data'
    - Java
    - Technology
tags:
    - 'big data'
    - hadoop
    - hdfs
    - Pig
    - 'Pig Latin'
---

## What is Apache Pig?

Apache Pig is a high level scripting language that is used with Apache Hadoop. It enables data analysts to write complex data transformations without knowing Java. Its simple SQL-like scripting language is called Pig Latin, and appeals to developers already familiar with scripting languages and SQL. Pig Scripts are converted into MapReduce Jobs which run on data stored in HDFS (refer to the diagram below).

Through the User Defined Functions (UDF) facility in Pig, it can invoke code in many languages like JRuby, Jython and Java. You can also embed Pig scripts in other languages. The result is that you can use it as a component to build larger and more complex applications that tackle real business problems.

## Architecture

[![Pig Architecture](assets/uploads/2014/06/pig-achitecture.jpg)](assets/uploads/2014/06/pig-achitecture.jpg)

## How It is being Used?

- Rapid prototyping of algorithms for processing large data sets.
- Data Processing for web search platforms.
- Ad Hoc queries across large data sets.
- Web log processing.

## Pig Elements

It consists of three elements:

- **Pig Latin**
  - High level scripting language
  - No Schema
  - Translated to MapReduce Jobs
- **Pig Grunt Shell**
  - Interactive shell for executing pig commands.
- **PiggyBank**
  - Shared repository for User defined functions (explained later).

**Pig Latin Statements**

Pig Latin statements are the basic constructs you use to process data using Pig. A Pig Latin statement is an operator that takes a relation as input and produces another relation as output (except LOAD and STORE statements).

Pig Latin statements are generally organized as follows:

- A LOAD statement to read data from the file system.
- A series of "transformation" statements to process the data.
- A DUMP statement to view results or a STORE statement to save the results.

Note that a DUMP or STORE statement is required to generate output.

- In this example Pig will validate, but not execute, the LOAD and FOREACH statements.

```pig
A = LOAD 'student' USING PigStorage() AS (name:chararray, age:int, gpa:float);
B = FOREACH A GENERATE name;
```

- In this example, Pig will validate and then execute the LOAD, FOREACH, and DUMP statements.

```pig
A = LOAD 'student' USING PigStorage() AS (name:chararray, age:int, gpa:float);
B = FOREACH A GENERATE name;
DUMP B;
(John)
(Mary)
(Bill)
(Joe)
```

## Storing Intermediate Results

Pig stores the intermediate data generated between MapReduce jobs in a temporary location on HDFS. This location must already exist on HDFS prior to use. This location can be configured using the `pig.temp.dir` property.

## Storing Final Results

Use the STORE operator and the load/store functions to write results to the file system (PigStorage is the default store function).

**Note:** During the testing/debugging phase of your implementation, you can use DUMP to display results to your terminal screen. However, in a production environment you always want to use the STORE operator to save your results.

## Debugging Pig Latin

Pig Latin provides operators that can help you debug your Pig Latin statements:

- Use the DUMP operator to display results to your terminal screen.
- Use the DESCRIBE operator to review the schema of a relation.
- Use the EXPLAIN operator to view the logical, physical, or map reduce execution plans to compute a relation.
- Use the ILLUSTRATE operator to view the step-by-step execution of a series of statements.

## What are Pig User Defined Functions (UDFs)?

Pig provides extensive support for user-defined functions (UDFs) as a way to specify custom processing. Functions can be a part of almost every operator in Pig. UDF is very powerful functionality to do many complex operations on data. The *Piggy Bank* is a place for users to share their functions (UDFs).

Example:

```pig
REGISTER saurzcodeUDF.jar;
A = LOAD 'employee_data' AS (name: chararray, age: int, designation: chararray);
B = FOREACH A GENERATE saurzcodeUDF.UPPER(name);
DUMP B;
```

I hope now you know some basic Pig Concepts already!

Happy Learning!!

**References:**

- [http://pig.apache.org](http://pig.apache.org)

---

### Related articles:

- *[Recommended readings for Hadoop](https://saurzcode.in//2014/02/04/recommended-readings-for-hadoop/)*
- *[Free Online Hadoop Trainings](https://saurzcode.in//2014/04/21/free-online-hadoop-trainings/)*
- *[How to become a Hadoop Certified Developer ?](https://saurzcode.in//2014/05/31/everything-about-hadoop-certifications/)*