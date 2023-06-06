---
title: Java关键字
date: 2020-01-29 10:19:02
tags:
	- Java
	- Java基础
	- 关键字
categories:
	- Java
toc: true
---



# final

## **1. 数据**

声明数据为常量，可以是编译时常量，也可以是在运行时被初始化后不能被改变的常量。

- 对于基本类型，final 使数值不变；
- 对于引用类型，final 使引用不变，也就不能引用其它对象，但是被引用的对象本身是可以修改的。

```java
final int x = 1;
// x = 2;  // cannot assign value to final variable 'x'
final A y = new A();
y.a = 1;
```

## **2. 方法**

声明方法不能被子类重写。

private 方法隐式地被指定为 final，如果在子类中定义的方法和基类中的一个 private 方法签名相同，此时子类的方法不是重写基类方法，**而是在子类中定义了一个新的方法。**

## **3. 类**

声明类不允许被继承。



# static

## **1. 静态变量**

- 静态变量：又称为类变量，也就是说这个变量属于类的，类所有的实例都共享静态变量，可以直接通过类名来访问它。静态变量在内存中只存在一份。
- 实例变量：每创建一个实例就会产生一个实例变量，它与该实例同生共死。

```java
public class A {

    private int x;         // 实例变量
    private static int y;  // 静态变量

    public static void main(String[] args) {
        // int x = A.x;  // Non-static field 'x' cannot be referenced from a static context
        A a = new A();
        int x = a.x;
        int y = A.y;
    }
}
```

## **2. 静态方法**

静态方法在类加载的时候就存在了，它不依赖于任何实例。所以静态方法必须有实现，也就是说它不能是抽象方法。

```java
public abstract class A {
    public static void func1(){
    }
    // public abstract static void func2();  // Illegal combination of modifiers: 'abstract' and 'static'
}
```

只能访问所属类的静态字段和静态方法，方法中不能有 this 和 super 关键字，因此这两个关键字与具体对象关联。 即静态域中不能访问非静态的，因为静态的变量是先于对象（或者非静态）出现。

```java
public class A {

    private static int x;
    private int y;

    public static void func1(){
        int a = x;
        // int b = y;  // Non-static field 'y' cannot be referenced from a static context
        // int b = this.y;     // 'A.this' cannot be referenced from a static context
    }
}
```

## **3. 静态语句块**

静态语句块在类初始化时运行一次。

```java
public class A {
    static {
        System.out.println("123");
    }

    public static void main(String[] args) {
        A a1 = new A();
        A a2 = new A();
    }
}

// 结果只输出一次“123”
```

## **4. 静态内部类**

### 内部类

>  大部分时候，类被定义成一个独立的程序单元。在某些情况下，也会把一个类放在另一个类的内部定义，这个定义在其他类内部的类就被称为内部类（有些地方也叫做嵌套类），包含内部类的类也被称为外部类（有些地方也叫做宿主类） 

### 内部类的作用

> - 更好的封装性
> - 内部类成员可以直接访问外部类的私有数据，因为内部类被当成其外部类成员，但外部类不能访问内部类的实现细节，例如内部类的成员变量
> - 匿名内部类适合用于创建那些仅需要一次使用的类

 使用static来修饰一个内部类，则这个内部类就属于外部类本身，而不属于外部类的某个对象。称为静态内部类（也可称为类内部类），这样的内部类是类级别的，**static关键字的作用是把类的成员变成类相关，而不是实例相关 。**

 注意：

1. 非静态内部类中不允许定义静态成员
   2. 外部类的静态成员不可以直接使用非静态内部类
      3. 静态内部类，不能访问外部类的实例成员，只能访问外部类的类成员 

* 在建造者模式中有使用，具体可以参考[链接](https://blog.csdn.net/cd18333612683/article/details/79129503 )



非静态内部类依赖于外部类的实例，也就是说需要先创建外部类实例，才能用这个实例去创建非静态内部类。而静态内部类不需要。

```java
public class OuterClass {

    class InnerClass {
    }

    static class StaticInnerClass {
    }

    public static void main(String[] args) {
        // InnerClass innerClass = new InnerClass(); // 'OuterClass.this' cannot be referenced from a static context
        OuterClass outerClass = new OuterClass();
        InnerClass innerClass = outerClass.new InnerClass();
        StaticInnerClass staticInnerClass = new StaticInnerClass();
    }
}Copy to clipboardErrorCopied
```

静态内部类不能访问外部类的非静态的变量和方法。



## **5. 静态导包**

在使用静态变量和方法时不用再指明 ClassName，从而简化代码，但可读性大大降低。

```java
import static com.xxx.ClassName.*
```

一般我们导入一个类都用 `import com…..ClassName;`

而静态导入是这样：`import static com…..ClassName.*;`  这里的多了个static，还有就是类名ClassName后面多了个.* ，意思是导入这个类里的静态方法。当然，也可以只导入某个静态方法，只要把 .* 换成静态方法名就行了。然后在这个类中，就可以直接用方法名调用静态方法，而不必用ClassName.方法名 的方式来调用。

**`好处：`**

这种方法的好处就是可以简化一些操作，例如打印操作System.out.println(…); 就可以将其写入一个静态方

法print(…)，在使用时直接print(…)就可以了。但是这种方法建议在有很多重复调用的时候使用，如果仅有一到两次调用，不如直接写来的方便。

```java
import static java.lang.System.out;
/**
 * @author Hongliang Zhu
 * @create 2020-01-29 10:40
 */
public class keywords {

    static {
        out.println("hello");
    }

    public static void main(String[] args) {

    }

}

```

## **6. 初始化顺序**

静态变量和静态语句块优先于实例变量和普通语句块，静态变量和静态语句块的初始化顺序取决于它们在代码中的顺序。

```java
public static String staticField = "静态变量";
```

```java
static {
    System.out.println("静态语句块");
}
```

```java
public String field = "实例变量";
```

```java
{
    System.out.println("普通语句块");
}
```

最后才是构造函数的初始化

```java
public InitialOrderTest() {
    System.out.println("构造函数");
}
```

存在继承的情况下，初始化顺序为：

- 父类（静态变量、静态语句块）
- 子类（静态变量、静态语句块）
- 父类（实例变量、普通语句块）
- 父类（构造函数）
- 子类（实例变量、普通语句块）
- 子类（构造函数）



# 参考

1.  https://cyc2018.github.io/CS-Notes 

2.  https://blog.csdn.net/cd18333612683/article/details/79129503 

3. https://blog.csdn.net/u012338954/article/details/51010337

   