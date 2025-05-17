---
id: 872
title: 'Hive : SORT BY vs ORDER BY vs DISTRIBUTE BY vs CLUSTER BY'
date: '2015-01-27T06:43:20-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in//?p=872'
permalink: /2015/01/hive-sort-order-distribute-cluster/
meta-checkbox:
    - ''
dsq_thread_id:
    - '3487179596'
ampforwp_custom_content_editor:
    - ''
ampforwp_custom_content_editor_checkbox:
    - null
ampforwp-amp-on-off:
    - default
categories:
    - 'Big Data'
    - Hive
    - Java
    - Technology
tags:
    - bigdata
    - 'cluster by'
    - 'distribute by'
    - hadoop
    - hive
    - 'hive interview'
    - Hiveql
    - 'order by'
    - 'sort by'
    - spark
    - 'spark sql'
---

In Apache Hive HQL, you can decide to order or sort your data differently based on ordering and distribution requirement. In this post we will look at how SORT BY, ORDER BY, DISTRIBUTE BY and CLUSTER BY behaves differently in Hive. Let's get started -
<figure id="attachment_797" align="alignleft" width="155"><a class="vt-p" href="https://saurzcode.in//wp-content/uploads/2015/01/images.jpg"><img src="http://saurzcode.in/wp-content/uploads/2015/01/images.jpg" class="wp-image-797" alt="Sort By vs Order By vs Group By vs Cluster By in Hive" width="155" height="155"></a> Sort By vs Order By vs Group By vs Cluster By in Hive</figure>
<h3>SORT BY</h3>Hive uses the columns in <i>SORT BY</i> to sort the rows before feeding the rows to a reducer. The sort order will be dependent on the column types. If the column is of numeric type, then the sort order is also in numeric order. If the column is of string type, then the sort order will be lexicographical order.

<span style="color: #000000"><b>Ordering:</b></span> It orders data at each of 'N' reducers, but each reducer can have overlapping ranges of data.

<span style="color: #000000"><b>Outcome:</b></span> N or more sorted files with overlapping ranges.

<!--more-->

Let's understand with an example of below query:-
<pre class="lang:mysql decode:true">hive&gt; SELECT emp_id, emp_salary FROM employees SORT BY emp_salary DESC;</pre>Let's assume the number of reducers was set to 2 and the output of each reducer is as follows -

<b>Reducer 1 :</b>
<div>
<div id="highlighter_383987">
<pre class="lang:sh decode:true">emp_id | emp_salary 10             5000 16             3000 13             2600 19             1800</pre></div>
</div>
<p class="lang:sh decode:true"><b style="font-size: 1em; background-color: #ffffff">Reducer 2 :</b></p>

<div class="code panel pdl">
<div class="codeContent panelContent pdl">
<div id="highlighter_251786" class="syntaxhighlighter nogutter java">
<div>
<pre class="lang:sh decode:true">emp_id | emp_salary 11             4000 17             3100 14             2500 20             2000</pre></div>
</div>
</div>
</div>
As, we can see, values in each reducer output are ordered but total ordering is missing since we end up with multiple outputs per reducer and data within one reducer is sorted in descending order.
<h3><b>ORDER BY</b></h3>This is similar to ORDER BY in SQL Language.

In Hive, ORDER BY guarantees total ordering of data, but for that, it has to be passed on to a single reducer, which is normally performance-intensive and therefore in strict mode, hive makes it compulsory to use LIMIT with ORDER BY so that reducer doesn't get overburdened.

<span style="color: #000000"><b>Ordering:</b></span> Total Ordered data.

<span style="color: #000000"><b>Outcome:</b></span> Single output i.e. fully ordered.

For example :
<pre class="lang:mysql decode:true">hive&gt; SELECT emp_id, emp_salary FROM employees ORDER BY emp_salary DESC;</pre><b>Reducer :</b>
<pre class="lang:sh decode:true">emp_id | emp_salary 10             5000 11             4000 17             3100 16             3000 13             2600 14             2500 20             2000 19             1800</pre>
<h3>DISTRIBUTE BY</h3>Hive uses the columns in <i>Distribute By</i> to distribute the rows among reducers. All rows with the same <i>Distribute By</i> columns will go to the same reducer.

It ensures each of N reducers gets non-overlapping ranges of the&nbsp;<span style="font-family: monospace,serif"><span style="font-size: 15px">column</span></span>, but doesn't sort the output of each reducer. You end up with N or more unsorted files with non-overlapping ranges.

Example ( taken directly from Hive wiki ):-

We are <i>Distributing By x</i> on the following 5 rows to 2 reducers:
<pre class="lang:sh decode:true">x1 x2 x4 x3 x1</pre>
<h4>Reducer 1</h4>
<pre class="lang:sh decode:true">x1 x2 x1</pre>
<h4>Reducer 2</h4>
<div class="code panel pdl">
<div class="codeContent panelContent pdl">
<div id="highlighter_558410" class="syntaxhighlighter nogutter java">
<pre class="lang:sh decode:true">x4 x3</pre><span style="font-size: 1em">Note that all rows with the same key x1 are guaranteed to be distributed to the same reducer (reducer 1 in this case), but they are not guaranteed to be clustered in adjacent positions.</span>

</div>
</div>
</div>
<h3>CLUSTER BY</h3><i>Cluster By</i> is a short-cut for both <i>Distribute By</i> and <i>Sort By</i>.

<code>CLUSTER BY x </code>ensures each of N reducers gets non-overlapping ranges, then sorts by those ranges at the reducers.

<b>Ordering</b> : Global ordering between multiple reducers.

<b>Outcome: </b>N or more sorted files with non-overlapping ranges.

For the same example as above, if we use <i>Cluster By x</i>, the two reducers will further sort rows on x:
<h4>Reducer 1 :</h4>
<div class="code panel pdl">
<div class="codeContent panelContent pdl">
<div id="highlighter_7223" class="syntaxhighlighter nogutter java">
<pre class="lang:sh decode:true">x1 x1 x2</pre></div>
</div>
</div>
<h4>Reducer 2 :</h4>
<div class="code panel pdl">
<div class="codeContent panelContent pdl">
<div id="highlighter_283486" class="syntaxhighlighter nogutter java">
<pre class="lang:sh decode:true">x3 x4</pre>Instead of specifying <i>Cluster By</i>, the user can specify <i>Distribute By</i> and <i>Sort By</i>, so the partition columns and sort columns can be different.

References : -

[1] <a href="http://stackoverflow.com/questions/13715044/hive-cluster-by-vs-order-by-vs-sort-by">http://stackoverflow.com/questions/13715044/hive-cluster-by-vs-order-by-vs-sort-by</a>

[2] <a href="https://cwiki.apache.org/confluence/display/Hive/LanguageManual+SortBy#LanguageManualSortBy-SyntaxofOrderBy">https://cwiki.apache.org/confluence/display/Hive/LanguageManual+SortBy#LanguageManualSortBy-SyntaxofOrderBy</a>

You may also be interested in some other BigData posts -
<ul>
 	<li><a href="https://saurzcode.in/2021/05/how-to-train-and-score-catboost-model-on-spark/" target="_blank" rel="noopener">CatBoost on Spark - Machine Learning </a></li>
 	<li><a href="https://saurzcode.in/2019/09/running-spark-application-on-windows/">Spark; How to Run Spark Applications on Windows</a></li>
 	<li><a href="https://saurzcode.in/2017/10/configure-spark-application-eclipse/">Getting started with Spark Development</a></li>
 	<li><a href="https://saurzcode.in//2015/01/setup-development-environment-hadoop-mapreduce/" target="_blank" rel="noopener">Getting started with MapReduce development</a></li>
 	<li><a href="https://wp.me/p5pWDa-iX">Multithreaded Mappers in MapReduce</a></li>
 	<li><a href="https://saurzcode.in/2018/06/spark-common-dataframe-operations/">Spark Dataframe Operations</a></li>
</ul>
</div>
</div>
</div>