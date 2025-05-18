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
image: assets/uploads/2017/10/spark-logo.png
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

Whether you want to unit test your Spark Scala application using Scala Tests or want to run some Spark application on Windows, you need to perform a few basics settings and configurations before you do so. In this post, I will explain the configurations that will help you start your journey to run your spark application seamlessly on your windows machines. Let's get started -

> First, note that you don't need Hadoop installation in your windows machine to run Spark. You need a way to use POSIX like file access operations in windows which is implemented using **winutils.exe** using some Windows APIs.

**Step 1**. Download **winutils.exe** binary from this link - [https://github.com/steveloughran/winutils](https://github.com/steveloughran/winutils), and place it on a folder like this - - **C:/hadoop/bin**, make sure you are downloading the same version as on which your Spark version is compiled against. You can check the version of Hadoop your spark version was compiled with using pom of spark binary you are using - [https://search.maven.org/artifact/org.apache.spark/spark-parent\_2.11/2.4.4/pom](https://search.maven.org/artifact/org.apache.spark/spark-parent_2.11/2.4.4/pom)

**Step 2**. set **HADOOP\_HOME** and PATH - In your environment variables either using Control Panel ( available to all apps - recommended option) or on command prompt ( for the current session) -  set **HADOOP\_HOME** as **C:/hadoop** or the path inside which you created bin directory where winutils.exe is present.

    set HADOOP_HOME=c:/hadoop

Next is to add **%HADOOP\_HOME%/bin** to the **PATH**.

    set PATH=%HADOOP_HOME%/bin;%PATH%

That's all !!

Now you can run any spark app on your local windows machine in IntelliJ, Eclipse, or in spark-shell. Please comment below for any issues!

**More Spark Posts -** 

[What does Skipped Stage mean in Spark WebUI?](https://saurzcode.in/2019/09/skipped-stages-spark-webui/)

[Dataframe Operations in Spark using Scala](https://saurzcode.in/2018/06/spark-common-dataframe-operations/)

[How to Configure Spark Application ( Scala and Java 8 Version with Maven ) in Eclipse.](https://saurzcode.in/2017/10/configure-spark-application-eclipse/)