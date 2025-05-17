---
id: 118
title: 'Top 10 Hadoop Shell Commands to manage HDFS'
date: '2013-10-27T22:32:09-07:00'
author: saurzcode
layout: single
guid: 'https://saurzcode.in//?p=118'
permalink: /2013/10/hdfs-shell-commands/
publicize_google_plus_url:
    - 'https://plus.google.com/107786853692055665005/posts/M9GxbHzMZsA'
geo_public:
    - '0'
publicize_linkedin_url:
    - 'http://www.linkedin.com/updates?discuss=&scope=23596248&stype=M&topic=5883662733584400384&type=U&a=mXcu'
dsq_thread_id:
    - '3280625624'
meta-checkbox:
    - ''
ampforwp_custom_content_editor:
    - ''
ampforwp_custom_content_editor_checkbox:
    - ''
ampforwp-amp-on-off:
    - default
image: /wp-content/uploads/2013/10/hadoop-hdfs-post.jpg
categories:
    - 'Big Data'
    - Technology
tags:
    - 'big data'
    - cloud
    - hadoop
    - hdfs
    - 'high availability'
    - scalable
    - storage
---

So you already know what *Hadoop* is? Why it is used for? What problems you can solve with it? And you want to know how you can deal with files on *HDFS*? Don't worry, you are in the right place.

In this article I will present **Top 10 basic Hadoop HDFS operations managed through shell commands** which are useful to manage files on *HDFS* clusters. For testing purposes, you can invoke these commands using either some of the VMs from *Cloudera*, *Hortonworks*, etc., or if you have your own setup of a pseudo-distributed cluster.

Let's get started.

## 1. Create a directory in HDFS at the given path(s).

**Usage:**
```
hadoop fs -mkdir <paths>
```
**Example:**
```
hadoop fs -mkdir /user/saurzcode/dir1 /user/saurzcode/dir2
```

## 2. List the contents of a directory.

**Usage:**
```
hadoop fs -ls <args>
```
**Example:**
```
hadoop fs -ls /user/saurzcode
```

## 3. Upload and download a file in HDFS.

### Upload
**hadoop fs -put:**

Copy a single src file, or multiple src files from local file system to the Hadoop data file system

**Usage:**
```
hadoop fs -put <localsrc> ... <HDFS_dest_Path>
```
**Example:**
```
hadoop fs -put /home/saurzcode/Samplefile.txt /user/saurzcode/dir3/
```

### Download
**hadoop fs -get:**

Copies/Downloads files to the local file system

**Usage:**
```
hadoop fs -get <hdfs_src> <localdst>
```
**Example:**
```
hadoop fs -get /user/saurzcode/dir3/Samplefile.txt /home/
```

## 4. See contents of a file

Same as UNIX cat command:

**Usage:**
```
hadoop fs -cat <path[filename]>
```
**Example:**
```
hadoop fs -cat /user/saurzcode/dir1/abc.txt
```

## 5. Copy a file from source to destination

This command allows multiple sources as well in which case the destination must be a directory.

**Usage:**
```
hadoop fs -cp <source> <dest>
```
**Example:**
```
hadoop fs -cp /user/saurzcode/dir1/abc.txt /user/saurzcode/dir2
```

## 6. Copy a file from/To Local file system to HDFS

### copyFromLocal
**Usage:**
```
hadoop fs -copyFromLocal <localsrc> URI
```
**Example:**
```
hadoop fs -copyFromLocal /home/saurzcode/abc.txt /user/saurzcode/abc.txt
```
Similar to `put` command, except that the source is restricted to a local file reference.

### copyToLocal
**Usage:**
```
hadoop fs -copyToLocal [-ignorecrc] [-crc] URI <localdst>
```
Similar to `get` command, except that the destination is restricted to a local file reference.

## 7. Move files from source to destination.

Note: Moving files across the filesystem is not permitted.

**Usage:**
```
hadoop fs -mv <src> <dest>
```
**Example:**
```
hadoop fs -mv /user/saurzcode/dir1/abc.txt /user/saurzcode/dir2
```

## 8. Remove a file or directory in HDFS.

Remove files specified as argument. Deletes directory only when it is empty

**Usage:**
```
hadoop fs -rm <arg>
```
**Example:**
```
hadoop fs -rm /user/saurzcode/dir1/abc.txt
```

### The recursive version of delete.
**Usage:**
```
hadoop fs -rmr <arg>
```
**Example:**
```
hadoop fs -rmr /user/saurzcode/
```

## 9. Display the last few lines of a file.

Similar to tail command in Unix.

**Usage:**
```
hadoop fs -tail <path[filename]>
```
**Example:**
```
hadoop fs -tail /user/saurzcode/dir1/abc.txt
```

## 10. Display the aggregate length of a file.

**Usage:**
```
hadoop fs -du <path>
```
**Example:**
```
hadoop fs -du /user/saurzcode/dir1/abc.txt
```

---

Please comment on which of these commands you found most useful while dealing with Hadoop /HDFS.

Reference: [https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html)

---

## Related articles

- [How to become Hadoop Certified Developer?](https://saurzcode.in//2014/05/31/hadoop-certifications/)
- [Free Online Hadoop Trainings](https://saurzcode.in//2014/04/21/free-online-hadoop-trainings/)
- [Reading List: Hadoop and Big Data Books](https://saurzcode.in//2014/06/01/reading-list-hadoop/)
- [Recommended Readings for Hadoop](https://saurzcode.in//2014/02/04/recommended-readings-for-hadoop/)
