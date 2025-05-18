---
id: 1122
title: 'What does Skipped Stage means in Spark WebUI ?'
date: '2019-09-14T19:38:21-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in/?p=1122'
permalink: /2019/09/skipped-stages-spark-webui/
meta-checkbox:
    - ''
image: assets/uploads/2019/09/Screenshot-2019-09-14-at-7.24.39-PM.png
categories:
    - 'Big Data'
    - Scala
    - Spark
tags:
    - apache-spark
    - bigdata
    - spark
    - 'spark interview'
---

## Skipped Stages in Spark UI


You must have come across various scenarios where you see a DAG like below, where you see a few stages shows greyed out with a text (skipped) after the stage name. What does this mean? Did Spark ignore one of your stage due to an error? or this is due to something else? Well, it's actually a good thing. It means that particular stage in the lineage DAG doesn't need to be re-evaluated as its already evaluated and cached. This will save computation time for that stage. If you want to see what data frame for that stage was stored in the cache, you can check in Storage tab in Spark UI.

[caption id="attachment\_1245" align="aligncenter" width="1330"]![spark webui](http://saurzcode.in/assets/uploads/2019/09/Screenshot-2019-09-14-at-7.24.39-PM.png) Skipped Stages in Spark Web UI[caption]   

**Reference** - https://stackoverflow.com/questions/34580662/what-does-stage-skipped-mean-in-apache-spark-web-ui [https://github.com/apache/spark/pull/3009](https://github.com/apache/spark/pull/3009) 

**More Spark Articles -**  [What is RDD in Spark ? and Why do we need it ?](https://saurzcode.in/2015/10/what-is-rdd-in-spark-and-why-do-we-need-it/) [How to Configure Spark Application ( Scala and Java 8 Version with Maven ) in Eclipse.](https://saurzcode.in/2017/10/configure-spark-application-eclipse/)