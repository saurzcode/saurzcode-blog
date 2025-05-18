---
id: 1101
title: 'How to Configure Spark Application ( Scala and Java 8 Version with Maven ) in Eclipse.'
date: '2017-10-15T23:46:09-07:00'
author: saurzcode

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

# How to Configure Spark Application (Scala and Java 8 Version with Maven) in Eclipse

A step-by-step, developer-friendly guide to setting up Apache Spark applications in Eclipse/Scala IDE using Maven, with both Java and Scala examples.
<!--more-->
---

## Table of Contents

- [How to Configure Spark Application (Scala and Java 8 Version with Maven) in Eclipse](#how-to-configure-spark-application-scala-and-java-8-version-with-maven-in-eclipse)
	- [Table of Contents](#table-of-contents)
	- [Introduction](#introduction)
	- [Tools and Prerequisites](#tools-and-prerequisites)
	- [Windows Note: winutils.exe](#windows-note-winutilsexe)
	- [Creating a Sample Spark Application in Eclipse](#creating-a-sample-spark-application-in-eclipse)
		- [Maven Project Setup](#maven-project-setup)
		- [Java WordCount Example](#java-wordcount-example)
		- [Scala WordCount Example](#scala-wordcount-example)
	- [Running the Code in Eclipse](#running-the-code-in-eclipse)
	- [Output](#output)

---

## Introduction

Apache Spark is a popular big data processing engine known for its fast, in-memory computation. This guide will help you set up a Spark project in Eclipse (Scala IDE), configure Maven, and run sample Java and Scala Spark applications.

---

## Tools and Prerequisites

- **Scala IDE for Eclipse** ([Download](http://scala-ide.org/download/sdk.html))
    - Example: Scala IDE 4.7.0 (supports both Scala and Java)
- **Scala Version:** 2.11 (ensure your compiler matches this)
- **Spark Version:** 2.2 (set in Maven dependency)
- **Java Version:** 1.8
- **Maven Version:** 3.3.9 (embedded in Eclipse)
- **winutils.exe** (for Windows only)

---

## Windows Note: winutils.exe

If running on Windows, you need Hadoop binaries in Windows format. `winutils.exe` provides this functionality. Set the `hadoop.home.dir` system property to the `bin` path containing `winutils.exe`.

- [Download winutils.exe](http://public-repo-1.hortonworks.com/hdp-win-alpha/winutils.exe)
- Place it at: `C:/hadoop/bin/winutils.exe`
- See [this guide](/2019/09/running-spark-application-on-windows/) for more details.

---

## Creating a Sample Spark Application in Eclipse

### Maven Project Setup

1. In Scala IDE, create a new Maven Project.
2. Replace the generated `pom.xml` with the following:

```xml
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
```

---

### Java WordCount Example

Create a new Java class (e.g., `JavaWordCount`) and use the following code:

```java
package com.saurzcode.spark;

import java.util.Arrays;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import scala.Tuple2;

public class JavaWordCount {
	public static void main(String[] args) throws Exception {
		String inputFile = "src/main/resources/input.txt";
		// Set HADOOP_HOME for Windows
		System.setProperty("hadoop.home.dir", "c://hadoop//");
		// Initialize Spark Context
		JavaSparkContext sc = new JavaSparkContext(new SparkConf().setAppName("wordCount").setMaster("local[4]"));
		// Load data from Input File
		JavaRDD<String> input = sc.textFile(inputFile);
		// Split up into words and count
		JavaPairRDD<String, Integer> counts = input
			.flatMap(line -> Arrays.asList(line.split(" ")).iterator())
			.mapToPair(word -> new Tuple2<>(word, 1))
			.reduceByKey((a, b) -> a + b);
		System.out.println(counts.collect());
		sc.stop();
		sc.close();
	}
}
```

---

### Scala WordCount Example

Create a new Scala object (e.g., `ScalaWordCount`) and use the following code:

```scala
package com.saurzcode.spark

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

object ScalaWordCount {
	def main(args: Array[String]): Unit = {
		// Set HADOOP_HOME for Windows
		System.setProperty("hadoop.home.dir", "c://hadoop//")
		// Create Spark context
		val sc = new SparkContext(new SparkConf().setAppName("Spark WordCount").setMaster("local[4]"))
		// Load input file
		val inputFile = sc.textFile("src/main/resources/input.txt")
		val counts = inputFile
			.flatMap(line => line.split(" "))
			.map(word => (word, 1))
			.reduceByKey(_ + _)
		counts.foreach(println)
		sc.stop()
	}
}
```

> **Tip:** Make sure your project is set as a Scala project and the Scala compiler version matches the version in your Spark dependency. You can set this in the build path.

---

## Running the Code in Eclipse

- Run the Java or Scala code as a standard Java or Scala Application in Eclipse.
- You should see the word count output and Spark log lines in the console.

---

## Output

You should see output similar to:

```
(hello, 3)
(world, 2)
(example, 1)
...
```

---