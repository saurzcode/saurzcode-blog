---
id: 820
title: 'How-To : Use HCatalog with Pig'
date: '2015-01-12T14:06:25-07:00'
author: saurzcode

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

# Using HCatalog with Pig

This post is a step by step guide on running HCatalog and using HCatalog with Apache Pig:
<!--more-->
**Assumptions:**

Pig and Hive are installed and tested with basic modes.

It requires Hive Metastore and its database to be properly configured (Refer to [How to Configure MySQL Metastore for Hive?](https://saurzcode.in//2015/01/configure-mysql-metastore-hive/))

**Versions Tested With:**

- HCatalog comes with Hive installation (0.11+) itself under folder `$HIVE_HOME/hcatalog`
- Hive Version: 0.14 and above (might work with version below this)
- Pig Version: 0.14 and above (might work with version below this)

Let's start with the configuration:

## Step 1
Assuming `HADOOP_HOME` is properly configured, let's set up `HCAT_HOME` and `PIG_CLASSPATH` (so that pig can know what jars need to be used for accessing Hcatalog Storage):

```sh
export HIVE_HOME=/usr/local/hive
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
```

## Step 2
It is required that Hive metastore should be running in remote mode so that MetaStore client knows where is the metastore -

In `$HIVE_HOME/conf/hive-site.xml`:

Add or edit the `hive.metastore.uris` property as follows:

```xml
<property>
  <name>hive.metastore.uris</name>
  <value>thrift://<hostname>:9083</value>
</property>
```

And, run:

```sh
$ hive --service metastore &
```

and test if it is running through:

```sh
$ netstat -an | grep 9083
```

## Step 3
Create a table using hcat:

```sh
# Create a table
$ hcat -e "create table hcatalogtest(name string,place string,id int) row format delimited fields terminated by ':' stored as textfile"
OK

# Get the schema for a table
$ hcat -e "desc hcatalogtest"
OK
name	string	
place	string	
id	int	
```

## Step 4
Connecting Pig to Hcatalog:

- Create a pig script named `hcatalogtest.pig`:

```pig
A = LOAD 'hcatalogtest' USING org.apache.hive.hcatalog.pig.HCatLoader(); 
DESCRIBE A;
```

Note: Please note that `org.apache.hive.hcatalog.pig.HCatLoader` is used and not `org.apache.hcatalog.pig.HCatLoader` (which you will find in most of the illustrations available).

- Run Pig script using flag `-useHCatalog`:

```sh
pig -useHCatalog hcatalogtest.pig
```

This should give you the schema of the table as output:

```text
A: {name: chararray,placeholder: chararray,id: int}
```

That's it! You are all set with a basic HCatalog configuration up and running and integrated with Pig.