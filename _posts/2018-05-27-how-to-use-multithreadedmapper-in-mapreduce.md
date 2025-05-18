---
id: 1175
title: 'How to Use MultiThreadedMapper in MapReduce'
date: '2018-05-27T11:40:21-07:00'
author: saurzcode

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

# How to Use MultiThreadedMapper in MapReduce

A practical, developer-focused guide to using Hadoop's `MultithreadedMapper` for parallelizing map tasks and improving performance in CPU-bound jobs.

---

## Table of Contents

- [How to Use MultiThreadedMapper in MapReduce](#how-to-use-multithreadedmapper-in-mapreduce)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Why Use MultithreadedMapper?](#why-use-multithreadedmapper)
  - [How MultithreadedMapper Works](#how-multithreadedmapper-works)
  - [Configuring MultithreadedMapper in Your Job](#configuring-multithreadedmapper-in-your-job)
    - [Via Configuration Properties](#via-configuration-properties)
    - [Via MultithreadedMapper Methods](#via-multithreadedmapper-methods)
  - [Thread Safety Considerations](#thread-safety-considerations)
  - [Example: Using MultithreadedMapper](#example-using-multithreadedmapper)
  - [Use Cases](#use-cases)
  - [Summary](#summary)

---

## Introduction

In a standard MapReduce job, each call to `Mapper.map()` is handled by a single thread, and key-value pairs are processed serially. However, for CPU-bound tasks, you can speed up processing by running multiple threads within a single mapper task using Hadoop's `MultithreadedMapper` class.

---

## Why Use MultithreadedMapper?

- **Parallelism:** Utilize multiple CPU cores by running several threads per mapper task
- **Performance:** Speed up CPU-bound map operations
- **Flexibility:** Control the number of threads per mapper

**Note:** Your `Mapper` implementation must be thread-safe!

---

## How MultithreadedMapper Works

- `MultithreadedMapper` creates a thread pool within each mapper task
- Each thread runs the `map()` method on a subset of the input split
- Threads process key-value pairs in parallel, improving throughput
- The number of threads is configurable

---

## Configuring MultithreadedMapper in Your Job

### Via Configuration Properties

```java
Configuration conf = new Configuration();
Job job = new Job(conf);
job.setMapperClass(MultithreadedMapper.class);
conf.set("mapred.map.multithreadedrunner.class", WordCountMapper.class.getCanonicalName());
conf.set("mapred.map.multithreadedrunner.threads", "8");
job.setJarByClass(WordCountMapper.class);
job.waitForCompletion(true);
```

- `mapred.map.multithreadedrunner.class`: The actual `Mapper` class to run in parallel
- `mapred.map.multithreadedrunner.threads`: Number of threads (default: 10)

### Via MultithreadedMapper Methods

```java
MultithreadedMapper.setMapperClass(job, WordCountMapper.class);
MultithreadedMapper.setNumberOfThreads(job, 8);
```

---

## Thread Safety Considerations

- The `map()` method and any shared resources must be thread-safe
- Avoid using mutable shared state in your `Mapper`
- Use local variables inside `map()` whenever possible

---

## Example: Using MultithreadedMapper

Here's a simplified example of how `MultithreadedMapper` manages threads internally:

```java
/**
 * Run the application's maps using a thread pool.
 */
@Override
public void run(Context context) throws IOException, InterruptedException {
    outer = context;
    int numberOfThreads = getNumberOfThreads(context);
    mapClass = getMapperClass(context);
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
```

---

## Use Cases

- **HBase Bulk Loads:** Speed up data loading in HBase using a map-only job
- **CPU-bound Map Tasks:** Any map operation that is CPU-intensive and can benefit from parallelism
- **Custom Data Processing:** When you want to maximize CPU utilization within a single mapper

**Caution:** Ensure your downstream systems (e.g., HBase) can handle the increased load from parallel mappers.

---

## Summary

- `MultithreadedMapper` allows you to run multiple threads per mapper task for parallel map processing
- Use it for CPU-bound workloads where thread safety can be guaranteed
- Configure the number of threads via properties or helper methods
