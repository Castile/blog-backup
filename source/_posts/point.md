---
title: 网易秋招编程题-优雅的点
tags:
  - 数学
  - 简单
categories:
  - Algorithm
date: 2020-05-31 17:57:10
---


# 描述

> 小易有一个圆心在坐标原点的圆，小易知道圆的半径的平方。小易认为在圆上的点而且横纵坐标都是整数的点是优雅的，小易现在想寻找一个算法计算出优雅的点的个数，请你来帮帮他。
>  例如：半径的平方如果为25
>  优雅的点就有：(+/-3, +/-4), (+/-4, +/-3), (0, +/-5) (+/-5, 0)，一共12个点。 

输入：

> 输入为一个整数，即为圆半径的平方,范围在32位int范围内。

输出：

> 输出为一个整数，即为优雅的点的个数

# 思路

醉了，现场做不得劲，回过头来看发现真简单。。。可能心态不行吧。稳重点！

分两种情况：1. 能被完整开平方的 ，这种需要加上横坐标为0的四个点。 2. 不能完整开平方的，也就是数开出来会有小数，此时可用floor函数向下取个整，这样就会比半径更小了。

在第一个象限遍历横坐标的范围，满足勾股定理，且纵坐标也是整数的就是满足条件，即“优雅的点”, 最后别忘了有四个象限，需要乘以4。



# 代码实现

```java
import java.util.Scanner;

/**
 * @author Hongliang Zhu
 * @create 2020-05-31 16:27
 */
public class point {

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        int radius = sc.nextInt();
        double r = Math.sqrt(radius);
        int range = (int)Math.floor(r);
        int count = 0;
        for(int i = 1; i <= range; i++){
            for(int j = 1; j <= range;  j++){
                if( i*i + j*j == radius){
                    count++;
                }
            }

        }
        count*=4;
        if(range == r){
            count+=4;
        }
        System.out.println(count);

//        System.out.println(Math.sqrt(25)== (int)Math.floor(Math.sqrt(25) ));


    }

}

```

