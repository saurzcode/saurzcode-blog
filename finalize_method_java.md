# Understanding the `finalize` Method in Java

`finalize` method in the `Object` class is often a point of discussion regarding whether it should be used or not. Below are some important pointers on the `finalize` method:

---

### 1. When Is It Called?

- Called by the garbage collector on an object when garbage collection determines that there are no more references to the object.
- A subclass overrides the `finalize` method to dispose of system resources or perform other cleanup.

---

### 2. Contract of `finalize`

- The general contract of `finalize` is that it is invoked if and when the Java™ virtual machine determines that there is no longer any means by which this object can be accessed by any thread that has not yet died, except as a result of an action taken by the finalization of some other object or class which is ready to be finalized.

---

### 3. Purpose and Behavior

- The `finalize` method may take any action, including making this object available again to other threads.
- The usual purpose of `finalize`, however, is to perform cleanup actions before the object is irrevocably discarded.
- For example, the `finalize` method for an object representing an input/output connection might perform explicit I/O transactions to break the connection before the object is permanently discarded.

---

### 4. Default Implementation

- The `finalize` method of class `Object` performs no special action; it simply returns normally.
- Subclasses of `Object` may override this definition.

```java
protected void finalize() throws Throwable { }
```

---

### 5. Thread Behavior

- The Java programming language **does not guarantee** which thread will invoke the `finalize` method for any given object.
- It is guaranteed, however, that the thread that invokes `finalize` will not be holding any user-visible synchronization locks.
- If an uncaught exception is thrown by the `finalize` method, the exception is ignored and finalization of that object terminates.

---

### 6. Finalization Cycle

- After the `finalize` method has been invoked for an object, no further action is taken until the JVM has again determined that there is no longer any means by which this object can be accessed.
- This includes possible actions by other objects or classes that are ready to be finalized, at which point the object may be discarded.

---

### 7. One-Time Invocation

- The `finalize` method is **never invoked more than once** by the JVM for any given object.

---

### 8. Exception Handling

- Any exception thrown by the `finalize` method causes the finalization of this object to be halted but is otherwise ignored.

---

### 9. General Recommendation

- In general, it's best **not to rely on `finalize()`** for cleaning up.
- An object may not be eligible for garbage collection during the lifetime of the application, which can cause resources not to be closed and may lead to resource exhaustion.

---

### 10. Best Practices When Overriding `finalize()`

- If overriding `finalize()`, it is good programming practice to use a try-catch-finally block and always call `super.finalize()`.
- This ensures that resources used by the object's calling class are properly released.

```java
protected void finalize() throws Throwable {
    try {
        close(); // close open files
    } finally {
        super.finalize();
    }
}
```

---

### References

- [Java Object Class - Oracle Documentation](http://docs.oracle.com/javase/7/docs/api/java/lang/Object.html)
