---
title: JDK8中日期的API的使用
tags:
  - Java
categories:
  - Java
cover: /img/cover/java.jpg
date: 2020-02-27 12:01:14
toc: true
---


# jdk8之前

## java.util.Date 日期类

​			---- java.sql.Date  数据库里面使用的数据类型

```java
public class Date extends java.util.Date {
}
```

System类提供的`public static long currentTimeMillis()`用来返回当前时间与1970年1月1日0时0分0秒之间以毫秒为单位的时间差。      **此方法适于计算时间差**  

> getTime() :返回自 1970 年 1 月 1 日 00:00:00 GMT 以来此 Date 对象表示的毫秒数。
>
> toString() :把此 Date 对象转换为以下形式的 String： dow mon dd hh:mm:ss zzz yyyy 其中： dow 是一周中的某一天 (Sun, Mon, Tue, Wed, Thu, Fri, Sat)，zzz是时间标准。

##      java.text.SimpleDateFormat类

Date类的API不易于国际化，大部分被废弃了，`java.text.SimpleDateFormat`类是一个不与语言环境有关的方式来格式化和解析日期的具体类。

**它允许进行格式化（日期--->文本）、解析（文本---->日期）**

格式化：

> `SimpleDateFormat()` ：默认的模式和语言环境创建对象
>
> `public SimpleDateFormat`(String pattern)：该构造方法可以用参数pattern指定的格式创建一个对象，该对象调用：
>
> `public String format`(Date date)：方法格式化时间对象date

解析：

> `public Date parse(String source)`：从给定字符串的开始解析文本，以生成一个日期。

## 三天打渔两天晒网

```java
 @Test
    public void test3() throws ParseException {
        // 三天打渔两天晒网： 问 在xxxx-xx-xx这一天是打渔还是在晒网。
        // 从1996-10-02开始三天打渔两天晒网
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String begin = "1996-10-02";
        String now = "2020-02-28";
        Date start = sdf.parse(begin);
       long totalMills = sdf.parse(now).getTime() -  start.getTime();
       long totalDays = totalMills / (24 * 60 * 60 * 1000) + 1; //防止小数点
        System.out.println("总天数：" + totalDays);
		//  System.out.println(totalDays / 366.0);
       int res = (int)totalDays % 5;
        System.out.println("结果: "+ res);
       if(res >= 1 && res <= 3){
           System.out.println("在打渔。。。。。。。。。");
       }else{
           System.out.println("在晒网....................");
       }
    }

```

## java.util.Calendar(日历)类

```java
	 @Test
    public void test4(){
        Calendar calendar = Calendar.getInstance();
        int days =  calendar.get(Calendar.DAY_OF_MONTH);
        System.out.println(days);  // 27
        days = calendar.get(Calendar.DAY_OF_YEAR);
        System.out.println(days); // 58

        calendar.add(Calendar.DAY_OF_MONTH , -3);
        days = calendar.get(Calendar.DAY_OF_MONTH);  // 24
        System.out.println(days);

        Date date = calendar.getTime();
        System.out.println(date); // Mon Feb 24 16:29:10 CST 2020

        Date date1 = new Date();
        calendar.setTime(date1);
        days = calendar.get(Calendar.DAY_OF_MONTH);
        System.out.println(days); // 27
    }
```

----



# JDK8中的日期API

## 概述

JDK1.0中包含了一个java.util.Date类， 但是它的大多数方法已经在JDK1.1中引入Calendar类之后被弃用了。然而Calendar类也并不比Date好多少。它们面临的问题是：

> 可变性： 像日期和时间这样的类应该是不可变的，但是Calendar类有set方法可以改变原来的时间。
>
> 偏移性： Date的年份是从1900年开始的，而月份都是从0开始的。
>
> 格式化： 格式化只对Date有用， Calendar则不行。
>
> 此外， 它们也不是线程安全的，； 不能处理闰秒等。

> 闰秒：也称作“跳秒”，  是指为保持[协调](https://baike.baidu.com/item/协调/787659)[世界时](https://baike.baidu.com/item/世界时/692237)接近于[世界时](https://baike.baidu.com/item/世界时)时刻，由[国际计量局](https://baike.baidu.com/item/国际计量局/2545290)统一规定在年底或[年中](https://baike.baidu.com/item/年中)（也可能在[季末](https://baike.baidu.com/item/季末/9671176)）对协调世界时增加或减少1[秒](https://baike.baidu.com/item/秒/2924586)的调整。由于地球[自转](https://baike.baidu.com/item/自转/1011647)的不均匀性和长期变慢性（主要由[潮汐摩擦](https://baike.baidu.com/item/潮汐摩擦/4765297)引起的），会使世界时（[民用时](https://baike.baidu.com/item/民用时)）和[原子时](https://baike.baidu.com/item/原子时)之间相差超过到±0.9秒时，就把协调世界时向前拨1秒（负闰秒，最后一分钟为59秒）或向后拨1秒（正闰秒，最后一分钟为61秒）； 闰秒一般加在[公历](https://baike.baidu.com/item/公历/449762)年末或公历六月末。
>
> 目前，全球已经进行了27次闰秒，均为正闰秒。
>
> 最近一次闰秒在[北京时间](https://baike.baidu.com/item/北京时间/410384)2017年1月1日7时59分59秒（**时钟显示07:59:60**）出现。这也是本世纪的第五次闰秒。

总结： 对日期和时间操作一直是Java程序员最痛苦的地方之一。

Java 8 吸收了 `Joda-Time` 的精华，以一个新的开始为 Java 创建优秀的 API。新的 `java.time` 中包含了所有关于时钟（`Clock`），本地日期（`LocalDate`）、本地时间（`LocalTime`）、本地日期时间（`LocalDateTime`）、时区（ZonedDateTime）和持续时间（`Duration`）的类。历史悠久的 `Date` 类新增了 `toInstant()` 方法，用于把 `Date` 转换成新的表示形式。这些新增的本地化时间日期 API 大大简化了了日期时间和本地化的管理。  



##      **使用** LocalDate、LocalTime、LocalDateTime 

`LocalDate`、`LocalTime`、`LocalDateTime` 类的实例是不可变的对象，分别表示使用 `ISO-8601`日历系统的日期、时间、日期和时间。它们提供了简单的日期或时间，并不包含当前的时间信息。也不包含与时区相关的信息。

> ​     ISO-8601日历系统是国际标准化组织制定的现代公民的日期和时间的表示法  

### 方法

|                           **方法**                           |                           **描述**                           |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
|                          **now()**                           |                静态方法，根据当前时间创建对象                |
|                           **of()**                           |             静态方法，根据指定日期/时间创建对象              |
|       **plusDays, plusWeeks, plusMonths,  plusYears**        |      向当前 LocalDate 对象添加几天、几周、几个月、几年       |
|  **minusDays,  minusWeeks,**  **minusMonths,  minusYears**   |      从当前 LocalDate 对象减去几天、几周、几个月、几年       |
|                       **plus,  minus**                       |              添加或减少一个 Duration 或 Period               |
| **withDayOfMonth,**  **withDayOfYear,**  **withMonth,**  **withYear** | 将月份天数、年份天数、月份、年份修改为指定的值并返回新的 LocalDate 对象 |
|                      **getDayOfMonth**                       |                      获得月份天数(1-31)                      |
|                       **getDayOfYear**                       |                     获得年份天数(1-366)                      |
|                       **getDayOfWeek**                       |            获得星期几(返回一个 DayOfWeek 枚举值)             |
|                         **getMonth**                         |               获得月份, 返回一个 Month 枚举值                |
|                      **getMonthValue**                       |                        获得月份(1-12)                        |
|                         **getYear**                          |                           获得年份                           |
|                          **until**                           | 获得两个日期之间的 Period 对象，或者指定 ChronoUnits 的数字  |
|                    **isBefore,  isAfter**                    |                      比较两个 LocalDate                      |
|                        **isLeapYear**                        |                        判断是否是闰年                        |

### 获取当前时间的日期、时间、 日期+时间

```java
//  now（）： 获取当前时间的日期、时间、 日期+时间
LocalDate localDate = LocalDate.now();
LocalTime localTime = LocalTime.now();
LocalDateTime localDateTime = LocalDateTime.now();

System.out.println(localDate);  // 2020-02-28
System.out.println(localTime); // 11:16:05.208365800
System.out.println(localDateTime); // 2020-02-28T11:16:05.208365800

// of(): 设置指定的年、月、日、时分秒
LocalDateTime time1 = LocalDateTime.of(2020, 10, 6, 15, 23, 9);
System.out.println(time1);  //  2020-10-06T15:23:09

```

### 获取具体的属性值

```java
 //getXXX(): 获取具体的属性值
System.out.println(localDateTime.getDayOfWeek()); //  FRIDAY
System.out.println(localDateTime.getDayOfMonth());  //  28
System.out.println(localDateTime.getDayOfYear()); // 59
System.out.println(localDateTime.getMonth()); // FEBRUARY
System.out.println(localDateTime.getMonthValue()); // 2
System.out.println(localDateTime.getHour()); //11
System.out.println(localDateTime.getMinute()); // 23
System.out.println(localDateTime.getSecond()); // 26
```

### 修改-不可变

体现了不可变性， 会返回新的LocalDate对象，不会修改原来的值

```java
 //修改 体现了不可变性， 会返回新的LocalDate对象，不会修改原来的值
LocalDate localDate1 = localDate.withDayOfMonth(22);
System.out.println(localDate1); //  2020-02-22
System.out.println(localDate); // 2020-02-28

// 加操作，同样是不可改变的，返回一个新的对象  不可变性
LocalDateTime localDateTime1 = localDateTime.plusMonths(3);// 现有的基础上三个月
System.out.println(localDateTime1); // 2020-05-28T12:50:47.920841500
System.out.println(localDateTime);  // 2020-02-28T12:50:47.920841500
```

----



# Instant时间戳

用于“时间戳”的运算。它是以Unix元年(传统的设定为UTC时区1970年1月1日午夜时分)开始所经历的描述进行运算。 类似于java.util.Date类

```java
@Test
public void test2(){
    Instant now = Instant.now();
    System.out.println(now);  // 2020-02-28T04:56:34.925610700Z 这个是本初子午线的时间，不											是东八区的时间
    //处理时区问题  添加时间偏移量
    OffsetDateTime offsetDateTime = now.atOffset(ZoneOffset.ofHours(8));
    System.out.println(offsetDateTime); // 2020-02-28T13:01:14.149267200+08:00
    // 获取对应时间点的毫秒数          类似于--- > Date.getTime()
    long mills = now.toEpochMilli();
    System.out.println(mills);  // 1582866180907

    //ofEpochMilli  通过给定的毫秒数，获取Instant实例  类似于--- > Date(long mills)
    Instant instant = Instant.ofEpochMilli(156698646645646140L);
    System.out.println(instant); // 1582866180907
}
```

---



#    解析与格式化

java.time.format.DateTimeFormatter 类：该类提供了三种格式化方法：

- 预定义的标准格式

- 语言环境相关的格式

- 自定义的格式

类似于SimpleDateFormat。

```java
 public void test3() {
     /*
         * 预定义的模式
         * */
     DateTimeFormatter format = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
     //格式化
     LocalDateTime localDateTime = LocalDateTime.now();
     String str1 = format.format(localDateTime);
     System.out.println(str1);  // 2020-02-28T13:12:45.4405114
     System.out.println(localDateTime); //2020-02-28T13:12:45.440511400
     //解析：字符串--> 日期
     TemporalAccessor parse = format.parse(str1);
     System.out.println(parse);

     /**
         * 本地化相关格式  ofLocalDateTime()
         * fFormatStyle.LONG / MEDIUM / SHORT  : 适用于LocalDateTime

         */

     DateTimeFormatter formatter = DateTimeFormatter.ofLocalizedDateTime(FormatStyle.SHORT);
     LocalDateTime localDateTime1 = LocalDateTime.now();

     String format1 = formatter.format(localDateTime1);
     System.out.println(format1);  // 2020/2/28 下午1:22

    }
```

上面两种方式用得不多，在开发中通常使用的是自定义模式

```java
/***
* 重点： 自定义模式
*/
DateTimeFormatter formatter1 = DateTimeFormatter.ofPattern("yyyy-MM-dd hh:mm:ss");
//格式化
String str4 = formatter1.format(LocalDateTime.now());
System.out.println(str4); // 2020-02-28 01:30:33
// 解析
TemporalAccessor parse1 = formatter1.parse("2020-02-28 01:30:33");
// {NanoOfSecond=0, MilliOfSecond=0, MinuteOfHour=30, SecondOfMinute=33, HourOfAmPm=1, MicroOfSecond=0},ISO resolved to 2020-02-28
System.out.println(parse1);
```

----



#      **与传统日期处理的转换**  



|                            **类**                            |           **To** **遗留类**           |     **From** **遗留类**     |
| :----------------------------------------------------------: | :-----------------------------------: | :-------------------------: |
|           **java.time.Instant     java.util.Date**           |          Date.from(instant)           |      date.toInstant()       |
|         **java.time.Instant     java.sql.Timestamp**         |        Timestamp.from(instant)        |    timestamp.toInstant()    |
| **java.time.ZonedDateTime**** **    **java.util.GregorianCalendar** | GregorianCalendar.from(zonedDateTime) |    cal.toZonedDateTime()    |
|      **java.time.LocalDate**** **    **java.sql.Time**       |        Date.valueOf(localDate)        |     date.toLocalDate()      |
|          **java.time.LocalTime     java.sql.Time**           |        Date.valueOf(localDate)        |     date.toLocalTime()      |
|      **java.time.LocalDateTime     java.sql.Timestamp**      |   Timestamp.valueOf(localDateTime)    | timestamp.toLocalDateTime() |
|       **java.time.ZoneId **    **java.util.TimeZone**        |       Timezone.getTimeZone(id)        |     timeZone.toZoneId()     |
| **java.time.format.DateTimeFormatter **    **java.text.DateFormat** |         formatter.toFormat()          |             无              |



# 其他

参考API

