---
id: 1045
title: 'Why Log analysis is important for you ?'
date: '2015-12-19T19:06:01-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in//?p=1045'
permalink: /2015/12/why-log-analysis-is-important-for-you/
meta-checkbox:
    - ''
dsq_thread_id:
    - '4417241437'
categories:
    - Technology
tags:
    - ELK
    - 'Learning ELK'
    - PacktPub
    - 'Saurabh Chhajed'
---

<h1>Need for Log Analysis</h1>

Logs provide us with necessary information on how our system is behaving. However, the content and format of logs varies among different services or say, among different components of the same system. For example a scanner may log error messages related to communication with other devices, on the other hand a web server logs information on all incoming requests, outgoing response, time taken for response etc. Similarly application logs for an e-commerce website will log business specific logs.

As the logs vary by their content, so are their uses. For example, the logs from the scanner might be used for troubleshooting or for simple status check or reporting, while the Web-server log is used to analyze the traffic patterns across multiple products. Analysis of logs from an ecommerce site can help to figure out if packages from a specific location are returned repeatedly and probable reasons for the same.

<!--more-->Following are some common use cases where log analysis is helpful –

<ul>
    <li>Issue debugging</li>
    <li>Performance analysis</li>
    <li>Security analysis</li>
    <li>Predictive analysis</li>
    <li>Internet of things (IoT) and Logging</li>
</ul>

<h2>Issue debugging</h2>

Debugging is one of the most common reasons to enable logging within your application. The simplest and most frequent use for a debug log is to&nbsp;grep&nbsp;for a specific error message or event occurrence. If a DevOps person believes that a program crashed because of a network failure, then he or she will try to find a "connection dropped" or similar message in the server logs, to analyze what caused the issue. Once the bug or the issue is identified, Log analysis solutions help to capture the application information and snapshots of that particular time can be easily passed across development teams to analyze it further.

<h2>Performance analysis</h2>

Log analysis helps to optimize or debug system performance and give essential inputs around bottlenecks in the system. Understanding a system's performance is often about understanding the resource usage in the system. Logs can help to analyze individual resource usage in the system, behavior of multiple threads in the application, potential deadlocks conditions etc. Logs also carry with them timestamp information which is essential to analyze how system is behaving over time , for instance , a web server log can help to know how individual services are performing based on response times, HTTP response codes etc.

<h2>Security analysis</h2>

Logs play a very vital role in managing the application security for any organization. They are particularly helpful to detect security breaches, application misuse, malicious attacks and so on. When users interact with the system, it generates log events, which can help to track user behavior, identify suspicious activities and raise alarms or security incidents for breaches

Intrusion detection process involves session reconstruction from the logs itself. For example ssh log-in events in the system can be used to identify any breaches on the machines.

<h2>Predictive analysis</h2>

Predictive analysis is one of the hot trends of recent times. Logs and events data can be used for very accurate predictive analysis. Predictive analysis models helps in identifying potential customers, resource planning, inventory management and optimization, workload efficiency, and efficient resource scheduling. It also helps to guide the marketing strategy, or user segment targeting, ad placement strategy and so on.

<h2>Internet of things (IoT) and Logging</h2>

When it comes to IoT devices (devices or machines which interact with each other without any human intervention), it is vital that the system is monitored and managed to keep&nbsp;downtime to a minimum and resolve any important bugs or issues swiftly. Since these devices should be able to work with little human intervention and may exist on a&nbsp;large geographical scale, log data is expected to&nbsp;play a crucial role in understanding system behavior and reducing downtime.

<h1>Challenges in log analysis</h1>

Current log analysis process mostly involves checking logs at multiple servers written by different components and systems across your application, it has various problems which makes it time consuming and a tedious job. Let’s look at some of the common problem scenarios –

<ul>
    <li>Non-consistent Log Format</li>
    <li>Decentralized Logs</li>
    <li>Expert knowledge requirement</li>
</ul>

<h2>Non-consistent log format</h2>

Every application and device logs in its own special way, so each format needs its own expert. Also, it is difficult to search across because of different formats.

Let’s see some of the common log formats. An interesting thing to observe will be the way different logs represent different timestamp format, different way to represent INFO, ERROR and so on, and the order of these components with logs. It’s difficult to figure out just by seeing logs, what is present at what location, that’s where tools like Logstash helps.

<h3>Tomcat Logs</h3>

A typical tomcat server start-up log entry will look like this -

May 24, 2015 3:56:26 PM org.apache.catalina.startup.HostConfig deployWAR

INFO: Deployment of web application archive \soft\apache-tomcat-7.0.62\webapps\sample.war has finished in 253 ms

<h3>Apache Access Logs – Combined Log Format</h3>

A typical Apache access log entry will look like this -

127.0.0.1 - - [24/May/2015:15:54:59 +0530] "GET /favicon.ico HTTP/1.1" 200 21630

<h3>IIS Logs</h3>

A typical IIS log entry will look like this –

2012-05-02 17:42:15 172.24.255.255 - 172.20.255.255 80 GET /images/favicon.ico - 200 Mozilla/4.0+(compatible;MSIE+5.5;+Windows+2000+Server)

<h2>Variety of Time formats</h2>

Not only log formats, timestamp format is also different among different type of applications and different types of events generated across multiple devices, and so on. Different types of time formats across different components of your system, also makes it difficult to correlate events occurring across multiple systems at same times.

<ul>
    <li>142920788</li>
    <li>Oct 12 23:21:45</li>
    <li>[5/May/2015:08:09:10 +0000]</li>
    <li>Tue 01-01-2009 6:00</li>
    <li>2015-05-30 T 05:45&nbsp;<a href="http://en.wikipedia.org/wiki/UTC">UTC</a></li>
    <li>Sat Jul 23 02:16:57 2014</li>
    <li>07:38, 11 December 2012 (UTC)</li>
</ul>

<h2>Decentralized Logs</h2>

Logs are mostly spread all across the applications that may be across different servers and different components. Complexity of log analysis increases with multiple component logging at multiple locations. For one or two servers setup, finding out some information from logs, involves running cat or tail commands or pipe these results to grep command. But what if you have 10, 20 or say 100 servers? These kinds of searches are mostly not scalable for a huge cluster of machines and needs a centralized log management and analysis solution.

<h2>Expert knowledge requirement</h2>

People interested in getting the required Business centric information out of logs, generally don’t have access to the logs or may not have technical expertise to figure out appropriate information in quickest possible way, which can make analysis slower and sometimes impossible too.

<h2>Solution : The ELK Stack</h2>

ELK platform is complete log analytics solutions, built on a combination of three open source tools Elasticsearch, Logstash and Kibana. It tries to address all problems and challenges that we saw in above section .ELK stack is currently maintained and actively supported by company called <a href="elastic.co">Elastic</a> (formerly Elasticsearch).

The above post is an excerpt from my <a href="https://saurzcode.in//2015/12/book-on-elk-stack-learning-elk-stack/" target="_blank" rel="noopener noreferrer">Book on ELK stack</a>. To know more about ELK stack or in general how to use ELK stack to design your own Log analytic solutions please read the book.<a href="https://saurzcode.in//wp-content/uploads/2015/12/Learning-Elk.png"><img class="alignright wp-image-1002" src="https://saurzcode.in//wp-content/uploads/2015/12/Learning-Elk-250x300.png" alt="Learning Elk" width="140" height="168"></a>

You can purchase the book on Amazon here – <a href="http://www.amazon.in/gp/product/B0146WY5QM/ref=as_li_tl?ie=UTF8&amp;camp=3626&amp;creative=24822&amp;creativeASIN=B0146WY5QM&amp;linkCode=as2&amp;tag=saurzcode-21" target="_blank" rel="noopener noreferrer">Learning ELK Stack Book on Amazon</a>&nbsp; &nbsp;or from the Publisher itself –&nbsp;<a href="https://www.packtpub.com/big-data-and-business-intelligence/learning-elk-stack" target="_blank" rel="noopener noreferrer">Learning ELK Stack Book on PacktPub</a>