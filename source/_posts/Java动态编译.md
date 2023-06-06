---
title: Java动态编译与脚本引擎
tags:
  - Java
categories:
  - Java
cover: /img/cover/java3.jpg
date: 2020-03-03 15:11:46
toc: true
---


# 动态编译

JAVA 6.0引入了动态编译机制。

## 动态编译的应用场景

可以做一个浏览器端编写java代码，上传服务器编译和运行的在线评测 系统。

服务器动态加载某些类文件进行编译。

## 动态编译的两种做法

1. 通过`Runtime`调用`javac`，启动新的进程去操作。

2. 通过`JavaCompiler`动态编译。

   JavaCompiler：

   > JavaCompiler.run(...):
   >
   > int run(InputStream in, OutputStream out, OutputStream err, String... arguments);
   >
   >  第一个参数：为java编译器提供参数 输入： null 表示`System.in`
   >
   >  第二个参数：得到 Java 编译器的输出信息 :  null 表示`System.out`
   >
   > 第三个参数：接收编译器的 错误信息:  null 表示`System.err`
   >
   > 第四个参数：可变参数（是一个String数组）能传入一个或多个 Java 源文件 
   >
   > 返回值：0表示编译成功，非0表示编译失败

```java
import javax.tools.JavaCompiler;
import javax.tools.ToolProvider;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

/**
 * 动态编译
 * @author Hongliang Zhu
 * @create 2020-03-03 14:58
 */
public class TestDynamic {
    public static void main(String[] args) throws IOException {
        // 编译
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        int run = compiler.run(null, null, null, "F:\\java\\base\\DynamicCompille\\src\\hello.java");
        System.out.println(run == 0?"编译成功":"编译失败");

        //执行class 运行程序
        Runtime runtime = Runtime.getRuntime();
        Process process = runtime.exec("java -cp F:\\java\\base\\DynamicCompille\\src hello");
        InputStream inputStream = process.getInputStream();
        BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
        String info = "";
        while ((info = reader.readLine()) != null){
            System.out.println(info);
        }



    }
}

```

> 编译成功
> 		hello!!!

## 通过反射运行编译好的类

```java
@Test
    public void TestReflect(){
        try {
            URL[] uRls = new URL[]{new URL("file:/"+"F:/java/base/DynamicCompille/src/")};
            URLClassLoader loader = new URLClassLoader(uRls);
            Class clazz = loader.loadClass("hello");
            // 调用加载类的main方法
            Method m = clazz.getMethod("main", String[].class);
            m.invoke(null, (Object)new String[]{});
            // 由于可变参数是JDK5.0之后才有的，上面代码会编译成： m.invoke(null, "aa0, "bb");, 我们知道
            // main方法中的参数是一个String[],这样就会发生参数个数不匹配的问题，所以要加上Object强制装换。
        } catch (Exception e) {
            e.printStackTrace();
        }


    }
```

> hello!!!

同样可以执行。

--------------------



# 脚本引擎

JAVA脚本引擎是从JDK6.0之后添加的新功能。

脚本引擎介绍：使得 Java 应用程序可以通过一套固定的接口与各种脚本引擎交互，从而达到在 Java 平台上调用各种脚本语言的目的。

Java 脚本 API 是连通 Java 平台和脚本语言的桥梁。可以把一些复杂异变的业务逻辑交给脚本语言处理，这又大大提高了 开发效率。

## 脚本引擎执行JavaScript代码

获取脚本程序输入，通过脚本引擎运行脚本并返回运行结果，这是最核心的接口。 

`Rhino` 是一种使用 Java 语言编写的 `JavaScript` 的开源实现，原先由`Mozilla`开发 ，现在被集成进入`JDK 6.0`。

通过脚本引擎的运行上下文在脚本和 Java 平台间交换数据，通过 Java 应用程序调用脚本函数。

```java
        // 获得脚本引擎对象
        ScriptEngineManager scriptEngineManager = new ScriptEngineManager();
        ScriptEngine engine = scriptEngineManager.getEngineByName("javascript");
        //定义变量，存储到引擎上下文中
        engine.put("msg", "you see you , one day day de");
        // 下面是JavaScript脚本
        String str = "var user = { name: 'jack', age:18, schools:['北京交通大学','计算机与信息技术学院']};";
        str+="print(user.name);";

        // 执行脚本
        engine.eval(str);
        System.out.println(engine.get("msg"));
        engine.eval("msg = 'day by day';"); //更改
        System.out.println(engine.get("msg"));
```

> jack
> 		you see you , one day day de
> 		day by day

## 脚本引擎执行JavaScript函数

```java
// 定义函数
engine.eval(
    "function add(a, b){ var sum = a+b; return sum;}"
);
//执行js函数
// 取得调用接口
Invocable jsInvoke = (Invocable)engine;
Object add = jsInvoke.invokeFunction("add", new Object[]{13, 44});
System.out.println(add); // 打印返回结果  57.0
```

## 交换数据

```java
// 导入其他java包，使用其他包中的Java类
String jsCode = " var list = java.util.Arrays.asList([\"北京交通大学\",\"计算机与信息技术学院\"]);";
engine.eval(jsCode);
List<String> list = (List) engine.get("list");
for (String t: list){
	System.out.println(t);  // 北京交通大学  计算机与信息技术学院
}
```

## 脚本引擎执行js文件

a.js:

```javascript
// 定义test方法
function test(){
    var a = 3;
    var b =4;
    print("invoke js file:" + (a+b));
}

// 执行test
test()

```

```java
 // 执行一个js文件
 InputStream resource = testengine.class.getClassLoader().getResourceAsStream("a.js");
 BufferedReader br = new BufferedReader(new InputStreamReader(resource));
 engine.eval(br);  // invoke js file:7
 br.close();
```

> invoke js file: 7