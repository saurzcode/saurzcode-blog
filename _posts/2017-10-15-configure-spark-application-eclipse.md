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

<img class="alignleft wp-image-1160" src="http://saurzcode.in/wp-content/uploads/2017/10/spark-logo.png" alt="saurzcode-spark-eclipse" width="133" height="103" />

Apache Spark is becoming very popular among organizations looking to leverage its fast, in-memory computing capability for big-data processing. This article is for beginners to get started with Spark Setup on Eclipse/Scala IDE and getting familiar with Spark terminologies in general -

Hope you have read the previous article on <a href="https://saurzcode.in/2015/10/what-is-rdd-in-spark-and-why-do-we-need-it/">RDD basics</a>, to get a basic understanding of Spark RDD.
<h4>Tools Used :</h4>
<ul>
 	<li>Scala IDE for Eclipse - Download the latest version of Scala IDE from <a style="font-size: 1em;" href="http://scala-ide.org/download/sdk.html">here</a>. Here<span style="font-size: 1em;">, I used Scala IDE 4.7.0 Release, which support both Scala and Java</span></li>
 	<li>Scala Version - 2.11 ( make sure scala compiler is set to this version as well)</li>
 	<li>Spark Version 2.2 ( provided in maven dependency)</li>
 	<li>Java Version 1.8</li>
 	<li>Maven Version 3.3.9 ( Embedded in Eclipse)</li>
 	<li>winutils.exe</li>
</ul>
<!--more-->
<blockquote><span style="color: #800000;">For running in Windows environment , you need hadoop binaries in windows format. winutils provides that and we need to set hadoop.home.dir system property to bin path inside which winutils.exe is present. You can download <b>winutils.exe</b> <a href="http://public-repo-1.hortonworks.com/hdp-win-alpha/winutils.exe">here </a>and place at path like this - <b>c:/hadoop/bin/winutils.exe .</b><span style="color: #993366;"> Read <a href="https://saurzcode.in/2019/09/running-spark-application-on-windows/">this</a> for more information.</span></span></blockquote>
<h4>Creating a Sample Application in Eclipse -</h4>
In Scala IDE, create a new Maven Project -

<img class="aligncenter wp-image-1139" src="http://saurzcode.in/wp-content/uploads/2017/10/2.png" alt="saurzcode-eclipse-spark" width="330" height="302" />

<img class="aligncenter wp-image-1140" src="http://saurzcode.in/wp-content/uploads/2017/10/3.png" alt="saurzcode-eclipse-spark" width="330" height="298" />

<img class="aligncenter wp-image-1141" src="http://saurzcode.in/wp-content/uploads/2017/10/4.png" alt="saurzcode-eclipse-spark" width="334" height="300" />

Replace POM.XML as below -
<h5>POM.XML</h5>
<pre class="lang:xhtml decode:true">&lt;project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd"&gt;
	&lt;modelVersion&gt;4.0.0&lt;/modelVersion&gt;
	&lt;groupId&gt;com.saurzcode.spark&lt;/groupId&gt;
	&lt;artifactId&gt;spark-app&lt;/artifactId&gt;
	&lt;version&gt;0.0.1-SNAPSHOT&lt;/version&gt;
	&lt;dependencies&gt;
		&lt;dependency&gt; &lt;!-- Spark dependency --&gt;
			&lt;groupId&gt;org.apache.spark&lt;/groupId&gt;
			&lt;artifactId&gt;spark-core_2.11&lt;/artifactId&gt;
			&lt;version&gt;2.2.0&lt;/version&gt;
			&lt;scope&gt;provided&lt;/scope&gt;
		&lt;/dependency&gt;
	&lt;/dependencies&gt;
&lt;/project&gt;</pre>
For creating a Java WordCount program, create a new Java Class and copy the code below -
<h4>Java Code for WordCount</h4>
<pre class="lang:java decode:true">package com.saurzcode.spark;</pre>
import java.util.Arrays;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;

import scala.Tuple2;

public class JavaWordCount {
public static void main(String[] args) throws Exception {

String inputFile = "src/main/resources/input.txt";

//To set HADOOP_HOME.
System.setProperty("hadoop.home.dir", "c://hadoop//");

//Initialize Spark Context
JavaSparkContext sc = new JavaSparkContext(new SparkConf().setAppName("wordCount").setMaster("local[4]"));

// Load data from Input File.
JavaRDD&lt;String&gt; input = sc.textFile(inputFile);

// Split up into words.
JavaPairRDD&lt;String, Integer&gt; counts = input.flatMap(line -&gt; Arrays.asList(line.split(" ")).iterator())
.mapToPair(word -&gt; new Tuple2&lt;&gt;(word, 1)).reduceByKey((a, b) -&gt; a + b);

System.out.println(counts.collect());

sc.stop();
sc.close();
}
}
<h4>Scala Version</h4>
For running the Scala version of WordCount program in scala, create a new Scala Object and use the code below -
<blockquote>
<p class=""><span style="color: #800000;">You may need to set project as scala project to run this, and make sure scala compiler version matches Scala version in your Spark dependency, by setting in build path -</span></p>
<img class="aligncenter wp-image-1142" src="http://saurzcode.in/wp-content/uploads/2017/10/SparkVersion.png" alt="saurzcode-eclipse-spark" width="422" height="283" /></blockquote>
<pre class="lang:scala decode:true">package com.saurzcode.spark</pre>
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

object ScalaWordCount {

def main(args: Array[String]) {

//To set HADOOP_HOME.
System.setProperty("hadoop.home.dir", "c://hadoop//");
// create Spark context with Spark configuration
val sc = new SparkContext(new SparkConf().setAppName("Spark WordCount").setMaster("local[4]"))

//Load inputFile
val inputFile = sc.textFile("src/main/resources/input.txt")
val counts = inputFile.flatMap(line =&gt; line.split(" ")).map(word =&gt; (word, 1)).reduceByKey((a, b) =&gt; a + b)
counts.foreach(println)

sc.stop()
}

}

So, your final setup will look like this -

<img class="aligncenter wp-image-1166 size-full" src="http://saurzcode.in/wp-content/uploads/2017/10/eclipse.png" alt="saurzcode-eclipse-spark" width="1444" height="394" />
<h4>Running the code in Eclipse</h4>
You can run the above code in Scala or Java as simple Run As Scala or Java Application in eclipse to see the output.
<h4>Output</h4>
Now you should be able to see the word count output, along with log lines generated using default Spark log4j properties.

<img class="aligncenter wp-image-1165 size-full" src="http://saurzcode.in/wp-content/uploads/2017/10/output.png" alt="saurzcode-eclipse-spark" width="1346" height="691" />

In the next post, I will explain how you can open Spark WebUI and look at various stages, tasks on Spark code execution internally.

You may also be interested in some other BigData posts -
<ul>
 	<li><a href="https://saurzcode.in//2015/10/what-is-rdd-in-spark-and-why-do-we-need-it/" target="_blank" rel="noopener noreferrer">Concept of RDDs in Spark</a></li>
 	<li><a href="https://saurzcode.in//2015/01/setup-development-environment-hadoop-mapreduce/" target="_blank" rel="noopener noreferrer">Getting started with MapReduce development</a></li>
 	<li><a href="https://saurzcode.in//2014/06/top-20-hadoop-bigdatabooks/" target="_blank" rel="noopener noreferrer">Top 20 BigData Books</a></li>
 	<li><a href="https://saurzcode.in/2018/06/spark-common-dataframe-operations/">Spark Dataframe Operations - Part I</a></li>
 	<li>Spark ; How to Run Spark Applications on Windows</li>
</ul>