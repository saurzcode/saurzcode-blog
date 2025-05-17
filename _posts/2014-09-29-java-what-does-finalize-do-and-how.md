---
id: 691
title: 'Java : What does finalize do and How?'
date: '2014-09-29T10:07:05-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in//?p=691'
permalink: /2014/09/java-what-does-finalize-do-and-how/
publicize_google_plus_url:
    - 'https://plus.google.com/107786853692055665005/posts/gJwqdFyAjVR'
publicize_twitter_user:
    - schhajed
publicize_twitter_url:
    - 'http://t.co/0RnZZ39dZv'
publicize_linkedin_url:
    - 'https://www.linkedin.com/updates?discuss=&scope=23596248&stype=M&topic=5922212275766185985&type=U&a=XZ8_'
dsq_thread_id:
    - '3282147228'
meta-checkbox:
    - ''
categories:
    - Java
    - Technology
tags:
    - Finalize
    - 'Garbage collection'
    - java
    - 'Java Interview'
    - JVM
---

Finalize method in Object class is often a point of discussion whether to be used or not ? Below are some of the pointers on Finalize method<!--more-->
<ul>
	<li><em><span style="text-decoration: underline;"><strong>When It is Called</strong></span></em> : Called by the garbage collector on an object when garbage collection determines that there are no more references to the object. A subclass overrides the <code>finalize</code> method to dispose of system resources or to perform other cleanup.</li>
	<li>The general contract of <code>finalize</code> is that it is invoked if and when the Java<sup>TM</sup> virtual machine has determined that there is no longer any means by which this object can be accessed by any thread that has not yet died, except as a result of an action taken by the finalization of some other object or class which is ready to be finalized.</li>
	<li>The <code>finalize</code> method may take any action, including making this object available again to other threads; the usual purpose of <code>finalize</code>, however, is to perform cleanup actions before the object is irrevocably discarded. For example, the finalize method for an object that represents an input/output connection might perform explicit I/O transactions to break the connection before the object is permanently discarded.</li>
	<li>The <code>finalize</code> method of class <code>Object</code> performs no special action; it simply returns normally. Subclasses of <code>Object</code> may override this definition.</li>
</ul>
<pre class="lang:java decode:true ">protected void finalize() throws Throwable { }</pre>
<ul>
	<li>The Java programming language <strong>does not guarantee</strong> which thread will invoke the <code>finalize</code> method for any given object. It is guaranteed, however, that the thread that invokes finalize will not be holding any user-visible synchronization locks when finalize is invoked. If an uncaught exception is thrown by the finalize method, the exception is ignored and finalization of that object terminates.</li>
	<li>After the <code>finalize</code> method has been invoked for an object, no further action is taken until the Java virtual machine has again determined that there is no longer any means by which this object can be accessed by any thread that has not yet died, including possible actions by other objects or classes which are ready to be finalized, at which point the object may be discarded.</li>
	<li>The <code>finalize</code> method is <strong>never invoked</strong> <strong>more than once</strong> by a Java virtual machine for any given object.</li>
	<li>Any exception thrown by the <code>finalize</code> method causes the finalization of this object to be halted, but is otherwise ignored.</li>
	<li>In general it's best not to rely on <code>finalize()</code> to do any cleaning up etc., because a object may not be eligible for GC during the lifetime of the application and resources might not get closed and can cause the resource exhaustion.</li>
	<li>If overriding <code>finalize()</code> it is good programming practice to use a try-catch-finally statement and to always call <code>super.finalize()</code>. This is a safety measure to ensure you do not inadvertently miss closing a resource used by the objects calling class
<pre class="lang:java decode:1 ">protected void finalize() throws Throwable {
try {
close(); // close open files
} finally {
super.finalize();
}
}</pre>
</li>
</ul>
References : <a class="vt-p" href="http://docs.oracle.com/javase/7/docs/api/java/lang/Object.html">http://docs.oracle.com/javase/7/docs/api/java/lang/Object.html</a>