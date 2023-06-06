---
title: Java中的Pair
date: 2020-02-12 12:52:45
tags:
	- Java
categories:
	- Java
cover: /img/cover/java1.jpg
toc: true
---

# Java 中的Pair

​		Pair（配对）：  当一个函数返回两个值并且两个值都有重要意义时我们一般会用Map的key和value来表达，但是这样的话就需要两个键值对，用Map映射去做处理时，此时的key相当于value的一个描述或者引用，而具体的信息都保存在value中，我们可以通过key去获取对应的value。**但是当key和value都保存具体信息时，我们就需要用到Pair对了。Pair对也是键值对的形式。** 

​		实际上Pair保存的应该说是一个信息对，两个信息都是我们需要的，没有key和value之分。



# 实现

​		在`javax.util`包下，有一个简单`Pair`类可以直接调用，用法是直接通过构造函数将所吸引类型的Key和value存入，这个key和value没有任何的对应关系类型。

```java
import javafx.util.Pair;

/**
 * @author Hongliang Zhu
 * @create 2020-02-12 13:02
 */
public class pair {
    public static void main(String[] args) {
        Pair<Integer, String> p = new Pair<>(1, "zhuhongliang");  // 要传入对应的值
        System.out.println(p.getKey());
        System.out.println(p.getValue());

        Pair<String, String> p2 = new Pair<>("Tony", "Jane");

        System.out.println(p2.getKey());
        System.out.println(p2.getValue());
    }
}
```

> 1
> zhuhongliang
> Tony
> Jane

 		这种Pair的返回对一个函数返回两个都有意义的值有特别用处。 