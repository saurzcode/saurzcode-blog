---
id: 638
title: 'How-To : Generate Restful API Documentation with Swagger ?'
date: '2014-08-19T12:00:47-07:00'
author: saurzcode
excerpt: 'Swagger is a specification and complete framework implementation for describing, producing, consuming, and visualizing RESTful web services. The goal of Swagger is to enable client and documentation systems to update at the same pace as the server. The documentation of methods, parameters, and models are tightly integrated into the server code, allowing APIs to always stay in sync.'
layout: post
guid: 'https://saurzcode.in//?p=638'
permalink: /2014/08/generate-restful-api-doc-with-swagger/
meta-checkbox:
    - ''
dsq_thread_id:
    - '3280625809'
image: /wp-content/uploads/2014/08/swagger-logo-horizontal.png
categories:
    - Java
    - Technology
tags:
    - 'Api Docs'
    - documentation
    - java
    - 'REST API'
    - Spring
    - 'Spring Boot'
    - Swagger
---

<h3>What is Swagger?</h3>
<blockquote>“Any fool can write code that a computer can understand. Good programmers write code that humans can understand.”
- Martin Fowler</blockquote>
<strong>Swagger is based on OPEN API specification and complete framework implementation for describing, producing, consuming, and visualizing RESTful web services by effectively mapping all the resources and operations associated with it.</strong> The goal of Swagger is to enable client and documentation systems to update at the same pace as the server. The documentation of methods, parameters, and models are tightly integrated into the server code, allowing APIs to always stay in sync.

<img class="wp-image-1255 aligncenter" src="http://saurzcode.in/wp-content/uploads/2014/08/swagger-logo-horizontal.png" alt="Swagger" width="462" height="174" />
<h3>Why is Swagger useful?</h3>
The framework simultaneously solves the server, client, and documentation/sandbox needs.

With Swagger's declarative resource specification, clients can understand and consume services without the knowledge of server implementation or access to the server code. The Swagger UI framework allows both developers and non-developers to interact with the API in a sandbox UI that gives a clear insight into how the API responds to parameters and options.

It happily speaks both JSON and XML, with additional formats in the works.

Now let's see a working example and how do we configure Swagger, to generate API documentation of our sample REST API created using Spring Boot.
<h3>How to Enable Swagger in your Spring Boot Web Application?</h3>
If you are one of those lazy people who hate reading the configurations, download the complete working example <a class="vt-p" href="https://github.com/saurzcode/saurzcode-swagger-spring" target="_blank" rel="noopener">here</a> , otherwise, go on -
<h4>Step 1: Include Swagger-SpringMVC dependency in Maven</h4>
<pre class="lang:xhtml decode:true">&lt;dependency&gt;
    &lt;groupId&gt;com.mangofactory&lt;/groupId&gt;
    &lt;artifactId&gt;swagger-springmvc&lt;/artifactId&gt;
    &lt;version&gt;0.8.8&lt;/version&gt;
&lt;/dependency&gt;</pre>
<h4>Step 2: Create a Swagger Java Configuration</h4>
<ul class="task-list">
 	<li>Use the <code>@EnableSwagger</code> annotation.</li>
 	<li>Autowire <code>SpringSwaggerConfig</code>.</li>
 	<li>Define one or more SwaggerSpringMvcPlugin instances using springs <code>@Bean</code> annotation.</li>
</ul>
[gist https://gist.github.com/saurzcode/9dcee7110707ff996784/]
<h4>Step 3: Create Swagger UI using WebJar</h4>
For using web jar dependency add, following repository and dependency, which will auto-configure swagger UI for you.
<pre class="lang:xhtml decode:true">&lt;repository&gt;
 &lt;id&gt;oss-jfrog-artifactory&lt;/id&gt;
 &lt;name&gt;oss-jfrog-artifactory-releases&lt;/name&gt;
 &lt;url&gt;http://oss.jfrog.org/artifactory/oss-release-local&lt;/url&gt;
 &lt;/repository&gt;</pre>
<pre class="lang:xhtml decode:true">&lt;dependency&gt;
 &lt;groupId&gt;org.ajar&lt;/groupId&gt;
 &lt;artifactId&gt;swagger-spring-mvc-ui&lt;/artifactId&gt;
 &lt;version&gt;0.1&lt;/version&gt;
 &lt;scope&gt;compile&lt;/scope&gt;
 &lt;/dependency&gt;</pre>
&nbsp;

That's it. Now run the<em> Application.java </em>as a java application in your IDE, and you will see the application running in embedded tomcat/jetty server running at default port <em>8080</em>.

Verify the API Configuration by pointing your browser at  - http://localhost:8080/api-docs
<pre class="lang:js decode:true">{"apiVersion":"1.0","swaggerVersion":"1.2","apis":[{"path":"/default/hello-controller","description":"Hello Controller"}],"info":{"title":"SaurzCode API","description":"API for Saurzcode","termsOfServiceUrl":"Saurzcode API terms of service","contact":"mail2saurzcode@gmail.com","license":"Saurzcode API Licence Type","licenseUrl":"Saurzcode API License URL"}}</pre>
And finally, you can see the Swagger API Docs  and test the APIs at  http://localhost:8080/index.html

[caption id="attachment_674" align="aligncenter" width="1080"]<a class="vt-p" href="https://saurzcode.in//wp-content/uploads/2014/08/swaggerjpg.jpg"><img class="wp-image-674 size-full" src="https://saurzcode.in//wp-content/uploads/2014/08/swaggerjpg.jpg" alt="Swagger: API Doc for Spring Boot Application" width="1080" height="357" /></a> Swagger: API Doc for RESTful API[/caption]

&nbsp;

Also, please note that default URL in web jar files is - http://petstore.swagger.wordnik.com/api/api-docs So you might see an error like this, "Can't read from the server. It may not have the appropriate access-control-origin settings."

Solution: Just replace the URL [http://petstore.swagger.wordnik.com/api/api-docs] on-screen with [http://localhost:8080/api-docs] and you will see UI as above.

&nbsp;

Again, complete project is available at GitHub.

<span style="color: #0000ff;"><a class="vt-p" style="color: #0000ff;" href="https://github.com/saurzcode/saurzcode-swagger-spring/" target="_blank" rel="nofollow noopener">https://github.com/saurzcode/saurzcode-swagger-spring/</a></span>

<span style="text-decoration: underline;">References</span> :
<ul>
 	<li><span style="color: #3366ff;"><a class="vt-p" style="color: #3366ff;" href="https://github.com/martypitt/swagger-springmvc" target="_blank" rel="nofollow noopener">https://github.com/martypitt/swagger-springmvc</a></span></li>
 	<li></li>
 	<li><span style="color: #3366ff;"><a class="vt-p" style="color: #3366ff;" href="https://helloreverb.com/developers/swagger/" target="_blank" rel="nofollow noopener">https://helloreverb.com/developers/swagger/</a></span></li>
</ul>
Do write back in comments,  if you face any issues or concerns !!

<hr />

You may also like:-
<ul>
 	<li><span style="color: #3366ff;"><a class="vt-p" style="color: #3366ff;" title="How to Setup Realtime Alalytics over Logs with ELK Stack ?" href="https://saurzcode.in//2014/08/09/how-to-setup-realtime-alalytics-over-logs-with-elk-stack/" target="_blank" rel="noopener">Setting up Realtime Analytics over logs using ELK Stack</a></span></li>
 	<li></li>
 	<li><span style="color: #3366ff;"><a class="vt-p" style="color: #3366ff;" title="Top 10 Hadoop Shell Commands to manage HDFS" href="https://saurzcode.in//2013/10/27/hadoop-shell-commands/" target="_blank" rel="noopener">Top 10 Hadoop HDFS Shell Commands.</a></span></li>
 	<li></li>
 	<li><span style="color: #3366ff;"><a style="color: #3366ff;" href="https://saurzcode.in//2015/01/hive-sort-vs-order-vs-distribute-vs-cluster/">Hive - SORT BY, DISTRIBUTE BY vs CLUSTER BY</a></span></li>
</ul>
&nbsp;