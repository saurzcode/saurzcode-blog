---
id: 842
title: 'How-to : Write a CoProcessor in HBase'
date: '2015-01-27T18:06:55-07:00'
author: saurzcode

guid: 'https://saurzcode.in//?p=842'
permalink: /2015/01/write-coprocessor-hbase/
meta-checkbox:
    - ''
dsq_thread_id:
    - '3505620384'
categories:
    - 'Big Data'
    - HBase
    - Technology
tags:
    - coprocessor
    - hadoop
    - hbase
    - hdfs
---
# What is Coprocessor in HBase?

Coprocessor is a mechanism which helps to move computations closer to the data in HBase. It is like a Mapreduce framework to distribute tasks across the cluster.
<!--more-->
You can think of them like either Aspects in Java where it intercepts code before and after some critical operations and executes some user supplied behavior or Triggers or Stored Procedures in RDBMS which gets executed at run time and near to the data.

Coprocessor functionality helps to run a custom code directly on the region server which gives following benefits:

- Coprocessor executes the code on Per-Region basis, and gives a RDBMS trigger and stored procedures like functionality (we will see in a bit, how?)
- It can help to execute aggregation tasks like sum(), count() etc on each region server basis and then return the aggregated result, which is a huge performance benefit.
- It is helpful to implement Authorization and Authentication mechanism in HBase.

## **How to Implement it?**

Either your class should extend one of the Coprocessor classes (like BaseRegionObserver) or it should implement Coprocessor interfaces (like Coprocessor, CoprocessorService).

## **Loading the Coprocessor**

Currently there are two ways to load the Coprocessor:

- Static Loading - Loading from configuration at startup.
- Dynamic Loading - Loading through HTableDescriptor either through Java code or through 'hbase shell'.

Let's see client-side code to call the Coprocessor with the static loading technique. This is the easiest step, as HBase handles the Coprocessor transparently and you don't have to do much to call the Coprocessor.

We are trying to intercept the calls to get rows with a specific key called "TEST_COPROCESSOR", and whenever we encounter get for that particular row, we will replace value of the column family ***name*** and column ***first*** with ***"saurzcode"***. Let's see it in action:

Create a maven project with dependency:

```xml
<dependency>
    <groupId>org.apache.hbase</groupId>
    <artifactId>hbase-server</artifactId>
    <version>0.98.9-hadoop2</version>
</dependency>
```

```java
package com.saurzcode.coprocessor;
import java.io.IOException;
import java.util.List;

import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.KeyValue;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.coprocessor.BaseRegionObserver;
import org.apache.hadoop.hbase.coprocessor.ObserverContext;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessorEnvironment;
import org.apache.hadoop.hbase.util.Bytes;

public class HBaseCoprocessor extends BaseRegionObserver {
    
    @Override
    public void preGetOp(final ObserverContext<RegionCoprocessorEnvironment> e,
        final Get get, final List<Cell> results) throws IOException {
        
        if(Bytes.equals(get.getRow(), Bytes.toBytes("TEST_COPROCESSOR"))){
            
            KeyValue kv = new KeyValue(get.getRow(),Bytes.toBytes("name"),Bytes.toBytes("first"),Bytes.toBytes("saurzcode"));
            results.add(kv);
            
        }
    }
}
```

Create a jar with above coprocessor code using *mvn package* and add the class in *hbase-site.xml* as under and jar to HBASE classpath.

***hbase-site.xml***
```xml
<property>
<name>hbase.coprocessor.region.classes</name>
<value>com.saurzcode.coprocessor.HBaseCoprocessor</value>
</property>
```

and

```sh
HBASE_CLASSPATH=path-to/<jar>
```

Restart hbase so that configuration is in classpath:

```sh
$ stop-hbase.sh

$ start-hbase.sh
```

```sh
hbase(main):003:0> get 'test','TEST_COPROCESSOR'
COLUMN               CELL                                                      
 name:first      timestamp=9223372036854775807, value=saurzcode                    
1 row(s) in 0.0210 seconds
```

That's it!! We have successfully created a CoProcessor that intercepts calls to get for a particular row.
