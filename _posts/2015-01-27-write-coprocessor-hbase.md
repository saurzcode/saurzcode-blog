---
id: 842
title: 'How-to : Write a CoProcessor in HBase'
date: '2015-01-27T18:06:55-07:00'
author: saurzcode
layout: post
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

<h2>What is Coprocessor in HBase ?</h2>
Coprocessor is a mechanism which helps to move computations closer to the data in HBase. It is like a Mapreduce framework to distribute tasks across the cluster.<img class="alignright size-full wp-image-870" src="https://saurzcode.in//wp-content/uploads/2015/01/hbase_logo.png" alt="hbase_logo" width="267" height="66" />

You can think of them like either Aspects in Java  where it intercepts code before and after some critical operations and executes some user supplied behavior or Triggers or Stored Procedures in RDBMS which gets executed at run time and near to the data.

<!--more-->Coprocessor functionality helps to run a custom code directly on the region server which gives following benefits -
<ul>
	<li>Coprocessor executes the code on Per-Region basis , and gives a RDBMS trigger and stored procedures like functionality ( we will see in a bit, how ? )</li>
	<li>It can help to execute aggregation tasks like sum() , count() etc on each region server basis and then return the aggregated result, which is a huge performance benefit.</li>
	<li>It is helpful to implement Authorization and Authentication mechanism in HBase.</li>
</ul>
<h3><strong>How to Implement it?</strong></h3>
Either your class should extend one of the Coprocessor classes (like BaseRegionObserver) or it should implement Coprocessor interfaces (like Coprocessor, CoprocessorService).
<h3><strong>Loading  the Coprocessor </strong></h3>
Currently there are two ways to load the Coprocessor.
<ul>
	<li>Static Loading - Loading from configuration at startup.</li>
	<li>Dynamic Loading - Loading through HTableDescriptor either through Java code or through ‘hbase shell’).</li>
</ul>
Let's see client-side code to call the Coprocessor with the static loading technique. This is the easiest step, as HBase handles the Coprocessor transparently and you don’t have to do much to call the Coprocessor.

We are trying to intercept the calls to get rows with a specific key called "TEST_COPROCESSOR" , and whenever we encounter get for that particular row, we will replace value of the column family <em><strong>name</strong> </em>and column <em><strong>first</strong></em> with<em><strong> "saurzcode"</strong></em>. Let's see it in action -

Create a maven project with dependency -
<pre class="lang:xhtml decode:true ">&lt;dependency&gt;
	&lt;groupId&gt;org.apache.hbase&lt;/groupId&gt;
	&lt;artifactId&gt;hbase-server&lt;/artifactId&gt;
	&lt;version&gt;0.98.9-hadoop2&lt;/version&gt;
&lt;/dependency&gt;
</pre>
&nbsp;
<pre class="lang:java decode:true">package com.saurzcode.coprocessor;
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
	  public void preGetOp(final ObserverContext&lt;RegionCoprocessorEnvironment&gt; e,
	      final Get get, final List&lt;Cell&gt; results) throws IOException {
		  
		  if(Bytes.equals(get.getRow(), Bytes.toBytes("TEST_COPROCESSOR"))){
			  
			  KeyValue kv = new KeyValue(get.getRow(),Bytes.toBytes("name"),Bytes.toBytes("first"),Bytes.toBytes("saurzcode"));
			  results.add(kv);
			  
		  }
	  }
}
</pre>
&nbsp;

Create a jar with above coprocessor code using <em>mvn package</em> and add the class in <em>hbase-site.xml</em> as under and jar to HBASE classpath.

<strong><em>hbase-site.xml</em></strong>
<pre class="lang:xhtml decode:true">&lt;property&gt;
&lt;name&gt;hbase.coprocessor.region.classes&lt;/name&gt;
&lt;value&gt;com.saurzcode.coprocessor.HBaseCoprocessor&lt;/value&gt;
&lt;/property&gt;
</pre>
and
<pre class="lang:vim decode:true">HBASE_CLASSPATH=path-to/&lt;jar&gt;</pre>
Restart hbase so that configuration is in classpath -
<pre class="lang:vim decode:true">$ stop-hbase.sh

$ start-hbase.sh</pre>
<pre class="lang:vim decode:true">hbase(main):003:0&gt; get 'test','TEST_COPROCESSOR'
COLUMN               CELL                                                      
 name:first      timestamp=9223372036854775807, value=saurzcode                    
1 row(s) in 0.0210 seconds
</pre>
That's it !! We have successfully created a CoProcessor that intercepts calls to get for a particular row.