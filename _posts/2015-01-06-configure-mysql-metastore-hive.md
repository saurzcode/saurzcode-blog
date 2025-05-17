---
id: 781
title: 'How-To : Configure MySQL Metastore for Hive ?'
date: '2015-01-06T23:16:44-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in//?p=781'
permalink: /2015/01/configure-mysql-metastore-hive/
meta-checkbox:
    - ''
dsq_thread_id:
    - '3490650038'
categories:
    - 'Big Data'
    - Hive
    - Java
    - Technology
tags:
    - bigdata
    - datawarehouse
    - hadoop
    - hive
    - metastore
    - mysql
---

Hive by default comes with Derby as its metastore storage, which is suited only for testing purposes and in most of the production scenarios it is recommended to use MySQL as a metastore. This is a step by step guide on How to Configure MySQL Metastore for Hive in place of Derby Metastore (Default).

<b>Assumptions :</b> Basic knowledge of Unix is assumed and also It's assumed that Hadoop and Hive configurations are in place.Hive with default metastore Derby is properly configured and tested out.
<ol>
	<li>Install  MySQL -</li>
</ol>
<pre class="lang:vim decode:true">$ sudo apt-get install mysql-server</pre><b>Note</b>:  You will be prompted to set a password for root.

<!--more-->

2. Install the MySQL Java Connector –
<pre class="lang:vim decode:true">$ sudo apt-get install libmysql-java</pre>3. Create soft link for connector in Hive lib directory  or copy connector jar to lib folder  –
<pre class="lang:vim decode:true">ln -s /usr/share/java/mysql-connector-java.jar $HIVE_HOME/lib/mysql-connector-java.jar</pre><b>Note</b> :- HIVE_HOME points to installed hive  folder.

4. Create the Initial database schema using the <b>hive-schema-0.14.0.mysql.sql </b>file ( or the file corresponding to your installed version of Hive) located in the <b>$HIVE_HOME/scripts/metastore/upgrade/mysql</b> directory.
<pre class="lang:mysql decode:true">$ mysql -u root -p

Enter password:

mysql&gt; CREATE DATABASE metastore;

mysql&gt; USE metastore;

mysql&gt; SOURCE $HIVE_HOME/scripts/metastore/upgrade/mysql/hive-schema-0.14.0.mysql.sql;</pre>5. You also need a MySQL user account for Hive to use to access the metastore. It is very important to prevent this user account from creating or altering tables in the metastore database schema.
<pre class="lang:mysql decode:true">mysql&gt; CREATE USER 'hiveuser'@'%' IDENTIFIED BY 'hivepassword'; 

mysql&gt; GRANT all on *.* to 'hiveuser'@localhost identified by 'hivepassword';

mysql&gt;  flush privileges;</pre><b>Note</b> : -  hiveuser is the ConnectionUserName in hive-site.xml ( As explained next)

6. Create hive-site.xml ( If not already present) in $HIVE_HOME/conf folder with the configuration below -
<pre class="lang:xhtml decode:true">&lt;configuration&gt;
   &lt;property&gt;
      &lt;name&gt;javax.jdo.option.ConnectionURL&lt;/name&gt;
      &lt;value&gt;jdbc:mysql://localhost/metastore?createDatabaseIfNotExist=true&lt;/value&gt;
      &lt;description&gt;metadata is stored in a MySQL server&lt;/description&gt;
   &lt;/property&gt;
   &lt;property&gt;
      &lt;name&gt;javax.jdo.option.ConnectionDriverName&lt;/name&gt;
      &lt;value&gt;com.mysql.jdbc.Driver&lt;/value&gt;
      &lt;description&gt;MySQL JDBC driver class&lt;/description&gt;
   &lt;/property&gt;
   &lt;property&gt;
      &lt;name&gt;javax.jdo.option.ConnectionUserName&lt;/name&gt;
      &lt;value&gt;hiveuser&lt;/value&gt;
      &lt;description&gt;user name for connecting to mysql server&lt;/description&gt;
   &lt;/property&gt;
   &lt;property&gt;
      &lt;name&gt;javax.jdo.option.ConnectionPassword&lt;/name&gt;
      &lt;value&gt;hivepassword&lt;/value&gt;
      &lt;description&gt;password for connecting to mysql server&lt;/description&gt;
   &lt;/property&gt;
&lt;/configuration&gt;</pre>7. We are all set now. Start the hive console.

<b>Note</b> :- If you are seeing any error related to Driver "com.mysql.jdbc.Driver" not found, Please make sure you have copied the mysql-java connector jar properly to Hive lib folder or created a soft link for the same.

If you have reached this far, without any errors , you can continue reading else , Go back to step 1 and see what you missed - :)

Now we'll test through hive console and mysql console if our Hive Metastore using MySQL is configured properly.
<span style="text-decoration: underline;">Hive console:</span>

Let's create a table in Hive.
<pre class="lang:vim decode:true">hive&gt; create table saurzcode(id int, name string);</pre><b><i><img class="alignleft wp-image-783" src="https://saurzcode.in//wp-content/uploads/2015/01/hive-e1420609337723.jpg" alt="Hive MySQL MetaStore Configuration" width="1247" height="100"></i></b>

 

And see if we can see it's metadata stored in MySQL.
<span style="text-decoration: underline;">MySql console:</span>
<pre class="lang:mysql decode:true">mysql -u root -p

Enter password:                                                             
mysql&gt; use metastore;                                                                                              mysql&gt; show tables ;</pre>You can query the metastore schema in your MySQL database. Something like:
<pre class="lang:mysql decode:true">mysql&gt; select * from TBLS;</pre>On your MySQL database you will see the names of your Hive tables.

<img class="alignleft wp-image-784 size-full" src="https://saurzcode.in//wp-content/uploads/2015/01/MySQL.jpg" alt="MySQL Metastore Configuration for Hive" width="1280" height="239">

 

That's It !! You are all set to use MySQL as a metastore in Hive.

Happy Learning !!

References :

<a class="vt-p" href="http://www.cloudera.com/content/cloudera/en/documentation/cdh4/v4-2-0/CDH4-Installation-Guide/cdh4ig_topic_18_4.html">[1]  Cloudera MySQL Metastore Guide.</a>



More Interesting Articles-

<a href="https://saurzcode.in/2018/06/spark-common-dataframe-operations/">Spark Dataframe Operations</a>