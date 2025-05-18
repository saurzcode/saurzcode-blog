---
id: 913
title: 'How-To : Write a Kafka Producer using Twitter Stream ( Twitter HBC Client)'
date: '2015-02-12T00:47:49-07:00'
author: saurzcode

guid: 'https://saurzcode.in//?p=913'
permalink: /2015/02/kafka-producer-using-twitter-stream/
meta-checkbox:
    - ''
dsq_thread_id:
    - '3508545894'
classic-editor-remember:
    - classic-editor
categories:
    - 'Big Data'
    - Java
    - Kafka
    - Technology
tags:
    - 'big data'
    - kafka
    - storm
    - twitter
---

# How-To: Write a Kafka Producer using Twitter Stream (Twitter HBC Client)

A step-by-step guide to building a Kafka producer that streams live tweets using Twitter's Hosebird Client (HBC) and publishes them to a Kafka topic. This is a practical, developer-focused walkthrough with code, configuration, and troubleshooting tips.
<!--more-->
---

## Table of Contents

- [How-To: Write a Kafka Producer using Twitter Stream (Twitter HBC Client)](#how-to-write-a-kafka-producer-using-twitter-stream-twitter-hbc-client)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Requirements](#requirements)
  - [Build Environment](#build-environment)
  - [Generating Twitter API Keys](#generating-twitter-api-keys)
  - [Kafka \& Zookeeper Setup](#kafka--zookeeper-setup)
    - [Start Zookeeper](#start-zookeeper)
    - [Start Kafka](#start-kafka)
      - [On macOS with Homebrew](#on-macos-with-homebrew)
  - [Creating a Kafka Topic](#creating-a-kafka-topic)
  - [Kafka Producer with Twitter HBC](#kafka-producer-with-twitter-hbc)
    - [Maven Dependencies](#maven-dependencies)
    - [Kafka Producer Properties](#kafka-producer-properties)
    - [Twitter HBC Client Setup](#twitter-hbc-client-setup)
    - [Producing Tweets to Kafka](#producing-tweets-to-kafka)
  - [Running the Example](#running-the-example)
  - [References \& Further Reading](#references--further-reading)

---

## Introduction

[Twitter's Hosebird Client (HBC)](https://github.com/twitter/hbc) is a robust Java HTTP library for consuming Twitter's [Streaming API](https://dev.twitter.com/docs/streaming-apis). In this guide, you'll learn how to use HBC to create a Kafka producer that streams tweets matching specific terms and publishes them to a Kafka topic. This data can then be used for analytics, real-time processing (e.g., with Storm), or further pipelined to HDFS.

You can find a complete sample project [here](https://github.com/saurzcode/twitter-stream/).

---

## Requirements

- **Apache Kafka 2.6.0**
- **Twitter Developer Account** (for API Key, Secret, etc.)
- **Apache Zookeeper** (required for Kafka)
- **Oracle JDK 1.8 (64-bit)**

## Build Environment

- **Eclipse** (or your preferred IDE)
- **Apache Maven 2/3**

---

## Generating Twitter API Keys

To access the Twitter Streaming API, you need API keys and tokens:

1. Go to [https://dev.twitter.com/apps/new](https://dev.twitter.com/apps/new) and log in.
2. Enter your Application Name, Description, and website address (callback URL can be left empty).
3. Accept the Terms of Service and create your application.
4. Copy the **Consumer Key (API key)** and **Consumer Secret**.
5. Click **Create my Access Token** to generate your **Access Token** and **Access Token Secret**.
6. You now have all four credentials needed for OAuth authentication.

---

## Kafka & Zookeeper Setup

Start Zookeeper and Kafka servers. Replace `$KAFKA_HOME` with your Kafka installation directory.

### Start Zookeeper

```sh
$KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties &
```

Verify Zookeeper is running (default port 2181):

```sh
netstat -anlp | grep 2181
```

### Start Kafka

```sh
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties &
```

Verify Kafka is running (default port 9092).

#### On macOS with Homebrew

```sh
brew install kafka  # Installs Zookeeper too
brew services start zookeeper
kafka-server-start /usr/local/etc/kafka/server.properties
```

---

## Creating a Kafka Topic

Create a topic named `twitter-topic`:

```sh
$KAFKA_HOME/bin/kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic twitter-topic
```

Validate the topic:

```sh
$KAFKA_HOME/bin/kafka-topics --describe --zookeeper localhost:2181 --topic twitter-topic
```

---

## Kafka Producer with Twitter HBC

Now, let's build a Kafka producer that streams tweets using HBC and publishes them to `twitter-topic`.

### Maven Dependencies

Add these dependencies to your `pom.xml`:

```xml
<dependency>
   <groupId>com.twitter</groupId>
   <artifactId>hbc-core</artifactId> <!-- or hbc-twitter4j -->
   <version>2.2.0</version> <!-- or latest -->
</dependency>
<dependency>
   <groupId>org.apache.kafka</groupId>
   <artifactId>kafka-clients</artifactId>
   <version>2.6.0</version>
</dependency>
```

### Kafka Producer Properties

Configure your Kafka producer:

```java
Properties properties = new Properties();
properties.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, TwitterKafkaConfig.SERVERS);
properties.put(ProducerConfig.ACKS_CONFIG, "1");
properties.put(ProducerConfig.LINGER_MS_CONFIG, 500);
properties.put(ProducerConfig.RETRIES_CONFIG, 0);
properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, LongSerializer.class.getName());
properties.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
```

### Twitter HBC Client Setup

Set up the HBC client to track terms and authenticate:

```java
StatusesFilterEndpoint endpoint = new StatusesFilterEndpoint();
endpoint.trackTerms(Lists.newArrayList(term));

Authentication auth = new OAuth1(consumerKey, consumerSecret, token, secret);

Client client = new ClientBuilder()
    .hosts(Constants.STREAM_HOST)
    .endpoint(endpoint)
    .authentication(auth)
    .processor(new StringDelimitedProcessor(queue))
    .build();
```

### Producing Tweets to Kafka

Connect to the Twitter stream, fetch messages from the queue, and send them to Kafka:

```java
client.connect();
try (Producer<Long, String> producer = getProducer()) {
    while (true) {
        ProducerRecord<Long, String> message = new ProducerRecord<>(TwitterKafkaConfig.TOPIC, queue.take());
        producer.send(message);
    }
} catch (InterruptedException e) {
    e.printStackTrace();
} finally {
    client.stop();
}
```

---

## Running the Example

- Run the `TwitterKafkaProducer.java` class as a Java application in your IDE.
- Pass your Twitter API keys and search terms as arguments (VM arguments or program arguments).
- For a complete runnable example and detailed instructions, see the [GitHub repository](https://github.com/saurzcode/twitter-stream/).

---

## References & Further Reading

- [Kafka Quickstart](https://kafka.apache.org/quickstart.html)
- [Twitter HBC](https://github.com/twitter/hbc)
- [How to generate Twitter API keys](https://themepacific.com/how-to-generate-api-key-consumer-token-access-key-for-twitter-oauth/994/)
- [Integrate Kafka with HDFS using Camus (blog)](http://saurzcode.in/2015/02/integrate-kafka-hdfs-using-camus-twitter-stream-example/)
- [Multithreaded Mappers in MapReduce](https://wp.me/p5pWDa-iX)

---

Happy Learning!