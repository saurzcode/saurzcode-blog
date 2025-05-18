---
id: 273
title: 'String Interning &#8211; What ,Why and When ?'
date: '2014-05-19T10:41:07-07:00'
author: saurzcode

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

## What is String Interning

String Interning is a method of storing only one copy of each distinct String Value, which must be immutable.
<!--more-->
In Java, the `String` class has a `public` method `intern()` that returns a canonical representation for the string object. Java's `String` class privately maintains a pool of strings, where `String` literals are automatically interned.

> When the `intern()` method is invoked on a `String` object it looks the string contained by this `String` object in the pool, if the string is found there then the string from the pool is returned. Otherwise, this `String` object is added to the pool and a reference to this `String` object is returned.

The `intern()` method helps in comparing two `String` objects with `==` operator by looking into the pre-existing pool of string literals, no doubt it is faster than `equals()` method. The pool of strings in Java is maintained for saving space and for faster comparisons. Normally Java programmers are advised to use `equals()`, not `==`, to compare two strings. This is because `==` operator compares memory locations, while `equals()` method compares the content stored in two objects.

### Why and When to Intern?

Though Java automatically interns all string literals, remember that we only need to intern strings when they are not constants, and we want to be able to quickly compare them to other interned strings. The `intern()` method should be used on strings constructed with `new String()` in order to compare them by `==` operator.

Let's take a look at the following Java program to understand the `intern()` behavior.

```java
public class TestString {
 
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
true
```
