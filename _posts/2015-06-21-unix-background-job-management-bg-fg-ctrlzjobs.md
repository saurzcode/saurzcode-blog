---
id: 944
title: 'Unix Job Control Commands &#8211; bg, fg, Ctrl+Z,jobs'
date: '2015-06-21T21:58:36-07:00'
author: saurzcode

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

# Unix Job Control Commands: `bg`, `fg`, `Ctrl+Z`, `jobs`

A practical guide for developers and data engineers to manage long-running jobs in Unix, especially useful when working with Hadoop or other big data tools.

---

## Table of Contents

- [Unix Job Control Commands: `bg`, `fg`, `Ctrl+Z`, `jobs`](#unix-job-control-commands-bg-fg-ctrlz-jobs)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Running a Job in the Background](#running-a-job-in-the-background)
  - [Listing Background Jobs: `jobs` Command](#listing-background-jobs-jobs-command)
  - [Bringing a Job to Foreground: `fg` Command](#bringing-a-job-to-foreground-fg-command)
  - [Stopping a Foreground Job: `Ctrl+Z`](#stopping-a-foreground-job-ctrlz)
  - [Resuming a Stopped Job in Background: `bg` Command](#resuming-a-stopped-job-in-background-bg-command)
  - [Killing a Job: `kill` Command](#killing-a-job-kill-command)
  - [Summary Table](#summary-table)
  - [Further Reading](#further-reading)

---

## Introduction

When running long Hadoop or other data processing jobs on Unix, it's important to know how to manage processes efficiently. This guide covers essential Unix job control commands to help you:

- Run jobs in the background
- Bring jobs to the foreground
- Pause and resume jobs
- List and kill jobs

---

## Running a Job in the Background

To run any command in the background, append `&` at the end:

```sh
hadoop jar examples.jar param1 param2 &
```

This allows you to continue using the terminal while the job runs.

---

## Listing Background Jobs: `jobs` Command

To see all jobs running in the background:

```sh
jobs
```

Example output:

```sh
[1] Running      hadoop jar examples.jar param1 param2 &
```

- `[1]` is the job ID
- `Running` is the status
- The command is shown at the end

The output format is:

```sh
[job_id] +/- <status> command
```

- `+` marks the default job for `fg`/`bg`
- `-` marks the next default if the current one exits

Example with multiple jobs:

```sh
[1]   Running                 tar -zxvf file.tar.gz ../path/ &
[2]-  Running                 tar -zxvf file2.tar.gz ../path2 &
[3]+  Running                 tar -zxvf file3.tar.gz ../path3/ &
```

---

## Bringing a Job to Foreground: `fg` Command

To bring the most recent background job to the foreground:

```sh
fg
```

To bring a specific job (e.g., job 1):

```sh
fg %1
```

---

## Stopping a Foreground Job: `Ctrl+Z`

If a job is running in the foreground and you want to pause (stop) it without killing it, press:

```
Ctrl+Z
```

You'll see output like:

```sh
[1]   STOPPED                 tar -zxvf file.tar.gz ../path/ &
```

---

## Resuming a Stopped Job in Background: `bg` Command

To resume a stopped job in the background (e.g., job 1):

```sh
bg %1
```

Check status again:

```sh
jobs
[1]   Running                 tar -zxvf file.tar.gz ../path/ &
```

---

## Killing a Job: `kill` Command

To kill a running or stopped job (e.g., job 1):

```sh
kill %1
```

Example output:

```sh
[1]   Exit                tar -zxvf file.tar.gz ../path/ &
```

---

## Summary Table

| Command         | Description                                      |
|----------------|--------------------------------------------------|
| `jobs`         | List all background jobs                         |
| `fg [%job_id]` | Bring job to foreground                          |
| `bg [%job_id]` | Resume stopped job in background                 |
| `kill [%job_id]`| Kill a job                                      |
| `Ctrl+Z`       | Pause (stop) a foreground job                    |
| `&`            | Run a command in the background                  |

---

## Further Reading

- [Multithreaded Mappers in MapReduce](https://wp.me/p5pWDa-iX)

In upcoming posts, we'll cover how to keep jobs running even after logout using `nohup`.