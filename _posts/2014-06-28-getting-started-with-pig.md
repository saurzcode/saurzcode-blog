---
id: 602
title: 'Hadoop : Getting Started with Pig'
date: '2014-06-28T19:10:39-07:00'
author: saurzcode
layout: post
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

<h2 style="text-align: justify;">What is Apache Pig?</h2>
<p style="text-align: justify;">Apache Pig is a high level scripting language that is used with Apache Hadoop. It enables data analysts to write complex data transformations without knowing Java. It’s simple SQL-like scripting language is called Pig Latin, and appeals to developers already familiar with scripting languages and SQL.Pig Scripts are converted into MapReduce Jobs which runs on data stored in HDFS (refer to the diagram below).</p>
<p style="text-align: justify;">Through the User Defined Functions(UDF) facility in Pig, It can invoke code in many languages like JRuby, Jython and Java. You can also embed Pig scripts in other languages. The result is that you can use it as a component to build larger and more complex applications that tackle real business problems.</p>

<h2 style="text-align: justify;">Architecture</h2>
<p style="text-align: justify;"><a class="vt-p" href="https://saurzcode.in//wp-content/uploads/2014/06/pig-achitecture.jpg"><img class="aligncenter size-full wp-image-607" src="https://saurzcode.in//wp-content/uploads/2014/06/pig-achitecture.jpg" alt="Pig Achitecture" width="568" height="111" /></a></p>

<h2 style="text-align: justify;">How It is being Used ?</h2>
<ul style="text-align: justify;">
	<li>Rapid prototyping of algorithms for processing large data sets.</li>
	<li>Data Processing for web search platforms.</li>
	<li>Ad Hoc queries across large data sets.</li>
	<li>Web log processing.</li>
</ul>
<h2 style="text-align: justify;">Pig Elements</h2>
<p style="text-align: justify;">It consists of three elements -</p>

<ul style="text-align: justify;">
	<li><strong>Pig Latin</strong>
<ul>
	<li>High level scripting language</li>
	<li>No Schema</li>
	<li>Translated to MapReduce Jobs</li>
</ul>
</li>
	<li><strong>Pig Grunt Shell</strong>
<ul>
	<li>Interactive shell for executing pig commands.</li>
</ul>
</li>
	<li><strong>PiggyBank</strong>
<ul>
	<li>Shared repository for User defined functions (explained later).</li>
</ul>
</li>
</ul>
<p style="text-align: justify;"><strong>Pig Latin Statements </strong></p>
<p style="text-align: justify;">Pig Latin statements are the basic constructs you use to process data using Pig. A Pig Latin statement is an operator that takes a relation as input and produces another relation as output(except LOAD and STORE statements).</p>
<p style="text-align: justify;">Pig Latin statements are generally organized as follows:</p>

<ul style="text-align: justify;">
	<li>A LOAD statement to read data from the file system.</li>
	<li>A series of "transformation" statements to process the data.</li>
	<li>A DUMP statement to view results or a STORE statement to save the results.</li>
</ul>
<p style="text-align: justify;">Note that a DUMP or STORE statement is required to generate output.</p>

<ul style="text-align: justify;">
	<li>In this example Pig will validate, but not execute, the LOAD and FOREACH statements.
<pre class="code">A = LOAD 'student' USING PigStorage() AS (name:chararray, age:int, gpa:float);
B = FOREACH A GENERATE name;
</pre>
</li>
	<li>In this example, Pig will validate and then execute the LOAD, FOREACH, and DUMP statements.
<pre class="code">A = LOAD 'student' USING PigStorage() AS (name:chararray, age:int, gpa:float);
B = FOREACH A GENERATE name;
DUMP B;
(John)
(Mary)
(Bill)
(Joe)</pre>
</li>
</ul>
<h3 style="text-align: justify;">Storing Intermediate Results</h3>
<p style="text-align: justify;">Pig stores the intermediate data generated between MapReduce jobs in a temporary location on HDFS. This location must already exist on HDFS prior to use. This location can be configured using the <em>pig.temp.dir</em> property.</p>

<h3 style="text-align: justify;">Storing Final Results</h3>
<p style="text-align: justify;">Use the STORE operator and the load/store functions to write results to the file system ( PigStorage is the default store function).</p>
<p style="text-align: justify;"><strong>Note:</strong> During the testing/debugging phase of your implementation, you can use DUMP to display results to your terminal screen. However, in a production environment you always want to use the STORE operator to save your results.</p>

<h3 style="text-align: justify;">Debugging Pig Latin</h3>
<p style="text-align: justify;">Pig Latin provides operators that can help you debug your Pig Latin statements:</p>

<ul style="text-align: justify;">
	<li>Use the DUMP operator to display results to your terminal screen.</li>
	<li>Use the DESCRIBE operator to review the schema of a relation.</li>
	<li>Use the EXPLAIN operator to view the logical, physical, or map reduce execution plans to compute a relation.</li>
	<li>Use the ILLUSTRATE operator to view the step-by-step execution of a series of statements.</li>
</ul>
<h2 style="text-align: justify;">What are Pig User Defined Functions (UDFs) ?</h2>
<p style="text-align: justify;">Pig provides extensive support for user-defined functions (UDFs) as a way to specify custom processing. Functions can be a part of almost every operator in Pig. UDF is very powerful functionality to do many complex operations on data.The <em>Piggy Bank</em> is a place for users to share their functions(UDFs).</p>
<p style="text-align: justify;">Example:</p>

<pre class="code">REGISTER saurzcodeUDF.jar;
A = LOAD 'employee_data' AS (name: chararray, age: int, designation: chararray);
B = FOREACH A GENERATE saurzcodeUDF.UPPER(name);
DUMP B;</pre>
<p style="text-align: justify;">I hope now you know some basic Pig Concepts already !</p>
<p style="text-align: justify;">Happy Learning !!</p>
<p style="text-align: justify;"><strong>References</strong> :-</p>

<ul style="text-align: justify;">
	<li><a class="vt-p" href="http://pig.apache.org">http://pig.apache.org</a></li>
</ul>

<hr />

<h3 style="text-align: justify;"> Related articles :</h3>
<ul style="text-align: justify;">
	<li><em><a class="vt-p" title="Recommended Readings for Hadoop" href="https://saurzcode.in//2014/02/04/recommended-readings-for-hadoop/">Recommended readings for Hadoop</a></em></li>
	<li><em><a class="vt-p" title="Free Online Hadoop Trainings" href="https://saurzcode.in//2014/04/21/free-online-hadoop-trainings/">Free Online Hadoop Trainings</a></em></li>
	<li><em><a class="vt-p" title="How to Become a Hadoop Certified Developer ?" href="https://saurzcode.in//2014/05/31/everything-about-hadoop-certifications/">How to become a Hadoop Certified Developer ?</a></em></li>
</ul>