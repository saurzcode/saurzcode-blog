---
id: 1175
title: 'How to Use MultiThreadedMapper in MapReduce'
date: '2018-05-27T11:40:21-07:00'
author: saurzcode
layout: medium
guid: 'https://saurzcode.in/?p=1175'
permalink: /2018/05/how-to-use-multithreadedmapper-in-mapreduce/
meta-checkbox:
    - ''
categories:
    - 'Big Data'
    - Java
    - Technology
tags:
    - hadoop
    - mapereduce
    - MultithreadedMapper
---

In simple MapReduce Job each instance of Mapper.map() method is invoked by a single thread and key value pair are passed serially. MultithreadedMapper class is used instead of default Mapper when tasks are CPU bound and multiple threads running a map tasks can help to speed up the tasks, based on availability of cores in the system. In case of MultithreadedMapper implementation , there will be multiple threads running the Mapper.map() method in single Mapper instance. Threads from a thread pool invoke a queue of key value pairs in parallel in a single Mapper Class instance.One thing in particular to keep in mind is, the map implementation must be thread safe. Here are the steps needed to create a [MultithreadedMapper](https://hadoop.apache.org/docs/r3.0.0/api/org/apache/hadoop/mapreduce/lib/map/MultithreadedMapper.html) implementation in your MapReduce Driver Code -

Configuration conf = new Configuration();
Job job = new Job(conf);
job.setMapperClass(MultithreadedMapper.class);
conf.set("mapred.map.multithreadedrunner.class", WordCountMapper.class.getCanonicalName());
conf.set("mapred.map.multithreadedrunner.threads", "8");
job.setJarByClass(WordCountMapper.class);
job.waitForCompletion(true);

#### Properties

_mapred.map.multithreadedrunner.class_ property is used to set the Mapper class whose instance will be invoked by multiple threads in parallel. _mapred.map.multithreadedrunner.threads_ property is used to define number of threads in thread pool that will run the map function. Default value is 10. Properties can also be set using methods in MultithreadedMapper class as follows -

MultithreadedMapper.setMapperClass(job, WordCountMapper.class);
MultithreadedMapper.setNumberOfThreads(job, 8);

Internally, MultithreadedMapper class overridedes run method to create multiple threads, each to run a map() function on a subrecord of input in inputsplit.

/\*\*
\* Run the application's maps using a thread pool.
\*/
@Override
public void run(Context context) throws IOException, InterruptedException {
outer = context;
int numberOfThreads = getNumberOfThreads(context);
mapClass = getMapperClass(context);
if (LOG.isDebugEnabled()) {
LOG.debug("Configuring multithread runner to use " + numberOfThreads + 
" threads");
}

runners = new ArrayList<MapRunner>(numberOfThreads);
for(int i=0; i < numberOfThreads; ++i) {
MapRunner thread = new MapRunner(context);
thread.start();
runners.add(i, thread);
}
for(int i=0; i < numberOfThreads; ++i) {
MapRunner thread = runners.get(i);
thread.join();
Throwable th = thread.throwable;
if (th != null) {
if (th instanceof IOException) {
throw (IOException) th;
} else if (th instanceof InterruptedException) {
throw (InterruptedException) th;
} else {
throw new RuntimeException(th);
}
}
}
}

Some of the use cases where you can use this is, to load data in HBase using a Map only MapReduce Job, in this case, your data loads can be significantly faster than a single threaded job. But please keep in mind of the fact that your HBase cluster should be able to handle the increased load. Please let me know in comments, where else you have used MultithreadedMapper in your jobs. Happy Learning !

##### Related -

[Top 20 Hadoop and Big Data Books](https://saurzcode.in/2014/06/top-20-hadoop-bigdatabooks/) [How to Configure Spark Application ( Scala and Java 8 Version with Maven ) in Eclipse.](https://saurzcode.in/2017/10/configure-spark-application-eclipse/)