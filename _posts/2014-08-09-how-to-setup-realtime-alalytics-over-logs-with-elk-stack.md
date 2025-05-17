---
id: 641
title: 'How-To : Setup Realtime Alalytics over Logs with ELK Stack : Elasticsearch, Logstash, Kibana?'
date: '2014-08-09T17:10:33-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in//?p=641'
permalink: /2014/08/how-to-setup-realtime-alalytics-over-logs-with-elk-stack/
geo_public:
    - '0'
meta-checkbox:
    - ''
dsq_thread_id:
    - '3280625820'
categories:
    - 'Big Data'
    - Java
    - Technology
tags:
    - 'big data'
    - 'Centralised Logging'
    - ElasticSearch
    - ELK
    - Kibana
    - LogStash
---

<blockquote>Once we know something, we find it hard to imagine what it was like not to know it.

- Chip &amp; Dan Heath, Authors of Made to Stick, Switch</blockquote>
&nbsp;
<h3>What is the ELK stack ?</h3>
The ELK stack consists of opensource tools <em>ElasticSearch</em>, <em>Logstash</em> and <em>Kibana</em>. These three provide a fully working real-time data analytics tool for getting wonderful information sitting on your data.

<strong>ElasticSearch</strong>

ElasticSearch,built on top of Apache Lucene, is a search engine with focus on real-time analysis of the data, and is based on the RESTful architecture. It provides standard full text search functionality and powerful search based on query. ElasticSearch is document-oriented/based and you can store everything you want as JSON. This makes it powerful, simple and flexible.

<strong>Logstash</strong>

Logstash is a tool for managing events and logs. You can use it to collect logs, parse them, and store them for later use.In ELK Stack logstash plays an important role in shipping the log and indexing them later which can be supplied to Elastic Search.

<strong>Kibana</strong>

Kibana is a user friendly way to view, search and visualize your log data, which will present the data stored from Logstash into ElasticSearch, in a very customizable interface with histogram and other panels which provides real-time analysis and search of data you have parsed into ElasticSearch.

<strong>How do I get it  ?</strong>

<a href="https://www.elastic.co/downloads">https://www.elastic.co/downloads</a>

<strong>How do they work together ?</strong>

Logstash is essentially a pipelining tool. In a basic, centralized installation a logstash agent, known as the shipper, will read input from one to many input sources and output that text wrapped in a JSON message to a broker. Typically Redis, the broker, caches the messages until another logstash agent, known as the collector, picks them up, and sends them to another output. In the common example this output is Elasticsearch, where the messages will be indexed and stored for searching. The Elasticsearch store is accessed via the Kibana web application which allows you to visualize and search through the logs. The entire system is scalable. Many different shippers may be running on many different hosts, watching log files and shipping the messages off to a cluster of brokers. Then many collectors can be reading those messages and writing them to an Elasticsearch cluster.

[caption id="attachment_644" align="aligncenter" width="729"]<a class="vt-p" href="https://saurzcode.in//2014/08/how-to-configure-swagger-to-generate-restful-api-doc-for-your-spring-boot-web-application/"><img class="wp-image-644 size-full" src="https://saurzcode.in//wp-content/uploads/2014/08/logstash1-e1407584364173.png" alt="Realtime Analytics for logs using ELK Stack" width="729" height="323" /></a> (E)lasticSearch (L)ogstash  (K)ibana (The ELK Stack)[/caption]

<strong>How do i fetch useful information out of logs ? </strong>

Fetching useful information from logs is one of the most important part of this stack and is being done in logstash using its <strong>grok filters </strong>and a set of <em>input</em> , <em>filter</em> and <em>output</em> plugins which helps to scale this functionality for taking various kinds of inputs (<em> file,tcp, udp, gemfire, stdin, unix, web sockets and even IRC and twitter and many more</em>) , filter them using (<em>groks,grep,date filters etc.</em>) and finally write ouput to <em>ElasticSearch,redis,email,HTTP,MongoDB,Gemfire , Jira , Google Cloud Storage etc.</em>

<strong>A bit more about Log Stash</strong>

<a class="vt-p" href="https://saurzcode.in//2014/08/how-to-configure-swagger-to-generate-restful-api-doc-for-your-spring-boot-web-application/"><img class="aligncenter wp-image-668 size-medium" src="https://saurzcode.in//wp-content/uploads/2014/08/grok-300x168.png" alt="Realtime Analytics over Logs using ELK Stack" width="300" height="168" /></a>

<strong>Filters </strong>

Transforming the logs as they go through the pipeline is possible as well using filters. Either on the shipper or collector, whichever suits your needs better. As an example, an Apache HTTP log entry can have each element (request, response code, response size, etc) parsed out into individual fields so they can be searched on more seamlessly. Information can be dropped if it isn’t important. Sensitive data can be masked. Messages can be tagged. The list goes on.

e.g.
<p style="text-align: left;">[gist https://gist.github.com/saurzcode/da3b31f0496b5feba8c9 /]</p>
&nbsp;

Above example takes input from an apache log file applies a grok filter with <em>%{COMBINEDAPACHELOG}</em>, which will index apache logs information on fields and finally output to Standard Output Console.

<strong>Writing Grok Filters</strong>

Writing grok filters and fetching information is the only task that requires some serious efforts and if done properly will give you great insights in to your data like Number of Transations performed over time, Which type of products have most hits etc.

Below links will help you a lot in writing grok filters and test them with ease -

<strong>Grok Debugger</strong>

Grok Debugger is a wonderful tool for testing your grok patterns before using in your logstash filters.

<span style="color: #3366ff;"><a class="vt-p" href="http://grokdebug.herokuapp.com/"><span style="color: #3366ff;">http://grokdebug.herokuapp.com/</span></a></span>

<strong>Grok Patterns Lookup</strong>

You can lookup grok for various commonly used log patterns here -

<a href="https://github.com/elastic/logstash/blob/v1.4.2/patterns/grok-patterns">https://github.com/elastic/logstash/blob/v1.4.2/patterns/grok-patterns</a>

If you like this post you will love to read my book on ELK stack - <a href="https://www.packtpub.com/big-data-and-business-intelligence/learning-elk-stack">https://www.packtpub.com/big-data-and-business-intelligence/learning-elk-stack</a>  . The book covers all the basics of Elasticsearch, Logstash and Kibana4 to get you started on ELK stack.Please find more details of the book <a href="https://saurzcode.in//2015/12/book-on-elk-stack-learning-elk-stack/">here</a>.

<span style="text-decoration: underline;">References</span> -
<ul>
	<li><a class="vt-p" href="http://www.elasticsearch.org/overview/">http://www.elasticsearch.org/overview/</a></li>
	<li><a class="vt-p" href="http://logstash.net/">http://logstash.net/</a></li>
	<li><a class="vt-p" href="http://rashidkpc.github.io/Kibana/about.html">http://rashidkpc.github.io/Kibana/about.html</a></li>
</ul>

<hr />

<span style="text-decoration: underline;"><strong>Related Articles :-</strong></span>

<span style="text-decoration: underline;"><span style="color: #3366ff; text-decoration: underline;"><a class="vt-p" title="How to Become a Hadoop Certified Developer ?" href="https://saurzcode.in//2014/05/31/hadoop-certifications/" target="_blank"><span style="color: #3366ff; text-decoration: underline;">Hadoop Certification</span></a></span></span>

<span style="text-decoration: underline;"><span style="color: #3366ff; text-decoration: underline;"><a class="vt-p" title="Hadoop : Getting Started with Pig" href="https://saurzcode.in//2014/06/28/getting-started-with-pig/" target="_blank"><span style="color: #3366ff; text-decoration: underline;">Getting Started with Apache Pig</span></a></span></span>

<span style="text-decoration: underline;"><span style="color: #3366ff; text-decoration: underline;"><a class="vt-p" title="Reading List : Hadoop and Big Data Books" href="https://saurzcode.in//2014/06/01/reading-list-hadoop/" target="_blank"><span style="color: #3366ff; text-decoration: underline;">Hadoop Reading List</span></a></span></span>

&nbsp;