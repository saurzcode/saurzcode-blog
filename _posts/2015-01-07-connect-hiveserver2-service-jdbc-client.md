---
id: 792
title: 'How-To : Connect HiveServer2 service with JDBC Client ?'
date: '2015-01-07T22:56:45-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in//?p=792'
permalink: /2015/01/connect-hiveserver2-service-jdbc-client/
meta-checkbox:
    - ''
dsq_thread_id:
    - '3487092095'
categories:
    - 'Big Data'
    - Hive
    - Java
    - Technology
tags:
    - 'hadoop interview'
    - hive
    - hiveserver2
    - jdbc
    - metastore
---

HiveServer2 (HS2) is a server interface that enables remote clientsto execute queries against Hive and retrieve the results. The current implementation, based on Thrift RPC, is an improved version of <a class="vt-p" href="https://cwiki.apache.org/confluence/display/Hive/HiveServer">HiveServer</a> and supports multi-client concurrency and authentication. It is designed to provide better support for open API clients like JDBC and ODBC.

<!--more-->

<img class="size-full wp-image-797 aligncenter" src="https://saurzcode.in//wp-content/uploads/2015/01/images.jpg" alt="images" width="225" height="225">

In this post, we will see , how we can start HiveServer2 and connect to it with a JDBC Client :-
<h3>Part 1 : How to Start HiveServer2 ( Hive as a service) :</h3>
<pre class="lang:vim decode:true">$HIVE_HOME/bin/hiveserver2</pre>OR
<div class="code panel pdl">
<div class="codeContent panelContent pdl">
<div class="syntaxhighlighter nogutter java" id="highlighter_202688"><pre class="lang:vim decode:true">$HIVE_HOME/bin/hive --service hiveserver2</pre>You should see something like this on console :-

<a class="vt-p" href="https://saurzcode.in//wp-content/uploads/2015/01/HiveServer2.jpg"><img class="alignleft wp-image-795 size-full" src="https://saurzcode.in//wp-content/uploads/2015/01/HiveServer2.jpg" alt="HiveServer2" width="1292" height="367"></a>

A quick way to check if HiveServer2 is running is to use <i>netstat </i>command to see if port <i>10000 </i>is open and listening to connections :-
<pre class="lang:zsh decode:true">$ netstat -nl | grep 10000</pre>Now we are all set to connect to above started Hive Service and we can connect our JDBC client to the server to create table, write queries over it etc.</div>
</div>
</div>
<h2 id="HiveServer2Clients-UsingJDBC">Part 2 : Using JDBC to Connect to HiveServer2</h2>
You can use JDBC to access data stored in a relational database or other tabular format.
<ol>
	<li>Load the HiveServer2 JDBC driver.
For example:
<div class="preformatted panel">
<div class="preformattedContent panelContent"><pre>Class.forName("org.apache.hive.jdbc.HiveDriver");</pre></div>
</div>
<pre></pre><pre></pre></li>
</ol>
<ul>
	<li>Connect to the database by creating a <code>Connection</code> object with the JDBC driver.

For example:</li>
</ul>
<ul>
	<li>
<div class="preformatted panel">
<div class="preformattedContent panelContent"><pre class="lang:vim decode:true">Connection cnct = DriverManager.getConnection("jdbc:hive2://&lt;host&gt;:&lt;port&gt;", "&lt;user&gt;", "&lt;password&gt;");</pre></div>
</div>
<pre class="lang:vim decode:true"></pre><pre class="lang:vim decode:true"></pre>The default <code>&lt;port&gt;</code> is 10000. In non-secure configurations, specify a <code>&lt;user&gt;</code> for the query to run as. The <code>&lt;password&gt;</code> field value is ignored in non-secure mode.
<div class="preformatted panel">
<div class="preformattedContent panelContent"><pre class="lang:vim decode:true">Connection cnct = DriverManager.getConnection("jdbc:hive2://&lt;host&gt;:&lt;port&gt;", "&lt;user&gt;", "");</pre></div>
</div>
<pre class="lang:vim decode:true"></pre><pre class="lang:vim decode:true"></pre>In Kerberos secure mode, the user information is based on the Kerberos credentials.</li>
</ul>


<ul>
	<li>Submit SQL to the database by creating a <code>Statement</code> object and using its <code>executeQuery()</code> method.

For example:
<div class="preformatted panel">
<div class="preformattedContent panelContent"><pre>Statement stmt = cnct.createStatement();
ResultSet rset = stmt.executeQuery("SELECT foo FROM bar");</pre></div>
</div>
<pre></pre><pre></pre></li>
</ul>
<ul>
	<li>Process the result set, if necessary.</li>
</ul>


Let's understand this with an Example :-

We'll create a text file with test values and read data with Hive and display using queries -
<div class="line number5 index4 alt2"><code class="bash functions">echo</code> <code class="bash plain">-e </code><code class="bash string">'1\x01foo'</code> <code class="bash plain">&gt; </code><code class="bash plain">/tmp/a</code><code class="bash plain">.txt</code></div>

<div class="line number6 index5 alt1"><code class="bash functions">echo</code> <code class="bash plain">-e </code><code class="bash string">'2\x01bar'</code> <code class="bash plain">&gt;&gt; </code><code class="bash plain">/tmp/a</code><code class="bash plain">.txt</code></div>






Test Java Client :-

We need to add following Maven Dependencies :-
<pre class="lang:xhtml decode:true">        &lt;dependency&gt;
            &lt;groupId&gt;org.apache.hive&lt;/groupId&gt;
            &lt;artifactId&gt;hive-exec&lt;/artifactId&gt;
            &lt;version&gt;0.14.0&lt;/version&gt;
        &lt;/dependency&gt;
        &lt;dependency&gt;
            &lt;groupId&gt;org.apache.hive&lt;/groupId&gt;
            &lt;artifactId&gt;hive-jdbc&lt;/artifactId&gt;
            &lt;version&gt;0.14.0&lt;/version&gt;
        &lt;/dependency&gt;
        &lt;dependency&gt;
            &lt;groupId&gt;org.apache.hive&lt;/groupId&gt;
            &lt;artifactId&gt;hive-metastore&lt;/artifactId&gt;
            &lt;version&gt;0.14.0&lt;/version&gt;
        &lt;/dependency&gt;
        &lt;dependency&gt;
            &lt;groupId&gt;org.apache.hive&lt;/groupId&gt;
            &lt;artifactId&gt;hive-service&lt;/artifactId&gt;
            &lt;version&gt;0.14.0&lt;/version&gt;
        &lt;/dependency&gt;
        &lt;dependency&gt;
            &lt;groupId&gt;org.apache.calcite&lt;/groupId&gt;
            &lt;artifactId&gt;calcite-avatica&lt;/artifactId&gt;
            &lt;version&gt;0.9.2-incubating&lt;/version&gt;
        &lt;/dependency&gt;
        &lt;dependency&gt;
            &lt;groupId&gt;org.apache.calcite&lt;/groupId&gt;
            &lt;artifactId&gt;calcite-core&lt;/artifactId&gt;
            &lt;version&gt;0.9.2-incubating&lt;/version&gt;
        &lt;/dependency&gt;
        &lt;dependency&gt;
            &lt;groupId&gt;org.apache.hadoop&lt;/groupId&gt;
            &lt;artifactId&gt;hadoop-common&lt;/artifactId&gt;
            &lt;version&gt;2.2.0&lt;/version&gt;
        &lt;/dependency&gt;</pre>And let's create one Test Java Program
<pre class="lang:java decode:true">import java.sql.SQLException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.DriverManager;
 
public class HiveJdbcClient {
  private static String driverName = "org.apache.hive.jdbc.HiveDriver";
 
  /**
   * @param args
   * @throws SQLException
   */
  public static void main(String[] args) throws SQLException {
      try {
      Class.forName(driverName);
    } catch (ClassNotFoundException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
      System.exit(1);
    }
    //replace "hduser" here with the name of the user the queries should run as
    Connection con = DriverManager.getConnection("jdbc:hive2://localhost:10000/default", "hduser", "");
    Statement stmt = con.createStatement();
    String tableName = "testHiveDriverTable";
    stmt.execute("drop table if exists " + tableName);
    stmt.execute("create table " + tableName + " (key int, value string)");
    // show tables
    String sql = "show tables '" + tableName + "'";
    System.out.println("Running: " + sql);
    ResultSet res = stmt.executeQuery(sql);
    if (res.next()) {
      System.out.println(res.getString(1));
    }
       // describe table
    sql = "describe " + tableName;
    System.out.println("Running: " + sql);
    res = stmt.executeQuery(sql);
    while (res.next()) {
      System.out.println(res.getString(1) + "\t" + res.getString(2));
    }
 
    // load data into table
    // NOTE: filepath has to be local to the hive server
    // NOTE: /tmp/a.txt is a ctrl-A separated file with two fields per line
    String filepath = "/tmp/a.txt";
    sql = "load data local inpath '" + filepath + "' into table " + tableName;
    System.out.println("Running: " + sql);
    stmt.execute(sql);
 
    // select * query
    sql = "select * from " + tableName;
    System.out.println("Running: " + sql);
    res = stmt.executeQuery(sql);
    while (res.next()) {
      System.out.println(String.valueOf(res.getInt(1)) + "\t" + res.getString(2));
    }
 
    // regular hive query
    sql = "select count(1) from " + tableName;
    System.out.println("Running: " + sql);
    res = stmt.executeQuery(sql);
    while (res.next()) {
      System.out.println(res.getString(1));
    }
  }
}</pre>
<div class="line number6 index5 alt1"></div>
<div class="line number6 index5 alt1">
<p style="background: white;">When we run the Test JDBC Client Output on Console looks like :-</p>
</div>
<p style="background: white;"></p>
<div class="line number6 index5 alt1"><pre class="lang:vim decode:true">Running: show tables 'testHiveDriverTable'
testhivedrivertable
Running: describe testHiveDriverTable
key    int
value    string
Running: load data local inpath '/tmp/a.txt' into table testHiveDriverTable
Running: select * from testHiveDriverTable
1    foo
2    bar
Running: select count(1) from testHiveDriverTable
2</pre>And on the HiveServer2 Screen you should see corresponding output and Processing of MapReduce Jobs for each query , something like this.

<img class="alignleft wp-image-796 size-full" src="https://saurzcode.in//wp-content/uploads/2015/01/HiveServer2QueryOutput.jpg" alt="HiveServer2QueryOutput" width="1009" height="541">

That's It !! We are all set with a HiveServer2 Running and Successfully connected with a JDBC Client.

Happy Learning !!

References :-

[1] <a class="vt-p" href="https://cwiki.apache.org/confluence/display/Hive/HiveServer2+Clients">https://cwiki.apache.org/confluence/display/Hive/HiveServer2+Clients</a>

Interesting Reads -

<a href="https://wp.me/p5pWDa-iX">Multithreaded Mappers in MapReduce</a></div>
<a href="https://saurzcode.in/2018/06/spark-common-dataframe-operations/">Spark Dataframe Operations</a>