---
id: 1247
title: 'Spark &#8211; How to Run Spark Applications on Windows'
date: '2019-09-14T22:24:39-07:00'
author: saurzcode

guid: 'https://saurzcode.in/?p=1247'
permalink: /2019/09/running-spark-application-on-windows/
meta-checkbox:
    - ''
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

# Spark – How to Run Spark Applications on Windows

A step-by-step, developer-friendly guide to running Apache Spark applications on Windows, including configuration, environment setup, and troubleshooting tips.
<!--more-->
---

## Table of Contents

- [Spark – How to Run Spark Applications on Windows](#spark--how-to-run-spark-applications-on-windows)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Why You Don't Need Hadoop on Windows](#why-you-dont-need-hadoop-on-windows)
  - [Step 1: Download winutils.exe](#step-1-download-winutilsexe)
  - [Step 2: Set HADOOP\_HOME and PATH](#step-2-set-hadoop_home-and-path)
  - [Running Spark Applications](#running-spark-applications)
  - [Troubleshooting](#troubleshooting)

---

## Introduction

Whether you want to unit test your Spark Scala application or run Spark jobs locally on Windows, you need to perform a few basic configurations. This guide will help you set up your environment so you can run Spark applications seamlessly on your Windows machine.

---

## Why You Don't Need Hadoop on Windows

You do **not** need a full Hadoop installation to run Spark on Windows. Spark uses POSIX-like file operations, which are implemented on Windows using **winutils.exe** and some Windows APIs.

---

## Step 1: Download winutils.exe

- Download the `winutils.exe` binary from [https://github.com/steveloughran/winutils](https://github.com/steveloughran/winutils)
- Place it in a folder, e.g., `C:/hadoop/bin`
- Make sure you download the version of `winutils.exe` that matches the Hadoop version your Spark distribution was compiled against
    - You can check the Hadoop version in the Spark binary's POM file, e.g.:
      [https://search.maven.org/artifact/org.apache.spark/spark-parent_2.11/2.4.4/pom](https://search.maven.org/artifact/org.apache.spark/spark-parent_2.11/2.4.4/pom)

---

## Step 2: Set HADOOP_HOME and PATH

Set the following environment variables, either via the Windows Control Panel (recommended, for all apps) or in your command prompt (for the current session only):

```sh
set HADOOP_HOME=C:/hadoop
set PATH=%HADOOP_HOME%/bin;%PATH%
```

- `HADOOP_HOME` should point to the directory containing the `bin` folder with `winutils.exe`
- Add `%HADOOP_HOME%/bin` to your `PATH`

---

## Running Spark Applications

Now you can run any Spark application on your local Windows machine using IntelliJ, Eclipse, or the `spark-shell`.

- No Hadoop installation required
- Works for both development and unit testing

---

## Troubleshooting

- **winutils.exe not found:** Double-check that `winutils.exe` is in `C:/hadoop/bin` and that `HADOOP_HOME` and `PATH` are set correctly
- **Version mismatch:** Ensure the version of `winutils.exe` matches the Hadoop version your Spark build expects
- **Permissions errors:** Run your IDE or terminal as Administrator if you encounter file permission issues