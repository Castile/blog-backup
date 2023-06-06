---
title: leetcode-1-两数之和
date: 2020-01-23 21:54:23
tags:
	- 数组
	- 算法
	- 简单
categories:
	- Algorithm
---

## 描述

> 给定一个整数数组 nums 和一个目标值 target，请你在该数组中找出和为目标值的那 两个 整数，并返回他们的数组下标。
>
> - [x] 你可以假设每种输入只会对应一个答案。但是，**你不能重复利用这个数组中同样的元素**。
>
>
> 示例:
>
> 给定 nums = [2, 7, 11, 15], target = 9
>
> 因为 nums[0] + nums[1] = 2 + 7 = 9
> 所以返回 [0, 1]
> 链接：https://leetcode-cn.com/problems/two-sum





## 分析

1. 暴力方法： 直接两层循环，时间复杂度较高：O(n^2^)

2. 哈希方法：使用哈希表可以实现O(1)级别的存取。存储每个数对应的下标，复杂度	O(n)	

   参考：

   HashMap的时间复杂度O(1)的思考：

   ​	原文链接：https://blog.csdn.net/donggua3694857/article/details/64127131

## Java代码实现

```java
package Arrays;
import java.util.HashMap;

/**
 * @author Hongliang Zhu
 * @create 2020-01-23 21:39
 */
public class leetcode_1_twoSum {

    // 暴力法
    public static int[] twoSum(int[] nums, int target) {
        int[] a = new int[2];
        for (int i = 0; i < nums.length; i++) {
            for (int j = i + 1; j < nums.length; j++) {
                if (nums[i] + nums[j] == target) {
                    a[0] = i;
                    a[1] = j;
                    break;
                }
            }
        }

        return a;
    }

    // 哈希
    public static int[] twoSum1(int[] nums, int target) {
        HashMap<Integer, Integer> mymap = new HashMap<>();
        for(int i = 0; i < nums.length;  i++){
            mymap.put(nums[i], i);
        }

        for(int i = 0; i < nums.length; i++){
            int t = target - nums[i];
            if(mymap.containsKey(t) && mymap.get(t) != i ){// 注意后面这个条件，题目要求
                return new int[] {i,mymap.get(t)};
            }
        }

        return null;

    }


    public static void main(String[] args) {
       int[] nums = { 2,11,15, 7};
       int target = 9;
       int []result = twoSum1(nums, target);


       for (int i = 0;  i < result.length; i++)
       {
           System.out.println(result[i]);
       }

    }
}
```

参考HashMap：

https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247486169&idx=2&sn=9818c995d51a19cd4a40c2605bdcfa5d&chksm=ebd74bd8dca0c2cefe86f54bcdd7f799ceda0a14deb72a4fcec7efa29fc3deffbc6e80d8a90f&mpshare=1&scene=1&srcid=&sharer_sharetime=1575479594341&sharer_shareid=2d7d0e474d11d42bad66b1f70e2c85ff&key=688085f24308deb8e963b43a687ea8ed3be23533e2ae4e751f02a336bb46979d39e6c74e731daa5fc22d9e719338c7f0f98152a12a38beef1d0023e2939dd0eda93264a9d032b8cc555448c332453c25&ascene=1&uin=MjA3NDA5MzU4MQ==&devicetype=Windows%2010&version=62070158&lang=zh_CN&exportkey=A5ZIZKTn0EuksyOXwEiV%2bEk=&pass_ticket=Nb/JBXAYTcQup5FBKcfsQy6kFv5X2eJwQ333U4h1UYJmrnawwezuSj8nX18XzQ8s