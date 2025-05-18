---
id: 861
title: 'How-To : Setup  Development Environment for  Hadoop MapReduce'
date: '2015-01-23T06:14:56-07:00'
author: saurzcode
layout: medium
guid: 'https://saurzcode.in//?p=861'
permalink: /2015/01/setup-development-environment-hadoop-mapreduce/
meta-checkbox:
    - ''
dsq_thread_id:
    - '3487569839'
categories:
    - 'Big Data'
    - Java
    - Technology
tags:
    - hadoop
    - 'hadoop blog'
    - 'hadoop interview'
    - hdfs
    - mapreduce
---

This post is intended for folks who are looking out for a quick start on developing a basic Hadoop MapReduce application.

We will see how to set up a basic MR application for `WordCount` using Java, Maven and Eclipse and run a basic MR program in local mode, which is easy for debugging at an early stage.

---

Assuming JDK 1.6+ is already installed and Eclipse has a setup for Maven plugin and download from default maven repository is not restricted.

## Problem Statement: To count the occurrence of each word appearing in an input file using Hadoop MapReduce.

### Step 1: Hadoop Maven Dependency
Create a maven project in eclipse and use following code in your `pom.xml`.

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.saurzcode.hadoop</groupId>
  <artifactId>MapReduce</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>

  <dependencies>
	<dependency>
		<groupId>org.apache.hadoop</groupId>
		<artifactId>hadoop-client</artifactId>
		<version>2.2.0</version>
	</dependency>
  </dependencies>
</project>
```

Upon saving it should download all required dependencies for running a basic Hadoop MapReduce program.

### Step 2: Mapper Program
Map step involves tokenizing the file, traversing the words, and emitting a count of one for each word that is found.

Our mapper class should extend Mapper class and override its map method. When this method is called the value parameter of the method will contain a chunk of the lines of file to be processed and the output parameter is used to emit word instances.

In real world clustered setup, this code will run on multiple nodes which will be consumed by set of reducers to process further.

```java
public class WordCountMapper extends
        Mapper<Object, Text, Text, IntWritable> {
 
    private final IntWritable ONE = new IntWritable(1);
    private Text word = new Text();
 
    public void map(Object key, Text value, Context context)
            throws IOException, InterruptedException {
 
        String line = value.toString();
        StringTokenizer tokenizer = new StringTokenizer(line);
        while(tokenizer.hasMoreTokens()) {
            word.set(tokenizer.nextToken());
            context.write(word, ONE);
        }
    }
}
```

### Step 3: Reducer Program
Our reducer extends the Reducer class and implements logic to sum up each occurrence of word token received from mappers. Output from Reducers will go to the `output` folder as a text file (default or as configured in Driver program for Output format) named as  `part-r-00000` along with a `_SUCCESS` file.

```java
public class WordCountReducer extends
        Reducer<Text, IntWritable, Text, IntWritable> {
 
    public void reduce(Text text, Iterable<IntWritable> values, Context context)
            throws IOException, InterruptedException {
        int sum = 0;
        for (IntWritable value : values) {
            sum += value.get();
        }
        context.write(text, new IntWritable(sum));
    }
}
```

### Step 4: Driver Program
Our driver program will configure the job by supplying the map and reduce program we just wrote along with various input, output parameters.

```java
public class WordCount {
 
    public static void main(String[] args) throws IOException,
            InterruptedException, ClassNotFoundException {
 
        Path inputPath = new Path(args[0]);
        Path outputDir = new Path(args[1]);
 
        // Create configuration
        Configuration conf = new Configuration(true);
 
        // Create job
        Job job = new Job(conf, "WordCount");
        job.setJarByClass(WordCountMapper.class);
 
        // Setup MapReduce
        job.setMapperClass(WordCountMapper.class);
        job.setReducerClass(WordCountReducer.class);
        job.setNumReduceTasks(1);
 
        // Specify key / value
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
 
        // Input
        FileInputFormat.addInputPath(job, inputPath);
        job.setInputFormatClass(TextInputFormat.class);
 
        // Output
        FileOutputFormat.setOutputPath(job, outputDir);
        job.setOutputFormatClass(TextOutputFormat.class);
 
        // Delete output if exists
        FileSystem hdfs = FileSystem.get(conf);
        if (hdfs.exists(outputDir))
            hdfs.delete(outputDir, true);
 
        // Execute job
        int code = job.waitForCompletion(true) ? 0 : 1;
        System.exit(code);
 
    }
 
}
```

That's it! We are all set to execute our first MapReduce Program in eclipse in local mode.

Let's assume there is an input text file called `input.txt` in folder `input` which contains following text:

```sh
foo bar is foo count

count foo for saurzcode
```

#### Expected output:

```sh
foo 3

bar  1

is  1

count 2

for 1

saurzcode 1
```

Let's run this program in eclipse as Java Application:

We need to give path to input and output folder/file to the program as argument. Also, note output folder shouldn't exist before running this program else program will fail.

```sh
java com.saurzcode.mapreduce.WordCount input/inputfile.txt output
```

If this program runs successfully emitting set of lines while it is executing mappers and reducers, we should see an output folder and with following files:

```sh
output/

_SUCCESS

part-r-00000
```

Enjoy Learning!!

---

**Interesting Reads:**

- [Multithreaded Mappers in Mapreduce](https://wp.me/p5pWDa-iX)