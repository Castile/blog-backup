---
title: Java的自动装箱和拆箱
date: 2020-01-28 11:57:55
tags:
	- Java
	- java基础
categories:
	- Java
---

自动装箱/拆箱
====================

----------


> 自动装箱：指开发人员可以把一个基本数据类型直接赋给对应的包装类。
>
> 自动拆箱：指开发人员可以把一个包装类对象直接赋给对应的基本数据类型。

基本数据类型包装类
---------

| 包装类                  | 基本数据类型                |
| ----------------------- | --------------------------- |
| Byte                    | byte                        |
| Integer                 | int                         |
| Long                    | long                        |
| Boolean                 | boolean                     |
| Float                   | float                       |
| Double                  | double                      |
| Character               | char                        |
| 对象变基本数据类型:拆箱 | 基本数据类型包装为对象:装箱 |

----------

 在使用这些基本类型对应的包装类型时，如果该数值范围在缓冲池范围内，就可以直接使用缓冲池中的对象。 



Example：

```java
public class Demo5 {
	
	public static void main(String[] args) {
		String str = "12";
		
		//字符串转换成int类型数据。 可以把字符串转换成对应的数字
		int i = Integer.parseInt(str);
		System.out.println(i+1);
		
		//把数字转换成字符串
		System.out.println("把整数转换成对应 的字符串："+Integer.toString(i));
		
		//把整数转换成对应的进制形式
		System.out.println("10的二进制："+ Integer.toBinaryString(10));
		System.out.println("10的二进制："+ Integer.toBinaryString(10));
		System.out.println("10的十六进制："+ Integer.toHexString(10));
		
		
		//可以把字符串当成对应的进行数据帮你转换
		String data = "10";
		int a = Integer.parseInt(data, 2);
		System.out.println("a="+a);
		
		
		//集合： 集合是可以存储任意对象类型数据的容器。
		ArrayList list = new ArrayList();
		list.add(1);
		list.add(2);
		list.add(3);
		
		//自动装箱： 自动把java的基本数据类型数据转换成对象类型数据。
		int temp = 10;  //基本数据类型
		Integer b =temp; //把a存储的值赋予给b变量。
		
		
		//自动拆箱： 把引用类型的数据转换成基本类型的数据
		Integer c = new Integer(13);
		int d = c; //
		System.out.println(d);
		
		//引用的数据类型
		Integer e = 127;
		Integer f = 127; 
		System.out.println("同一个对象吗？"+(e==f)); // ture
		
		
	}
	
}
```
注意：
> Integer类内部维护 了缓冲数组，该缓冲数组存储的-128~127
> 这些数据在一个数组中。如果你获取的数据是落入到这个范围之内的，那么就直接从该缓冲区中获取对应的数据。【Java8】

 编译器会在自动装箱过程调用 valueOf() 方法，因此多个值相同且值在缓存池范围内的 Integer 实例使用自动装箱来创建，那么就会引用相同的对象。 

```java
public class integer {

    public static void main(String[] args) {
        Integer a = new Integer(111);
        Integer b = new Integer(111);

        Integer c = Integer.valueOf(111);
        Integer d = Integer.valueOf(111);


        System.out.println(a == b);
        System.out.println(c == d);

    }
}
```

结果： false   true

> new Integer(123) 与 Integer.valueOf(123) 的区别在于：
>
> - new Integer(123) 每次都会新建一个对象；
> - Integer.valueOf(123) 会使用缓存池中的对象，多次调用会取得同一个对象的引用。

看下面的例子：

```java

/**
 * @author Hongliang Zhu
 * @create 2020-01-28 11:38
 */
public class integer {

    public static void main(String[] args) {
        Integer a = new Integer(160);
        Integer b = new Integer(160);

        Integer c = Integer.valueOf(160);
        Integer d = Integer.valueOf(160);


        System.out.println(a == b);
        System.out.println(c == d);

    }
}

```

结果为： false  false

因为160超过了缓存的范围（-128-127），所以都是不同的对象， valueOf() 方法的实现比较简单，就是先判断值是否在缓存池中，如果在的话就直接返回缓存池的内容。 如果不在缓存池中，则会new一个Integer对象。

```java
 public static Integer valueOf(int i) {
        if (i >= IntegerCache.low && i <= IntegerCache.high)
            return IntegerCache.cache[i + (-IntegerCache.low)];
        return new Integer(i);
    }
```





**看源码：**

----------

```java
     private static class IntegerCache {
        static final int low = -128;
        static final int high;
        static final Integer cache[];

        static {
            // high value may be configured by property
            int h = 127;
            String integerCacheHighPropValue =
                sun.misc.VM.getSavedProperty("java.lang.Integer.IntegerCache.high");
            if (integerCacheHighPropValue != null) {
                try {
                    int i = parseInt(integerCacheHighPropValue);
                    i = Math.max(i, 127);
                    // Maximum array size is Integer.MAX_VALUE
                    h = Math.min(i, Integer.MAX_VALUE - (-low) -1);
                } catch( NumberFormatException nfe) {
                    // If the property cannot be parsed into an int, ignore it.
                }
            }
            high = h;

            cache = new Integer[(high - low) + 1];
            int j = low;
            for(int k = 0; k < cache.length; k++)
                cache[k] = new Integer(j++);

            // range [-128, 127] must be interned (JLS7 5.1.7)
            assert IntegerCache.high >= 127;
        }

        private IntegerCache() {}
    }
```

​	 在 jdk 1.8 所有的数值类缓冲池中，Integer 的缓冲池 IntegerCache 很特殊，这个缓冲池的下界是 - 128，上界默认是 127，但是这个上界是可调的，在启动 jvm 的时候，通过 -XX:AutoBoxCacheMax=<size> 来指定这个缓冲池的大小，该选项在 JVM 初始化的时候会设定一个名为 java.lang.IntegerCache.high 系统属性，然后 IntegerCache 初始化的时候就会读取该系统属性来决定上界。 





## 参考

1.  [https://cyc2018.github.io/CS-Notes/#/notes/Java%20%E5%9F%BA%E7%A1%80](https://cyc2018.github.io/CS-Notes/#/notes/Java 基础) 
2.  https://blog.csdn.net/Castile_zhu/article/details/78822267 