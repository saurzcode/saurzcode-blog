---
id: 1517
title: 'How to Train and Score Catboost Model on Spark'
date: '2021-05-02T09:36:43-07:00'
author: saurzcode

guid: 'https://saurzcode.in/?p=1517'
permalink: /2021/05/how-to-train-and-score-catboost-model-on-spark/
meta-checkbox:
    - ''
classic-editor-remember:
    - classic-editortegories:
    - 'Big Data'
    - Scala
    - Spark
    - Technology
tags:
    - catboost
    - spark
---

# How to Train and Score CatBoost Model on Spark

A practical, developer-focused guide to distributed training and inference with CatBoost on Apache Spark, including code examples and best practices.

<!--more-->
---

## Table of Contents

- [How to Train and Score CatBoost Model on Spark](#how-to-train-and-score-catboost-model-on-spark)
  - [Table of Contents](#table-of-contents)
  - [About CatBoost](#about-catboost)
  - [Distributed CatBoost Training on Spark](#distributed-catboost-training-on-spark)
  - [Key Features and Limitations](#key-features-and-limitations)
  - [Getting Started: Setup and Dependencies](#getting-started-setup-and-dependencies)
  - [Example: Training and Scoring a CatBoost Model](#example-training-and-scoring-a-catboost-model)
    - [Training a Binary Classification Model](#training-a-binary-classification-model)
    - [Saving the Model](#saving-the-model)
    - [Feature Importance](#feature-importance)
  - [References \& Further Reading](#references--further-reading)

---

## About CatBoost

[CatBoost](https://catboost.ai/) (by Yandex) is a high-performance, open-source gradient boosting library. It is popular for:

- Native support for categorical features (no need for manual encoding)
- Fast and accurate predictions
- Minimal parameter tuning required
- Widely used for ranking, recommendation, classification, and regression tasks

Previously, CatBoost supported training only in Python and R, but could make predictions in Java, Python, C++, and R.

---

## Distributed CatBoost Training on Spark

Distributed training for large datasets was limited to GPU or single-node CPU setups. Now, CatBoost provides a Spark package for distributed training and inference, following the Spark MLlib API and supporting Spark ML Pipelines.

- **Official Spark package:** [catboost4j-spark](https://github.com/catboost/catboost/tree/master/catboost/spark/catboost4j-spark)
- **Supported Spark versions:** 2.3–3.0
- **Supported Scala versions:** 2.11–2.12
- **Works with both Scala Spark and PySpark**

---

## Key Features and Limitations

**Features:**
- Distributed training for binary, multiclass classification, and regression
- Save models in Spark MLlib or CatBoost native format (`.cbm`)
- Feature importance calculation
- Distributed prediction/inference

**Limitations:**
- No support for text and embedding features (as of now)

---

## Getting Started: Setup and Dependencies

Add the CatBoost Spark dependency to your Maven `pom.xml`:

```xml
<dependency>
  <groupId>ai.catboost</groupId>
  <artifactId>catboost-spark_2.4_2.12</artifactId>
  <version>0.25</version>
</dependency>
```

For a full working example and all dependencies, see the [GitHub sample project](https://github.com/saurzcode/catboost-spark-examples).

---

## Example: Training and Scoring a CatBoost Model

### Training a Binary Classification Model

```scala
import org.apache.spark.ml.linalg.Vectors
import org.apache.spark.sql.{Row, SparkSession}
import org.apache.spark.sql.types._
import ai.catboost.spark._

val srcDataSchema = Seq(
  StructField("features", SQLDataTypes.VectorType),
  StructField("label", StringType)
)

// Training data
val trainData = Seq(
  Row(Vectors.dense(0.11, 0.22, 0.13, 0.45, 0.89), "0"),
  Row(Vectors.dense(0.99, 0.82, 0.33, 0.89, 0.97), "1"),
  Row(Vectors.dense(0.12, 0.21, 0.23, 0.42, 0.24), "1"),
  Row(Vectors.dense(0.81, 0.63, 0.02, 0.55, 0.65), "0")
)
val spark = SparkSession.builder().getOrCreate()
val trainDf = spark.createDataFrame(spark.sparkContext.parallelize(trainData), StructType(srcDataSchema))
val trainPool = new Pool(trainDf)

// Evaluation data
val evalData = Seq(
  Row(Vectors.dense(0.22, 0.34, 0.9, 0.66, 0.99), "1"),
  Row(Vectors.dense(0.16, 0.1, 0.21, 0.67, 0.46), "0"),
  Row(Vectors.dense(0.78, 0.0, 0.0, 0.22, 0.12), "1")
)
val evalDf = spark.createDataFrame(spark.sparkContext.parallelize(evalData), StructType(srcDataSchema))
val evalPool = new Pool(evalDf)

val classifier = new CatBoostClassifier
val model: CatBoostClassificationModel = classifier.fit(trainPool, Array(evalPool))

// Apply model
val predictions = model.transform(evalPool.data)
predictions.show(false)
```

**Output columns:**
- `rawPredictions`: Confidence scores for each class
- `probability`: Sigmoid of raw predictions (class probabilities)
- `prediction`: Predicted class (0 or 1)

---

### Saving the Model

```scala
// Save model in Spark MLlib format
val savedModelPath = "models/binclass_model"
model.write.overwrite().save(savedModelPath)

// Save model in CatBoost native format
val savedNativeModelPath = "models/binclass_model.cbm"
model.saveNativeModel(savedNativeModelPath)
```

---

### Feature Importance

```scala
val loadedModel = CatBoostClassificationModel.loadNativeModel("models/binclass_model.cbm")
val featureImportance = loadedModel.getFeatureImportancePrettified()
featureImportance.foreach(fi => println(s"[${fi.featureName}, ${fi.importance}]") )
```

**Sample Output:**
```
[2,47.26]
[4,30.27]
[1,12.31]
[3,10.16]
[0,0.0]
```

---

## References & Further Reading

- [CatBoost for Apache Spark introduction (YouTube)](https://www.youtube.com/watch?v=47-mAVms-b8)
- [CatBoost for Apache Spark Architecture (YouTube)](https://www.youtube.com/watch?v=nrGt5VKZpzc)
- [CatBoost Spark Examples (GitHub)](https://github.com/saurzcode/catboost-spark-examples)
- [CatBoost Spark Documentation](https://catboost.ai/docs/en/concepts/spark-quickstart-scala)