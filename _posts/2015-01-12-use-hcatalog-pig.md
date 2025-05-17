---
id: 820
title: 'How-To : Use HCatalog with Pig'
date: '2015-01-12T14:06:25-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in//?p=820'
permalink: /2015/01/use-hcatalog-pig/
meta-checkbox:
    - ''
dsq_thread_id:
    - '3487091424'
categories:
    - 'Big Data'
    - Hive
    - Java
    - Technology
tags:
    - hadoop
    - hcatalog
    - hive
    - Pig
---

<h1> Using HCatalog with Pig :-</h1>
This post is a step by step guide on running HCatalog and using HCatalog with Apache Pig :-

<strong>Assumptions</strong> :

Pig and Hive are installed and tested with basic modes.

It requires Hive Metastore and it's databse to be properly configured ( Refer to <a class="vt-p" title="How to Configure MySQL Metastore for Hive ?" href="https://saurzcode.in//2015/01/configure-mysql-metastore-hive/">Post </a>)<!--more-->

<strong>Versions Tested With :- </strong>

HCatalog comes with Hive installation (0.11+) itself under folder $HIVE_HOME/hcatalog

Hive Version : 0.14 and above ( might work with version below this)

Pig Version : 0.14 and above (might work with version below this)

Let's start with the configuration  -

<strong>Step 1</strong> : Assuming HADOOP_HOME  is properly configured , let's set up HCAT_HOME and PIG_CLASSPATH ( so that pig can know what jars needs to used for accessing Hcatalog Storage)  : -
<pre class="lang:vim decode:true">export HIVE_HOME=/usr/local/hive
export HCAT_HOME=/usr/local/hive/hcatalog
export PIG_HOME=/usr/local/pig
export PATH=$PATH:$HCAT_HOME/bin
export PATH=$PATH:$PIG_HOME/bin
export PIG_CLASSPATH=$HCAT_HOME/share/hcatalog/hive-hcatalog-core*.jar:\
$HCAT_HOME/share/hcatalog/ hive-hcatalog-pig-adapter*.jar:\
$HIVE_HOME/lib/hive-metastore-*.jar:$HIVE_HOME/lib/libthrift-*.jar:\
$HIVE_HOME/lib/hive-exec-*.jar:$HIVE_HOME/lib/libfb303-*.jar:\
$HIVE_HOME/lib/jdo2-api-*-ec.jar:$HIVE_HOME/conf:$HADOOP_HOME/conf:\
$HIVE_HOME/lib/slf4j-api-*.jar

</pre>
&nbsp;

<strong>Step 2</strong> : It is required that Hive metastore should be running in remote mode so that MetaStore client knows where is the metastore -

in $HIVE_HOME/conf/hive-site.xml -

Add or edit the hive.metastore.uris property as follows:
<pre class="lang:xhtml decode:true">&lt;property&gt;
  &lt;name&gt;hive.metastore.uris&lt;/name&gt;
  &lt;value&gt;thrift://&lt;hostname&gt;:9083&lt;/value&gt;
&lt;/property&gt;</pre>
And, run
<pre class="lang:java decode:true">$ hive --service metastore &amp;</pre>
and test if it is running through
<pre class="lang:vim decode:true">$ netstat -an | grep 9083</pre>
&nbsp;

<strong>Step 3</strong> : Create a table using hcat -
<pre class="pre codeblock "># Create a table
$ hcat -e "create table hcatalogtest(name string,place string,id int) row format delimited fields terminated by ':' stored as textfile"
OK

# Get the schema for a table
$ hcat -e "desc hcatalogtest"
OK
name	string	
place	string	
id	int	
</pre>
<strong>Step 4</strong> : Connecting Pig to Hcatalog : -
<ul>
	<li>Create a pig script named hcatalogtest.pig
<pre class="lang:mysql decode:true">A = LOAD 'hcatalogtest' USING org.apache.hive.hcatalog.pig.HCatLoader(); 
DESCRIBE A;</pre>
Note : Please note that  <strong>org.apache.hive.hcatalog.pig.HCatLoader </strong>is used and not org.apache.hcatalog.pig.HCatLoader ( which you will find in most of the illustrations available)</li>
	<li>Run Pig script using flag -useHCatalog
<pre class="lang:mysql decode:true ">pig -useHCatalog hcatalogtest.pig</pre>
This should give you the schema of the table  as output  :-
<pre class="lang:js decode:true ">A: {name: chararray,placeholder: chararray,id: int}
</pre>
&nbsp;</li>
</ul>
That's it  !! You are all set with a basic HCatalog configuration up and running and integrated with Pig.