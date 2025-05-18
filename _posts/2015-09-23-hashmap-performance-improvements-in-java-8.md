---
id: 763
title: 'Hashmap Performance Improvements in Java 8'
date: '2015-09-23T00:40:22-07:00'
author: saurzcode
layout: medium
guid: 'https://saurzcode.in//?p=763'
permalink: /2015/09/hashmap-performance-improvements-in-java-8/
meta-checkbox:
    - ''
dsq_thread_id:
    - '4158527568'
categories:
    - Java
tags:
    - collection
    - hashmap
    - java8
---

Problem Statement :
===================

Until Java 7, java.util.Hashmap implementations always suffered with the problem of Hash Collision, i.e. when multiple `hashCode()` values end up in the same bucket, values are placed in a Linked List implementation, which reduces Hashmap performance from O(1) to O(n).

Solution :
==========

Improve the performance of `java.util.HashMap` under high hash-collision conditions by using balanced trees rather than linked lists to store map entries.This will improve collision performance for any key type that implements `Comparable`. This JDK 8 change applies only toHashMap, LinkedHashMap, and ConcurrentHashMap. The principal idea is that once the number of items in a hash bucket grows beyond a certain threshold(TREEIFY\_THRESHOLD), that bucket will switch from using a linked list of entries to a balanced tree. In the case of high hash collisions, this will improve worst-case performance from O(n) to O(log n).and when they become too small (due to removal or resizing) they are converted back to Linked List. \`\`\`java static final int TREEIFY\_THRESHOLD = 8; static final int UNTREEIFY\_THRESHOLD = 6; \`\`\` Also note that in rare situations, this change could introduce a change to the iteration order of HashMap and HashSet. A particular iteration order is not specified for HashMap objects - any code that depends on iteration order should be fixed.