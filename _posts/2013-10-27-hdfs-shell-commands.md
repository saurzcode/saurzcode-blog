---
id: 118
title: 'Top 10 Hadoop Shell Commands to manage HDFS'
date: '2013-10-27T22:32:09-07:00'
author: saurzcode
layout: post
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

<div dir="ltr">
<blockquote>So you already know what <em>Hadoop</em> is? Why it is used for ? and  What problems you can solve with it?  and you want to know how you can deal with files on <em>HDFS</em>?  Don't worry, you are in the right place.</blockquote>
In this article I will present Top 10 basic <em>Hadoop HDFS</em> operations managed through shell commands which are useful to manage files on <em>HDFS</em> clusters, For testing purposes, you can invoke this commands using either some of the VMs from <em>Cloudera</em>, <em>Hortonworks</em> etc or if you have your own setup of a pseudo-distributed cluster.

Let's get started.

<strong><span style="color: #993366;">1. Create a directory in HDFS at the given path(s).</span></strong>
<pre>Usage:
hadoop fs -mkdir &lt;paths&gt;
Example:
hadoop fs -mkdir /user/saurzcode/dir1 /user/saurzcode/dir2</pre>
<span style="color: #993366;"><strong>2.  List the contents of a directory.</strong></span>
<pre>Usage :
hadoop fs -ls &lt;args&gt;
Example:
hadoop fs -ls /user/saurzcode</pre>
<strong><span style="color: #993366;">3. Upload and download a file in HDFS.</span></strong>

<span style="text-decoration: underline;"><em>Upload</em></span>:

<strong>hadoop fs -put:</strong>

Copy a single src file, or multiple src files from local file system to the Hadoop data file system
<pre>Usage:
hadoop fs -put &lt;localsrc&gt; ... &lt;HDFS_dest_Path&gt;
Example:
hadoop fs -put /home/saurzcode/Samplefile.txt  /user/saurzcode/dir3/</pre>
<span style="text-decoration: underline;"><em>Download:</em></span>

<strong>hadoop fs -get:</strong>

Copies/Downloads files to the local file system
<pre>Usage:
hadoop fs -get &lt;hdfs_src&gt; &lt;localdst&gt;
Example:
hadoop fs -get /user/saurzcode/dir3/Samplefile.txt /home/</pre>
<span style="color: #993366;"><strong>4. See contents of a file</strong></span>

Same as UNIX cat command:
<pre>Usage:
hadoop fs -cat &lt;path[filename]&gt;
Example:
hadoop fs -cat /user/saurzcode/dir1/abc.txt</pre>
<span style="color: #993366;"><strong>5. Copy a file from source to destination</strong></span>

This command allows multiple sources as well in which case the destination must be a directory.
<pre>Usage:
hadoop fs -cp &lt;source&gt; &lt;dest&gt;
Example:
hadoop fs -cp /user/saurzcode/dir1/abc.txt /user/saurzcode/dir2</pre>
<span style="color: #993366;"><strong>6. Copy a file from/To Local file system to HDFS </strong></span>

<strong>copyFromLocal</strong>
<pre>Usage:
hadoop fs -copyFromLocal &lt;localsrc&gt; URI
Example:
hadoop fs -copyFromLocal /home/saurzcode/abc.txt  /user/saurzcode/abc.txt</pre>
Similar to put command, except that the source is restricted to a local file reference.

<strong>copyToLocal</strong>
<pre>Usage:
hadoop fs -copyToLocal [-ignorecrc] [-crc] URI &lt;localdst&gt;</pre>
Similar to get command, except that the destination is restricted to a local file reference.

<span style="color: #993366;"><strong>7. Move files from source to destination.</strong></span>

Note:- Moving files across the filesystem is not permitted.
<pre>Usage :
hadoop fs -mv &lt;src&gt; &lt;dest&gt;
Example:
hadoop fs -mv /user/saurzcode/dir1/abc.txt /user/saurzcode/dir2</pre>
<span style="color: #993366;"><strong>8. Remove a file or directory in HDFS.</strong></span>

Remove files specified as argument. Deletes directory only when it is empty
<pre>Usage :
hadoop fs -rm &lt;arg&gt;
Example:
hadoop fs -rm /user/saurzcode/dir1/abc.txt</pre>
<span style="text-decoration: underline;"><em>The recursive version of delete.</em></span>
<pre>Usage :
hadoop fs -rmr &lt;arg&gt;
Example:
hadoop fs -rmr /user/saurzcode/</pre>
<strong><span style="color: #993366;">9. Display the last few lines of a file.</span></strong>

Similar to tail command in Unix.
<pre>Usage :
hadoop fs -tail &lt;path[filename]&gt;
Example:
hadoop fs -tail /user/saurzcode/dir1/abc.txt</pre>
<strong><span style="color: #993366;">10. Display the aggregate length of a file.</span></strong>
<pre>Usage :
hadoop fs -du &lt;path&gt;
Example:
hadoop fs -du /user/saurzcode/dir1/abc.txt</pre>
&nbsp;

Please comment on which of these commands you found most useful while dealing with Hadoop /HDFS.

</div>
Reference - <a href="https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html" target="_blank" rel="noopener noreferrer">https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html</a>
<div dir="ltr">

<hr />

<span style="text-decoration: underline;"><em><strong>Related articles : </strong></em></span>
<ul>
 	<li><em><span style="text-decoration: underline;"><a title="How to Become a Hadoop Certified Developer ?" href="https://saurzcode.in//2014/05/31/hadoop-certifications/" target="_blank" rel="noopener noreferrer"><span style="text-decoration: underline; color: #3366ff;">How to become Hadoop Certified Developer?</span></a></span></em></li>
 	<li><a title="Getting Started with Hadoop : Free Online Hadoop Trainings" href="https://saurzcode.in//2014/04/21/free-online-hadoop-trainings/" target="_blank" rel="noopener noreferrer"><em><span style="color: #3366ff; text-decoration: underline;">Free Online Hadoop Trainings</span></em></a></li>
 	<li><a title="Reading List : Hadoop and Big Data Books" href="https://saurzcode.in//2014/06/01/reading-list-hadoop/" target="_blank" rel="noopener noreferrer"><em><span style="color: #3366ff; text-decoration: underline;">Reading List: Hadoop and Big Data Books</span></em></a></li>
 	<li><em><span style="text-decoration: underline;"><a title="Recommended Readings for Hadoop" href="https://saurzcode.in//2014/02/04/recommended-readings-for-hadoop/" target="_blank" rel="noopener noreferrer"><span style="color: #3366ff; text-decoration: underline;">Recommended Readings for Hadoop</span></a></span></em></li>
</ul>
</div>