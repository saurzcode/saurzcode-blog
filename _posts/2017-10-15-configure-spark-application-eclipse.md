---
id: 1101
title: 'How to Configure Spark Application ( Scala and Java 8 Version with Maven ) in Eclipse.'
date: '2017-10-15T23:46:09-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in/?p=1101'
permalink: /2017/10/configure-spark-application-eclipse/
meta-checkbox:
    - ''
dsq_thread_id:
    - '6218159354'
categories:
    - 'Big Data'
    - Java
    - Scala
    - Spark
    - Technology
tags:
    - eclipse
    - java
    - java8
    - lambda
    - maven
    - scala
    - spark
---

![saurzcode-spark-eclipse](http://saurzcode.in/assets/uploads/2017/10/spark-logo.png) Apache Spark is becoming very popular among organizations looking to leverage its fast, in-memory computing capability for big-data processing. This article is for beginners to get started with Spark Setup on Eclipse/Scala IDE and getting familiar with Spark terminologies in general - Hope you have read the previous article on [RDD basics](https://saurzcode.in/2015/10/what-is-rdd-in-spark-and-why-do-we-need-it/), to get a basic understanding of Spark RDD.

#### Tools Used :

*   Scala IDE for Eclipse - Download the latest version of Scala IDE from [here](http://scala-ide.org/download/sdk.html). Here, I used Scala IDE 4.7.0 Release, which support both Scala and Java
*   Scala Version - 2.11 ( make sure scala compiler is set to this version as well)
*   Spark Version 2.2 ( provided in maven dependency)
*   Java Version 1.8
*   Maven Version 3.3.9 ( Embedded in Eclipse)
*   winutils.exe

> For running in Windows environment , you need hadoop binaries in windows format. winutils provides that and we need to set hadoop.home.dir system property to bin path inside which winutils.exe is present. You can download **winutils.exe** [here](http://public-repo-1.hortonworks.com/hdp-win-alpha/winutils.exe) and place at path like this - **c:/hadoop/bin/winutils.exe .** Read [this](https://saurzcode.in/2019/09/running-spark-application-on-windows/) for more information.

#### Creating a Sample Application in Eclipse -

In Scala IDE, create a new Maven Project - ![saurzcode-eclipse-spark](http://saurzcode.in/assets/uploads/2017/10/2.png) ![saurzcode-eclipse-spark](http://saurzcode.in/assets/uploads/2017/10/3.png) ![saurzcode-eclipse-spark](http://saurzcode.in/assets/uploads/2017/10/4.png) Replace POM.XML as below -

##### POM.XML

<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.saurzcode.spark</groupId>
	<artifactId>spark-app</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<dependencies>
		<dependency> <!-- Spark dependency -->
			<groupId>org.apache.spark</groupId>
			<artifactId>spark-core\_2.11</artifactId>
			<version>2.2.0</version>
			<scope>provided</scope>
		</dependency>
	</dependencies>
</project>

For creating a Java WordCount program, create a new Java Class and copy the code below -

#### Java Code for WordCount

package com.saurzcode.spark;

import java.util.Arrays; import org.apache.spark.SparkConf; import org.apache.spark.api.java.JavaPairRDD; import org.apache.spark.api.java.JavaRDD; import org.apache.spark.api.java.JavaSparkContext; import scala.Tuple2; public class JavaWordCount { public static void main(String\[\] args) throws Exception { String inputFile = "src/main/resources/input.txt"; //To set HADOOP\_HOME. System.setProperty("hadoop.home.dir", "c://hadoop//"); //Initialize Spark Context JavaSparkContext sc = new JavaSparkContext(new SparkConf().setAppName("wordCount").setMaster("local\[4\]")); // Load data from Input File. JavaRDD<String> input = sc.textFile(inputFile); // Split up into words. JavaPairRDD<String, Integer> counts = input.flatMap(line -> Arrays.asList(line.split(" ")).iterator()) .mapToPair(word -> new Tuple2<>(word, 1)).reduceByKey((a, b) -> a + b); System.out.println(counts.collect()); sc.stop(); sc.close(); } }

#### Scala Version

For running the Scala version of WordCount program in scala, create a new Scala Object and use the code below -

> You may need to set project as scala project to run this, and make sure scala compiler version matches Scala version in your Spark dependency, by setting in build path -
> 
> ![saurzcode-eclipse-spark](http://saurzcode.in/assets/uploads/2017/10/SparkVersion.png)

package com.saurzcode.spark

import org.apache.spark.SparkConf import org.apache.spark.SparkContext object ScalaWordCount { def main(args: Array\[String\]) { //To set HADOOP\_HOME. System.setProperty("hadoop.home.dir", "c://hadoop//"); // create Spark context with Spark configuration val sc = new SparkContext(new SparkConf().setAppName("Spark WordCount").setMaster("local\[4\]")) //Load inputFile val inputFile = sc.textFile("src/main/resources/input.txt") val counts = inputFile.flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey((a, b) => a + b) counts.foreach(println) sc.stop() } } So, your final setup will look like this - ![saurzcode-eclipse-spark](http://saurzcode.in/assets/uploads/2017/10/eclipse.png)

#### Running the code in Eclipse

You can run the above code in Scala or Java as simple Run As Scala or Java Application in eclipse to see the output.

#### Output

Now you should be able to see the word count output, along with log lines generated using default Spark log4j properties. ![saurzcode-eclipse-spark](http://saurzcode.in/assets/uploads/2017/10/output.png) In the next post, I will explain how you can open Spark WebUI and look at various stages, tasks on Spark code execution internally. You may also be interested in some other BigData posts -

*   [Concept of RDDs in Spark](https://saurzcode.in//2015/10/what-is-rdd-in-spark-and-why-do-we-need-it/)
*   [Getting started with MapReduce development](https://saurzcode.in//2015/01/setup-development-environment-hadoop-mapreduce/)
*   [Top 20 BigData Books](https://saurzcode.in//2014/06/top-20-hadoop-bigdatabooks/)
*   [Spark Dataframe Operations - Part I](https://saurzcode.in/2018/06/spark-common-dataframe-operations/)
*   Spark ; How to Run Spark Applications on Windows