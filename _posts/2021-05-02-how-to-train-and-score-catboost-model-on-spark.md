---
id: 1517
title: 'How to Train and Score Catboost Model on Spark'
date: '2021-05-02T09:36:43-07:00'
author: saurzcode
layout: medium
guid: 'https://saurzcode.in/?p=1517'
permalink: /2021/05/how-to-train-and-score-catboost-model-on-spark/
meta-checkbox:
    - ''
classic-editor-remember:
    - classic-editor
image: assets/uploads/2021/05/Untitledc.png
categories:
    - 'Big Data'
    - Scala
    - Spark
    - Technology
tags:
    - catboost
    - spark
---

<h2>About CatBoost</h2>
<a href="https://catboost.ai/">Catboost</a> (developed by Yandex)  is one of the great open-source gradient boosting libraries with great performance without a lot of additional tuning. It provides support for categorical features without any need for encoding etc. and predictions are pretty fast as well. No wonder its one of the algorithm which is increasingly popular among data scientists community for a lot of ranking, recommendation, classification and regression problems.

Till now, Catboost supported training only in Python and R and predictions (applying the model) on a multitude of languages - Java( JVM-Packages), Python, C++, and R.
<h3>Distributed CatBoost Training<img class="wp-image-1539 alignright" src="https://saurzcode.in/assets/uploads/2021/05/Untitledc.png" alt="catboost-spark" width="293" height="220" /></h3>
There was limited support to train the model in a distributed manner for a big data set on CPU except for some support via GPU training. Catboost team at Yandex started working on the Spark version of the Catboost for the training and inference and they have recently <a href="https://github.com/catboost/catboost/tree/master/catboost/spark/catboost4j-spark">released</a> the spark version and is available in the maven repository to use. Catboost Spark Implementation follows general Spark MLLib implementations and supports Spark ML Pipelines etc.

It supports the following functionalities as of now -
<ul>
 	<li>Support for Spark 2.3-3.0 and Scala 2.11-2.12</li>
 	<li>Support for both Scala Spark and PySpark</li>
 	<li>Distributed Training for Binary Classification, MultiClass Classification, and Regression.</li>
 	<li>Save trained model in Spark MLLib Serialization Format or Catboost Native Format (.cbm) files.</li>
 	<li>Get Feature Importance for the CatBoost Models.</li>
 	<li>Prediction/Inference over Spark for the Catboost Models.</li>
</ul>
<strong>Limitations</strong> - As of now, it doesn't support training for  Text and Embedding Features, which might not be a big deal for a large number of users.

I highly recommend going over videos explaining the implementation in more detail from CatBoost Team- <a href="https://www.youtube.com/watch?v=47-mAVms-b8" rel="nofollow">CatBoost for Apache Spark introduction</a> and <a href="https://www.youtube.com/watch?v=nrGt5VKZpzc" rel="nofollow">CatBoost for Apache Spark Architecture</a>.

I thought of giving it a try on some of the models and find below the snapshot of how this can be used  for Spark and full source code is available here at my GitHub link - <a href="https://github.com/saurzcode/catboost-spark-examples">https://github.com/saurzcode/catboost-spark-examples</a>

You just need to add this dependency in your POM and you should be okay, please look at GitHub sample above for all set of dependencies needed for end to end spark code -
<pre class="EnlighterJSRAW" data-enlighter-language="xml" data-enlighter-theme="dracula">&lt;dependency&gt;    
  &lt;groupId&gt;ai.catboost&lt;/groupId&gt;    
  &lt;artifactId&gt;catboost-spark_2.4_2.12&lt;/artifactId&gt;    
  &lt;version&gt;0.25&lt;/version&gt;
&lt;/dependency&gt;</pre>
And then we can use CatBoost classes below in spark code to train or score the model as follows.
<h5>Catboost Binary Classification Model -</h5>
<pre class="EnlighterJSRAW" data-enlighter-language="scala" data-enlighter-theme="dracula">val srcDataSchema = Seq(  StructField("features", SQLDataTypes.VectorType),  StructField("label", StringType))

//training data containing features and label.
val trainData = Seq(  Row(Vectors.dense(0.11, 0.22, 0.13, 0.45, 0.89), "0"),  Row(Vectors.dense(0.99, 0.82, 0.33, 0.89, 0.97), "1"),  Row(Vectors.dense(0.12, 0.21, 0.23, 0.42, 0.24), "1"),  Row(Vectors.dense(0.81, 0.63, 0.02, 0.55, 0.65), "0"))

val trainDf = spark.createDataFrame(spark.sparkContext.parallelize(trainData), StructType(srcDataSchema))

val trainPool = new Pool(trainDf)
//evaluation data containing features and label.
val evalData = Seq(  Row(Vectors.dense(0.22, 0.34, 0.9, 0.66, 0.99), "1"),  Row(Vectors.dense(0.16, 0.1, 0.21, 0.67, 0.46), "0"),  Row(Vectors.dense(0.78, 0.0, 0.0, 0.22, 0.12), "1"))

val evalDf = spark.createDataFrame(spark.sparkContext.parallelize(evalData), StructType(srcDataSchema))
val evalPool = new Pool(evalDf)
val classifier = new CatBoostClassifier // train model

val model: CatBoostClassificationModel = classifier.fit(trainPool, Array[Pool](evalPool))// apply model
val predictions: DataFrame = model.transform(evalPool.data)

println("predictions")

predictions.show(false)</pre>
<h6>Output</h6>
<h6><img class="aligncenter size-full wp-image-1537" src="https://saurzcode.in/assets/uploads/2021/05/Screenshot-2021-05-08-at-1.21.06-PM.png" alt="catboost-spark" width="2114" height="280" /></h6>
<strong>rawPredictions</strong> - confidence scores for each of the class for the classification model,

<strong>probability</strong> scores, which are sigmoid of raw predictions for each of the class and

<strong>prediction</strong> class of 0 or 1 basis probability of &gt;0.5 assigned as the probability of 1.
<h5>Saving the Model -</h5>
<pre class="EnlighterJSRAW" data-enlighter-language="scala" data-enlighter-theme="dracula">// save model  
val savedModelPath = "models/binclass_model"  
model.write.overwrite().save(savedModelPath)  // save model as local file in CatBoost native format  
val savedNativeModelPath = "models/binclass_model.cbm"  
model.saveNativeModel(savedNativeModelPath)</pre>
<h5>Catboost Model Feature Importance Calculation -</h5>
<pre class="EnlighterJSRAW" data-enlighter-language="scala" data-enlighter-theme="dracula">val loadedModel = CatBoostClassificationModel.loadNativeModel("models/binclass_model.cbm")
val featureImportance = loadedModel.getFeatureImportancePrettified()
featureImportance.foreach(fi =&gt; println("[" + fi.featureName + "," + fi.importance + "]"))</pre>
<h6>Output - Feature Importance % for each feature in the model.</h6>
<pre class="EnlighterJSRAW" data-enlighter-language="shell" data-enlighter-theme="dracula">[2,47.25978201414037][4,30.27449225598115][1,12.306202235604536][3,10.159523494273953][0,0.0]</pre>
&nbsp;

Please feel free to comment with any questions.

&nbsp;

<a href="https://saurzcode.in/2015/01/hive-sort-order-distribute-cluster/">Hive : SORT BY vs ORDER BY vs DISTRIBUTE BY vs CLUSTER BY</a>

<a href="https://saurzcode.in/2019/09/running-spark-application-on-windows/">Spark - How to Run Spark Applications on Windows</a>

&nbsp;