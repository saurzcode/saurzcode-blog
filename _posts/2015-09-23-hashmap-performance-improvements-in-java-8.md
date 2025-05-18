---
id: 763
title: 'Hashmap Performance Improvements in Java 8'
date: '2015-09-23T00:40:22-07:00'
author: saurzcode

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

# HashMap Performance Improvements in Java 8

A developer-focused look at how Java 8 improved the performance of `HashMap` under high-collision scenarios, with code examples and practical explanations.
<!--more-->
---

## Table of Contents

- [HashMap Performance Improvements in Java 8](#hashmap-performance-improvements-in-java-8)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [The Hash Collision Problem (Pre-Java 8)](#the-hash-collision-problem-pre-java-8)
  - [Java 8 Solution: Tree Bins](#java-8-solution-tree-bins)
  - [Thresholds and Behavior](#thresholds-and-behavior)
  - [Impact on Iteration Order](#impact-on-iteration-order)
  - [Summary](#summary)
  - [References](#references)

---

## Introduction

Prior to Java 8, `java.util.HashMap` suffered from performance degradation when many keys hashed to the same bucket (hash collision). In such cases, the bucket was implemented as a linked list, causing lookup time to degrade from O(1) to O(n).

Java 8 introduced a major improvement: **buckets with many collisions are now stored as balanced trees (red-black trees) instead of linked lists**, improving worst-case performance to O(log n).

---

## The Hash Collision Problem (Pre-Java 8)

- In Java 7 and earlier, each bucket in a `HashMap` was a linked list of entries.
- When multiple keys had the same hash code, they were placed in the same bucket.
- As the number of entries in a bucket grew, operations like `get`, `put`, and `remove` became slower (O(n) in the number of entries in the bucket).

**Example:**

```java
// Many keys with the same hash code
Map<BadKey, String> map = new HashMap<>();
for (int i = 0; i < 1000; i++) {
    map.put(new BadKey(i), "value" + i);
}
// Lookup is O(n) for a bucket with many collisions
```

---

## Java 8 Solution: Tree Bins

- Java 8 introduced a threshold: if a bucket contains more than a certain number of entries, it is converted from a linked list to a balanced tree (red-black tree).
- This reduces the worst-case time complexity for operations in a bucket from O(n) to O(log n).
- When the number of entries in a bucket drops below a lower threshold, it is converted back to a linked list.
- This change applies to `HashMap`, `LinkedHashMap`, and `ConcurrentHashMap`.

**Relevant constants:**

```java
static final int TREEIFY_THRESHOLD = 8;
static final int UNTREEIFY_THRESHOLD = 6;
```

- If a bucket grows beyond 8 entries, it is treeified.
- If it shrinks below 6, it is untreeified.

---

## Thresholds and Behavior

- **TREEIFY_THRESHOLD**: When a bucket contains more than 8 entries, it is converted to a tree.
- **UNTREEIFY_THRESHOLD**: When a tree bin shrinks below 6 entries, it is converted back to a linked list.
- **Note:** Treeification only happens if the overall map capacity is at least 64 (to avoid overhead for small maps).

**Code Example:**

```java
HashMap<String, String> map = new HashMap<>();
// Add enough colliding keys to trigger treeification
for (int i = 0; i < 20; i++) {
    map.put("key" + (i % 4), "value" + i); // Simulate collisions
}
```

---

## Impact on Iteration Order

- In rare cases, the change to tree bins can affect the iteration order of `HashMap` and `HashSet`.
- **Important:** The iteration order of `HashMap` is not specified and should not be relied upon.

---

## Summary

- Java 8 improved `HashMap` performance under high-collision scenarios by using balanced trees for large buckets.
- This change improves worst-case performance from O(n) to O(log n) for buckets with many entries.
- The change is transparent to most users, but be aware of possible changes in iteration order.

---

## References

- [Java 8 HashMap Improvements (OpenJDK)](https://bugs.openjdk.org/browse/JDK-8046154)
- [Java HashMap Source Code (GitHub)](https://github.com/openjdk/jdk/blob/master/src/java.base/share/classes/java/util/HashMap.java)
