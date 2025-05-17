---
id: 273
title: 'String Interning &#8211; What ,Why and When ?'
date: '2014-05-19T10:41:07-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in//?p=273'
permalink: /2014/05/string-interning-what-why-and-when/
geo_public:
    - '0'
publicize_linkedin_url:
    - 'http://www.linkedin.com/updates?discuss=&scope=23596248&stype=M&topic=5874023215919042560&type=U&a=vDqJ'
dsq_thread_id:
    - '3280625904'
meta-checkbox:
    - ''
categories:
    - Java
    - Technology
tags:
    - Intern
    - java
    - 'Java Interview'
    - String
    - Technology
---

<em><strong>What is String Interning </strong></em>

String Interning is a method of storing only one copy of each distinct String Value, which must be immutable.
<p style="color: #333333;">In Java <code style="color: #333333;">String</code> class has a <code style="color: #333333;">public</code> method <code style="color: #333333;">intern()</code> that returns a canonical representation for the string object. Java's <code style="color: #333333;">String</code> class privately maintains a pool of strings, where <code style="color: #333333;">String</code> literals are automatically interned.</p>

<blockquote>
<p style="color: #333333;"><em>When the <code style="color: #333333;">intern()</code> method is invoked on a <code style="color: #333333;">String</code> object it looks the string contained by this <code style="color: #333333;">String</code> object in the pool, if the string is found there then the string from the pool is returned. Otherwise, this <code style="color: #333333;">String</code> object is added to the pool and a reference to this <code style="color: #333333;">String</code> object is returned.</em></p>
</blockquote>
<p style="color: #333333;">The <code style="color: #333333;">intern()</code> method helps in comparing two <code style="color: #333333;">String</code> objects with <code style="color: #333333;">==</code> operator by looking into the pre-existing pool of string literals, no doubt it is faster than <code style="color: #333333;">equals()</code> method. <span style="color: #333333;">The pool of strings in Java is maintained for saving space and for faster comparisons.</span><strong><span style="color: #333333;"> </span></strong>Normally Java programmers are advised to use <code style="color: #333333;">equals()</code>, not <code style="color: #333333;">==</code>, to compare two strings. This is because <code style="color: #333333;">==</code> operator compares memory locations, while <code style="color: #333333;">equals()</code> method compares the content stored in two objects.</p>
<p style="color: #333333;"><em><strong>Why and When to Intern ?</strong></em></p>
<p style="color: #333333;">Thought Java automatically interns all Remember that we only need to intern strings when they are not constants, and we want to be able to quickly compare them to other interned strings. The <code style="color: #333333;">intern() </code>method should be used on strings constructed with <code style="color: #333333;">new String()</code> in order to compare them by <code style="color: #333333;">==</code> operator.</p>
<p style="color: #333333;">Let's take a look at the following Java program to understand the <em>intern()</em> behavior.</p>

<pre class="lang:java decode:true">public class TestString {
 
    public static void main(String[] args) {
        String s1 = "Test";
        String s2 = "Test";
        String s3 = new String("Test");
        final String s4 = s3.intern();
        System.out.println(s1 == s2);
        System.out.println(s2 == s3);
        System.out.println(s3 == s4);
        System.out.println(s1 == s3);
        System.out.println(s1 == s4);
        System.out.println(s1.equals(s2));
        System.out.println(s2.equals(s3));
        System.out.println(s3.equals(s4));
        System.out.println(s1.equals(s4));
        System.out.println(s1.equals(s3));
    }
 
}
 
 
//Output
true
false
false
false
true
true
true
true
true
true</pre>