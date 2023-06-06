---
title: Java8中的Lambda表达式
tags:
  - Java
categories:
  - Java
cover: /img/cover/lambda.jpg
date: 2020-03-05 11:16:34
---


# Java8新特性

Java 8 于2014年3月14号发布，可以看成是自Java 5 以来最具革命性的版本。Java 8为Java语言、编译器、类库、开发工具与JVM带来了大量新特性。

> 速度更快
>
> 代码更少(增加了新的语法：**Lambda** **表达式**
>
> 强大的 **Stream API**
>
> 便于并行
>
> 最大化减少空指针异常：`Optional`  



#      Lambda表达式  

`Lambda` 是一个**匿名函数**，我们可以把 `Lambda` 表达式理解为是**一段可以传递的代码**（将代码像数据一样进行传递）。可以写出更简洁、更灵活的代码。作为一种更紧凑的代码风格，使Java的语言表达能力得到了提升。

`Lambda` 表达式在Java 8 语言中引入了一个新的语法元素和操作符。这个操作符为 `->` ， 该操作符被称为 `Lambda` 操作符或**箭头操作符**。它将 Lambda 分为两个部分：

> **左侧：**指定了 `Lambda` 表达式需要的参数列表。
>
> **右侧：**指定了 `Lambda` 体，即 `Lambda` 表达式要执行的功能。

```java
  @Test
    public void test(){
        Comparator<Integer> con = (o1, o2)-> o1.compareTo(o2);
        System.out.println(con.compare(11, 56));
    }
```

```java
public void happy(double money, Consumer<Double> con){
        con.accept(money);
    }

	@Test
    public void test1(){
        // 原始写法
        happy(19000, new Consumer<Double>() {
            @Override
            public void accept(Double money) {
                System.out.println("花了"+ money);
            }
        });

	// lambda表达式
    happy(9000, money->System.out.println("花了"+money));
}
```

# Lambda表达式语法格式

语法格式一： 无参数， 无返回值

> ```java
> Runnable r  = ()-> System.out.println("helllo"); 
> ```

语法格式二： 需要一个参数，但是没有返回值。如果只有一个参数，**参数的小括号可以省略。**

> ```java
> Consumer<String> con = str -> System.out.println(str);con.accept("hello");
> ```

语法格式三： Lambda 需要两个或以上的参数，多条执行语句，并且有返回值 。

> ```java
> Comparator<Integer> com = (x, y)->{    
> 	System.out.println("实现函数式接口方法...");    
> 	return Integer.compare(x, y);
> 	};
> ```
>
> 

