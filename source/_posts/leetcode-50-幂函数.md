---
title: leetcode-50-幂函数
date: 2020-02-12 12:29:27
tags:
	- 数学
	- 递归
	- 算法
	- 中等
categories:
	- Algorithm
cover: /img/cover/幂函数.jpg
---

# 描述

## leetcode-50 Pow(x, n)

> 实现 pow(x, n) ，即计算 x 的 n 次幂函数。
>
> 示例 1:
>
> 输入: 2.00000, 10
> 输出: 1024.00000
> 示例 2:
>
> 输入: 2.10000, 3
> 输出: 9.26100
> 示例 3:
>
> 输入: 2.00000, -2
> 输出: 0.25000
> 解释: 2-2 = 1/22 = 1/4 = 0.25
> 说明:
>
> -100.0 < x < 100.0
> n 是 32 位有符号整数，其数值范围是 [−231, 231 − 1] 。
>
> 链接：https://leetcode-cn.com/problems/powx-n

# 分析

1. 暴力求解： 这个会超时，这里要处理一下n小于0的情况， 当n小于0的时候，将x变成1/x， n = -n； 

2. 快速幂： https://blog.csdn.net/qq_19782019/article/details/85621386 

   ​		快速幂算法能帮我们算出指数非常大的幂，传统的求幂算法之所以时间复杂度非常高（为O(指数n)），就是因为当指数n非常大的时候，需要执行的循环操作次数也非常大。所以我们快速幂算法的核心思想就是每一步都把指数分成两半，而相应的底数做平方运算。这样不仅能把非常大的指数给不断变小，所需要执行的循环次数也变小，而最后表示的结果却一直不会变。

# 代码

 https://github.com/Castile/algorithm/blob/master/leetcode/src/RecurrenceAndDynamicProgramming/leetcode50_pow.java 

```java
package RecurrenceAndDynamicProgramming;
/**
 * @author Hongliang Zhu
 * @create 2020-02-12 15:39
 */
public class leetcode50_pow {

    public static double pow(double x, int n) {
        long N = n;
        if (n < 0) {
            N = -N;
            x = 1 / x;
        }
        double ans = 1.0;
        for (int i = 0; i < N; i++) {
            ans *= x;
            ans %= 1000;
        }
        return ans;
    }

    /**
     *  快速幂
     * @param x 底数
     * @param n 指数
     * @return  结果   求最后三位数
     */
    public static double fast_pow(double x, int n){
        double result = 1;
        while (n > 0 ){
//            if(n % 2 == 0){
//                // 如果指数为偶数
//                n /= 2;
//                x = x * x % 1000;
//            }if(n % 2 != 0 ){
//                // 指数为奇数
//                n--; //  指数减一为偶数
//                result = result * x % 1000;
//                n /= 2;
//                x = x * x % 1000;
//            }
            if( (n & 1) == 1) {  // n%2 == 1  奇数   使用位运算更加高效
                result = result * x % 1000;
            }
            // n /= 2;
            n >>= 2; // 右移
            x = x * x % 1000;
        }
        return result % 1000;

    }

    public static void main(String[] args) {

        long start =  System.nanoTime();
//        double ans = pow(2, 1000000000);
        double anss = fast_pow(2, 10000000);
        long end = System.nanoTime();

        System.out.println(anss);
        System.out.println("耗时：" +  (end - start)   +" ns");

    }
}

```

附上AC的结果：

```java
class Solution {
    public double myPow(double x, int n) {
        long N = n;
        if (N < 0) {
            x = 1 / x;
            N = -N;
        }
        return fastPow(x, N);
    }

    private double fastPow(double x, long n){
        if(n == 0)  return 1.0;
        double ans = 1.0;
        while(n > 0){
            if((n & 1 ) == 1){
                ans = ans*x;
            }
            n >>= 1;
            x = x * x;
        }
        return ans;
    }

};

```

<img src="leetcode-50-幂函数/1581498031170.png" alt="1581498031170" style="zoom:80%;" align='center'/>

快速幂很巧妙！值得学习！加油！！！

