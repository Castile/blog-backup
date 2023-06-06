---
title: >-
  IDEA搭建MyBatis项目使用jndi异常org.apache.ibatis.builder.BuilderException:Error
  parsing SQL Mapper Configuration. Cause:java.io.IOException:Could not find
  resource com/hongliang/dao/UserDao.xml
tags:
  - maven
  - mybatis
  - errors
categories:
  - MyBatis
date: 2020-03-31 16:58:52
toc: true
---


# 异常



在idea中创建的Maven的webapp工程，使用jndi连接数据库发生了如下错误：

![1585645523704](idea中MyBatis的JNDI工程错误/1585645523704.png)

# 解决方法

## 方法一

网上有人说： IDEA的锅：**IDEA的Maven是不会编译src的java目录的xml文件，所以在Mybatis的配置文件中找不到xml文件！** 

1. 把pom文件拿出来；
2. 把下面这段代码复制到前面去
    <build>
       <resources>
           <resource>
               <directory>src/main/java</directory>
               <includes>
                   <include>**/*.xml</include>
               </includes>
           </resource>
       </resources>
   </build>



## 方法二

 **mapper resource** 这种方式加载不到资源，其他的url class和package都可以，如果想解决问题的话，可以不使用resource这种方式！ 

我使用的package方式可以。

![1585645763050](idea中MyBatis的JNDI工程错误/1585645763050.png)

## 方法三

![1585645838825](idea中MyBatis的JNDI工程错误/1585645838825.png)





*推荐方法二*！！！！！！









# 参考

1.  https://blog.csdn.net/u010648555/article/details/70880425?depth_1-utm_source=distribute.pc_relevant.none-task 

2.  https://blog.csdn.net/qq_23184291/article/details/78089115 

   