---
id: 944
title: 'Unix Job Control Commands &#8211; bg, fg, Ctrl+Z,jobs'
date: '2015-06-21T21:58:36-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in//?p=944'
permalink: /2015/06/unix-background-job-management-bg-fg-ctrlzjobs/
meta-checkbox:
    - ''
dsq_thread_id:
    - '3868180595'
categories:
    - 'Big Data'
    - Technology
tags:
    - bg
    - fg
    - hadoop
    - jobs
    - 'process management'
    - unix
---

Since Hadoop jobs are often long running, its difficult for newbies to manage the processes in Unix unless they know some useful Unix commands to do so, so that they can increase their efficiency.

In this post, I will explain some of the commands that are very useful while executing some long running jobs .We will see how to execute a job in background, bring it back to foreground, stopping the execution and starting it back and kill a job.

<!--more-->
<h2>Executing a Job in background</h2>
Just append <span style="color: #0000ff;"><i><b>&amp;</b></i> </span>at the end of any command to put the execution of that command in background.

For example -
```sh
$ hadoop jar examples.jar param1 param2 &
```
We can see all the jobs running in background by executing <span style="color: #0000ff;"><i><b>jobs</b></i><i> </i></span>command.
```sh
$jobs

[1] Running      hadoop jar examples.jar param1 param2 &
```
<h2>Jobs Command</h2>
When we run jobs command it gives a list of all the jobs with their status. The general syntax of output is -
```sh
[job_id] +/- <status> command
```
<b>job_id</b> is id of the current job.

<b>status</b> represents the status of the job and can be one of RUNNING, STOPPED, EXIT, and DONE.

The character <b>'+'</b>  represents the job which will be used as default in <b>bg and fg commands</b>.

The character <b>'-'</b> represents the job which would become default when current default job exits.

For example -
```sh
[1]   Running                 tar -zxvf file.tar.gz ../path/ &
[2]-  Running                 tar -zxvf file2.tar.gz ../path2 &
[3]+  Running                 tar -zxvf file3.tar.gz ../path3/ &
```
<h2>fg command</h2>
Also, we can bring the job in foreground with <span style="color: #0000ff;"><i><b>fg</b></i> command. <span style="color: #000000;">When executed without any argument, it will bring most recent background job in foreground.</span></span>
```sh
$fg
```
Now, if job is running in foreground and you want to stop the execution of job, without killing it, press <span style="color: #3366ff;"><i><b>Ctrl-Z</b></i></span> on keyboard and you will see an output like this -
```sh
[1]   STOPPED                 tar -zxvf file.tar.gz ../path/ &
```
<h2>bg command</h2>
Now, current status of job is STOPPED, we can again start the job in background using it's job_id using<span style="color: #3366ff;"><i><b> bg command.</b></i></span>
```sh
$ bg %1
```
And , you can again see job running in background using jobs.
```sh
$jobs
[1]   Running                 tar -zxvf file.tar.gz ../path/ &
```
<h2>Killing a Job</h2>
We can kill a running job using kill command with it's job_id.

For example -
```sh
$ kill %1

[1]   Exit                tar -zxvf file.tar.gz ../path/ &
```
That's it !! In the upcoming posts , we will see about how we can execute  job in background even when we are logged out of system using <i><b>nohup</b></i><i> </i>command.



Interesting Reads -

<a href="https://wp.me/p5pWDa-iX">Multithreaded Mappers in MapReduce</a>