---
id: 1247
title: 'Spark &#8211; How to Run Spark Applications on Windows'
date: '2019-09-14T22:24:39-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in/?p=1247'
permalink: /2019/09/running-spark-application-on-windows/
meta-checkbox:
    - ''
image: /wp-content/uploads/2017/10/spark-logo.png
categories:
    - 'Big Data'
    - Scala
    - Spark
    - Technology
tags:
    - apache-spark
    - 'big data'
    - spark
    - 'spark on windows'
    - winutils.exe
---

<!-- wp:paragraph -->
<p>Whether you want to unit test your Spark Scala application using Scala Tests or want to run some Spark application on Windows, you need to perform a few basics settings and configurations before you do so. In this post, I will explain the configurations that will help you start your journey to run your spark application seamlessly on your windows machines. Let's get started -</p>
<!-- /wp:paragraph -->

<!-- wp:quote -->
<blockquote class="wp-block-quote">
<p><span style="color: #993300;">First, note that you don't need Hadoop installation in your windows machine to run Spark. You need a way to use POSIX like file access operations in windows which is implemented using <strong>winutils.exe</strong> using some Windows APIs.</span></p>
</blockquote>
<!-- /wp:quote -->

<!-- wp:paragraph -->
<p><strong>Step 1</strong>. Download <strong>winutils.exe</strong> binary from this link - <a href="https://github.com/steveloughran/winutils">https://github.com/steveloughran/winutils</a>,<span style="font-size: 1em;"> and place it on a folder like this - - <strong>C:/hadoop/bin</strong>, make sure you are downloading the same version as on which your Spark version is compiled against. You can check the version of Hadoop your spark version was compiled with using pom of spark binary you are using - <a href="https://search.maven.org/artifact/org.apache.spark/spark-parent_2.11/2.4.4/pom">https://search.maven.org/artifact/org.apache.spark/spark-parent_2.11/2.4.4/pom</a></span></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Step 2</strong>. set <strong>HADOOP_HOME</strong> and PATH - In your environment variables either using Control Panel ( available to all apps - recommended option) or on command prompt ( for the current session) -  set <strong>HADOOP_HOME</strong> as <strong>C:/hadoop</strong> or the path inside which you created bin directory where winutils.exe is present.</p>
<!-- /wp:paragraph -->

<!-- wp:more -->
<p><!--more--></p>
<!-- /wp:more -->

<!-- wp:code {"className":"highlight"} -->
<pre class="wp-block-code highlight"><code>set HADOOP_HOME=c:/hadoop</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>Next is to add <strong>%HADOOP_HOME%/bin</strong> to the <strong>PATH</strong>.</p>
<!-- /wp:paragraph -->

<!-- wp:code {"className":"highlight"} -->
<pre class="wp-block-code highlight"><code>set PATH=%HADOOP_HOME%/bin;%PATH%</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>That's all !!</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Now you can run any spark app on your local windows machine in IntelliJ, Eclipse, or in spark-shell. Please comment below for any issues!</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>More Spark Posts - </strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><a href="https://saurzcode.in/2019/09/skipped-stages-spark-webui/">What does Skipped Stage mean in Spark WebUI?</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><a href="https://saurzcode.in/2018/06/spark-common-dataframe-operations/">Dataframe Operations in Spark using Scala</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><a href="https://saurzcode.in/2017/10/configure-spark-application-eclipse/">How to Configure Spark Application ( Scala and Java 8 Version with Maven ) in Eclipse.</a></p>
<!-- /wp:paragraph -->