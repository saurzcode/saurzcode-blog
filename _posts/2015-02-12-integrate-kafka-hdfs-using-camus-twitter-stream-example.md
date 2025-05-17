---
id: 915
title: 'How-To : Integrate Kafka with HDFS using Camus (Twitter Stream Example)'
date: '2015-02-12T17:53:51-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in//?p=915'
permalink: /2015/02/integrate-kafka-hdfs-using-camus-twitter-stream-example/
meta-checkbox:
    - ''
dsq_thread_id:
    - '3509130304'
categories:
    - 'Big Data'
    - Java
    - Kafka
    - Technology
tags:
    - camus
    - hdfs
    - kafka
    - kafka-hdfs
    - linkedin
---

<h3 style="text-align: left;"><strong>Simple String Example for Setting up Camus for Kafka-HDFS Data Pipeline</strong></h3>
I came across Camus while building a Lambda Architecture framework recently. I couldn’t find a good Illustration of getting started with Kafk-HDFS pipeline ,  In this post we will see how we can use Camus to build a Kafka-HDFS data pipeline using a twitter stream produced by Kafka Producer as mentioned in last <a class="vt-p" href="https://saurzcode.in//2015/02/kafka-producer-using-twitter-stream/">post</a> .
<h4><strong>What is Camus?</strong></h4>
Camus is LinkedIn's <a class="vt-p" href="http://kafka.apache.org/">Kafka</a>-&gt;HDFS pipeline. It is a mapreduce job that does distributed data loads out of Kafka. It includes the following features:<!--more-->
<ul>
	<li>Automatic discovery of topics</li>
	<li>Avro schema management / In progress</li>
	<li>Date partitioning</li>
</ul>
More details on overview of the projects is available on Camus READ ME <a class="vt-p" href="https://github.com/linkedin/camus">page</a> on github.

<hr />

<h2> <strong>Setting up Camus</strong></h2>
<h4><strong>Requirements:</strong></h4>
<ul>
	<li>Apache Hadoop 2+</li>
	<li>Apache Kafka 0.8</li>
	<li>Twitter Developer account ( for API Key, Secret etc.)</li>
	<li>Apache Zookeeper ( required for Kafka)</li>
	<li>Oracle JDK 1.7 (64 bit )</li>
</ul>
<h4><strong>Build Environment:</strong></h4>
<ul>
	<li>Eclipse</li>
	<li>Apache Maven 2/3</li>
</ul>
<h4>Building Camus Jar</h4>
To build Camus:
<ul>
	<li>Clone the Git Repo from <a class="vt-p" href="https://github.com/linkedin/camus">https://github.com/linkedin/camus</a> or download the complete project.</li>
	<li>Change the version of hadoop-client library in camus/pom.xml to match your hadoop version, In our case it's 2.6.0 so we will change that to as follows -</li>
</ul>
<pre class="lang:xhtml decode:true">&lt;dependency&gt;
&lt;groupId&gt;org.apache.hadoop&lt;/groupId&gt;
&lt;artifactId&gt;hadoop-client&lt;/artifactId&gt;
&lt;version&gt;2.6.0&lt;/version&gt;
&lt;/dependency&gt;</pre>
<ul>
	<li>Build using
<pre class="lang:sh decode:true">mvn clean package -DskipTests</pre>
And wait for <span style="color: #99cc00;">BUILD SUCCESS</span> message, be patient as it may take some time while building first time.</li>
</ul>
<h1>Camus Essentials - Decoder and RecordWriterProvider</h1>
Camus needs two main components for reading and decoding data from Kafka and writing data to HDFS -
<ol>
	<li><strong>Decoding Messages read from Kafka</strong>  -  Camus has a set of Decoders which helps in decoding messages coming from Kafka,  Decoders basically extends<span style="color: #3366ff;"> com.linkedin.camus.coders.MessageDecoder</span> which implements logic to partition data based on timestamp. A set of predefined Decoders are present in this directory and you can write  your own based on these.                                                                          <em>camus/camus-kafka-coders/src/main/java/com/linkedin/camus/etl/kafka/coders/</em></li>
</ol>
<ol start="2">
	<li><strong>Writing messages  to HDFS</strong> - Camus needs a set of RecordWriterProvider classes  which extends <span style="color: #3366ff;">com.linkedin.camus.etl.RecordWriterProvider</span> that will tell Camus what’s the payload that should be written to HDFS.A set of predefined RecordWriterProvider are present in this directory and you can write your own based on these.</li>
</ol>
<em>camus-etl-kafka/src/main/java/com/linkedin/camus/etl/kafka/common</em>
<h1>Configuring and Running Camus</h1>
Camus needs Hadoop and JobHistory server to be running ,So let's get it up -
<ol>
	<li>Start Hadoop and JobHistory Server Daemon , inside your Hadoop installation directory sbin folder -</li>
</ol>
<pre class="lang:sh decode:true">$ start-dfs.sh

$ start-yarn.sh

$ mr-jobhistory-daemon.sh start historyserver</pre>
2.  Also, setup Kafka and Twitter configuration as mentioned in <a class="vt-p" title="How-To : Write a Kafka Producer using Twitter Stream ( Twitter HBC Client)" href="https://saurzcode.in//2015/02/kafka-producer-using-twitter-stream/">previous post </a> , which specifies topic as "twitter-topic" and client id as "camus" ( which we'll configure in camus.properties too later ) and keep it running .

3. <strong>Configuring Camus Properties</strong> -  We’ll use<em> camus.properties</em> as present <a class="vt-p" href="https://github.com/linkedin/camus/blob/master/camus-example/src/main/resources/camus.properties">here </a>and customize as per our need and configuration
<ul>
	<li>Specify <span style="color: #3366ff;">JsonStringMessageDecoder</span> as decoder for messages on "twitter-topic" and <span style="color: #3366ff;">StringRecordWriterProvider</span> for writing output -</li>
</ul>
<pre class="lang:vim decode:true">camus.message.decoder.class.twitter-topic=com.linkedin.camus.etl.kafka.coders.JsonStringMessageDecoder

etl.record.writer.provider.class=com.linkedin.camus.etl.kafka.common.StringRecordWriterProvider</pre>
<ul>
	<li>Configure  Kafka broker list, etl destination path ( destination where actual data from kafka will be written based on date partitioning) , base execution and execution history path.</li>
</ul>
<pre class="lang:vim decode:true">kafka.client.name=camus

kafka.brokers=localhost:9092

etl.destination.path = /user/hduser/topic/

etl.execution.base.path=/user/hduser/exec/

etl.execution.history.path=/user/hduser/camus/exec/history</pre>
<ul>
	<li> Specify "created_at" field present in twitter json as the timestamp field and timestamp format as ISO-8601</li>
</ul>
<pre class="lang:vim decode:true">camus.message.timestamp.field=created_at

camus.message.timestamp.format=ISO-8601</pre>
I am also presenting complete<em> camus.properties</em> files -
<pre class="lang:vim decode:true"># Needed Camus properties, more cleanup to come
#
# Almost all properties have decent default properties. When in doubt, comment out the property.
#

# The job name.
camus.job.name=Camus Job

# final top-level data output directory, sub-directory will be dynamically created for each topic pulled
etl.destination.path=/user/hduser/topics
# HDFS location where you want to keep execution files, i.e. offsets, error logs, and count files
etl.execution.base.path=/user/hduser/exec
# where completed Camus job output directories are kept, usually a sub-dir in the base.path
etl.execution.history.path=/user/hduser/camus/exec/history

# Concrete implementation of the Encoder class to use (used by Kafka Audit, and thus optional for now)
#camus.message.encoder.class=com.linkedin.camus.etl.kafka.coders.DummyKafkaMessageEncoder

# Concrete implementation of the Decoder class to use.
# Out of the box options are:
#  com.linkedin.camus.etl.kafka.coders.JsonStringMessageDecoder - Reads JSON events, and tries to extract timestamp.
#  com.linkedin.camus.etl.kafka.coders.KafkaAvroMessageDecoder - Reads Avro events using a schema from a configured schema repository.
#  com.linkedin.camus.etl.kafka.coders.LatestSchemaKafkaAvroMessageDecoder - Same, but converts event to latest schema for current topic.
camus.message.decoder.class.twitter-topic=com.linkedin.camus.etl.kafka.coders.StringMessageDecoder

# Decoder class can also be set on a per topic basis.
#camus.message.decoder.class.&lt;topic-name&gt;=com.your.custom.MessageDecoder

# Used by avro-based Decoders (KafkaAvroMessageDecoder and LatestSchemaKafkaAvroMessageDecoder) to use as their schema registry.
# Out of the box options are:
# com.linkedin.camus.schemaregistry.FileSchemaRegistry
# com.linkedin.camus.schemaregistry.MemorySchemaRegistry
# com.linkedin.camus.schemaregistry.AvroRestSchemaRegistry
# com.linkedin.camus.example.schemaregistry.DummySchemaRegistry
#kafka.message.coder.schema.registry.class=com.linkedin.camus.schemaregistry.AvroRestSchemaRegistry

# Used by JsonStringMessageDecoder when extracting the timestamp
# Choose the field that holds the time stamp (default "timestamp")
camus.message.timestamp.field=created_at
# What format is the timestamp in? Out of the box options are:
# "unix" or "unix_seconds": The value will be read as a long containing the seconds since epoc
# "unix_milliseconds": The value will be read as a long containing the milliseconds since epoc
# "ISO-8601": Timestamps will be fed directly into org.joda.time.DateTime constructor, which reads ISO-8601
# All other values will be fed into the java.text.SimpleDateFormat constructor, which will be used to parse the timestamps
# Default is "[dd/MMM/yyyy:HH:mm:ss Z]"
#camus.message.timestamp.format=yyyy-MM-dd_HH:mm:ss
camus.message.timestamp.format=ISO-8601

# Used by the committer to arrange .avro files into a partitioned scheme. This will be the default partitioner for all
# topic that do not have a partitioner specified.
# Out of the box options are (for all options see the source for configuration options):
# com.linkedin.camus.etl.kafka.partitioner.HourlyPartitioner, groups files in hourly directories
# com.linkedin.camus.etl.kafka.partitioner.DailyPartitioner, groups files in daily directories
# com.linkedin.camus.etl.kafka.partitioner.TimeBasedPartitioner, groups files in very configurable directories
# com.linkedin.camus.etl.kafka.partitioner.DefaultPartitioner, like HourlyPartitioner but less configurable
# com.linkedin.camus.etl.kafka.partitioner.TopicGroupingPartitioner
#etl.partitioner.class=com.linkedin.camus.etl.kafka.partitioner.HourlyPartitioner

# Partitioners can also be set on a per-topic basis. (Note though that configuration is currently not per-topic.)
#etl.partitioner.class.&lt;topic-name&gt;=com.your.custom.CustomPartitioner

# all files in this dir will be added to the distributed cache and placed on the classpath for hadoop tasks
# hdfs.default.classpath.dir=

# max hadoop tasks to use, each task can pull multiple topic partitions
mapred.map.tasks=5
# max historical time that will be pulled from each partition based on event timestamp
kafka.max.pull.hrs=1
# events with a timestamp older than this will be discarded.
kafka.max.historical.days=3
# Max minutes for each mapper to pull messages (-1 means no limit)
kafka.max.pull.minutes.per.task=-1

# if whitelist has values, only whitelisted topic are pulled. Nothing on the blacklist is pulled
kafka.blacklist.topics=
kafka.whitelist.topics=
log4j.configuration=true

# Name of the client as seen by kafka
kafka.client.name=camus
# The Kafka brokers to connect to, format: kafka.brokers=host1:port,host2:port,host3:port
kafka.brokers=localhost:9092
# Fetch request parameters:
#kafka.fetch.buffer.size=
#kafka.fetch.request.correlationid=
#kafka.fetch.request.max.wait=
#kafka.fetch.request.min.bytes=
#kafka.timeout.value=

#Stops the mapper from getting inundated with Decoder exceptions for the same topic
#Default value is set to 10
max.decoder.exceptions.to.print=5

#Controls the submitting of counts to Kafka
#Default value set to true
post.tracking.counts.to.kafka=true
#monitoring.event.class=class.that.generates.record.to.submit.counts.to.kafka

# everything below this point can be ignored for the time being, will provide more documentation down the road
##########################
etl.run.tracking.post=false
kafka.monitor.tier=
etl.counts.path=
kafka.monitor.time.granularity=10

etl.hourly=hourly
etl.daily=daily

# Should we ignore events that cannot be decoded (exception thrown by MessageDecoder)?
# `false` will fail the job, `true` will silently drop the event.
etl.ignore.schema.errors=false

# configure output compression for deflate or snappy. Defaults to deflate
mapred.output.compress=false
etl.output.codec=deflate
etl.deflate.level=6
#etl.output.codec=snappy

etl.default.timezone=America/Los_Angeles
etl.output.file.time.partition.mins=60
etl.keep.count.files=false
etl.execution.history.max.of.quota=.8

# Configures a customer reporter which extends BaseReporter to send etl data
#etl.reporter.class

mapred.map.max.attempts=1

kafka.client.buffer.size=20971520
kafka.client.so.timeout=60000

#zookeeper.session.timeout=
#zookeeper.connection.timeout=
etl.record.writer.provider.class=com.linkedin.camus.etl.kafka.common.StringRecordWriterProvider
</pre>
One last thing, in my example I have  set
<pre class="lang:vim decode:true">mapred.output.compress=false</pre>
which, in real scenarios will be set to true and defaults to DEFLATE compression.
<h3>Running Camus</h3>
After building camus  in first step, you should see in target folder of camus-example folder a jar named <em>camus-example - camus-example-0.1.0-SNAPSHOT-shaded.jar</em>

Put jar and <em>camus.properties</em> file in a folder and execute this command .
<pre class="lang:sh decode:true">hadoop jar camus-example-0.1.0-SNAPSHOT-shaded.jar com.linkedin.camus.etl.kafka.CamusJob -P camus.properties</pre>
That's It !!

If you see above command to be successfully executed , you should see the records in HDFS at following path -

<em>/user/hduser/topics/</em> or whatever path you have mentioned in your <em>camus.properties</em> file.

<a class="vt-p" href="https://saurzcode.in//wp-content/uploads/2015/02/camus_kafka_hdfs.png"><img class=" wp-image-926 size-full aligncenter" src="https://saurzcode.in//wp-content/uploads/2015/02/camus_kafka_hdfs.png" alt="camus_kafka_hdfs" width="729" height="185" /></a>

<strong> </strong>

&nbsp;

Please write back to me in comments if you face any issues while executing this one.

Happy Learning !!

&nbsp;