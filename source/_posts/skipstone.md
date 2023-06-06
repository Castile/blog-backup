---
title: 网易秋招编程题-跳石板
tags:
  - dp
  - 困难
categories:
  - Algorithm
date: 2020-05-31 22:08:56
---




# 描述

> 小易来到了一条石板路前，每块石板上从1挨着编号为：1、2、3.......
>  这条石板路要根据特殊的规则才能前进：对于小易当前所在的编号为K的 石板，小易单次只能往前跳K的一个约数(不含1和K)步，即跳到K+X(X为K的一个非1和本身的约数)的位置。 小易当前处在编号为N的石板，他想跳到编号恰好为M的石板去，小易想知道最少需要跳跃几次可以到达。
>  例如：
>  N = 4，M = 24：
>  4->6->8->12->18->24
>  于是小易最少需要跳跃5次，就可以从4号石板跳到24号石板 



输入：

> 输入为一行，有两个整数N，M，以空格隔开。 (4 ≤ N ≤ 100000) (N ≤ M ≤ 100000)

输出

> 输出小易最少需要跳跃的步数,如果不能到达输出-1

示例：

> 4 24
>
> 5



# 思路

一看到题干上说要求最小、最少。。等字眼，就要想到是动态规划类型的题目，要明确状态转移方程，还有个小难点就是一个数的约数怎么求。

设 $dp[i]$  表示从初始石板到目标石板需要跳跃的最少次数。首先dp数组应该初始化一个很大的值，表示都不可达，除了自己到自己需要跳0次，即 $dp[N] = 0$. 

求出当前石块编号的所有约数，对约数们遍历，则有一下状态转移方程(c为约数)：
$$
dp[i + c] = Min\{ dp[i + c], dp[i]+1\}.  ---> dp[i + c] != Integer.MaxValue
$$

$$
dp[i + c] = dp[i]+1;  --->dp[i+c] = Integet.MaxValue
$$

# 代码

```java

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Scanner;

/**
 *
 * [编程题]跳石板  网易秋招
 * @author Hongliang Zhu
 * @create 2020-05-31 21:31
 */
public class skipStone {

    public static void main(String[] args) {

        Scanner sc = new Scanner(System.in);
        int N = sc.nextInt(); // 起始位置
        int M = sc.nextInt(); //  终止位置

        int []dp = new int[M+1]; //  dp[i] ： 到第i个石块最少需要跳多少次。
        Arrays.fill(dp, Integer.MAX_VALUE); //  均初始化为无穷大
        dp[N] = 0; // 自己到自己跳0次

        for(int i = N; i <= M; i++){
            if(dp[i] == Integer.MAX_VALUE) continue; //  不可达
            // 遍历 当前i的约数
            ArrayList<Integer> factors = getFactors(i);
            for(int j = 0;  j < factors.size(); j++){
                int skip = i+factors.get(j);
                if(skip > M){
                    continue;
                }
                if(dp[skip] == Integer.MAX_VALUE){
                    dp[skip] = dp[i]+1;
                }else {
                    dp[skip] = Math.min(dp[skip], dp[i]+1);
                }
            }

        }

        if(dp[M] == Integer.MAX_VALUE)
            System.out.println(-1);
        else
            System.out.println(dp[M]);
    }

    /**
     * 获得当前数的约数 ， 除了1和它自己
     * @param n
     * @return
     */
    public static ArrayList<Integer> getFactors(int n){
        ArrayList<Integer> list = new ArrayList<>();
        for(int i = 2; i <= Math.sqrt(n); i++){
            if(n % i == 0){
                list.add(i);
                if(n / i != i){
                    list.add(n / i);
                }
            }
        }
        return list;
    }
}

```

