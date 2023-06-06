---
title: leetcode42接雨水
tags:
  - 算法
  - 困难
categories:
  - Algorithm
date: 2020-10-04 19:58:22
---


# 描述

给定 n 个非负整数表示每个宽度为 1 的柱子的高度图，计算按此排列的柱子，下雨之后能接多少雨水。

![1601803740558](leetcode42接雨水\1601803740558.png)

上面是由数组 [0,1,0,2,1,0,1,3,2,1,2,1] 表示的高度图，在这种情况下，可以接 6 个单位的雨水（蓝色部分表示雨水）

示例:

输入: [0,1,0,2,1,0,1,3,2,1,2,1]

输出: 6

# 题解

对于每一个位置，该位置能装最大的雨水与两边中最大高度中的最小值有关系。

即要先求出min{lmax， rmax}。我们只需要找到左边的最大和右边的最大高度就行。

该位置能接到的雨水就是其高度差。

注意： 第一个格子和最后一个格子不能接到雨水。

## 暴力解法

时间复杂度为O(N^2)

```java
class Solution {
    public int trap(int[] height) {
        int n = height.length;
        
        int res = 0;
        for(int i = 1; i < n -1; i++){
            int lmax = 0;
            int rmax = 0;
            //找右边的
            for(int j = i; j < n; j++){
                rmax = Math.max(rmax, height[j]);
            }
            // 左边的
            for(int j = i; j >= 0; j--){
                lmax = Math.max(lmax, height[j]);
            }

            res += Math.min(lmax, rmax)- height[i];


        }

        return res;

    }
}
```

这种太暴力了，每次都得重新计算当前位置的左边最大和右边最大，不如先将每个位置的左边最大和右边最大都保存下来啊，这样就不用每次重新计算了，可能降低时间复杂度。

```java
class Solution {
    public int trap(int[] height) {
        if(height == null || height.length == 0){
            return 0;
        }
        int n = height.length;
        int[] lmax = new int[n];
        int[] rmax = new int[n];
        lmax[0] = height[0];
        rmax[n-1] = height[n-1];
        // 从左往右计算lmax
        for(int i = 1; i < n; i++){
            lmax[i] = Math.max(height[i], lmax[i-1]);
        }
        // 从右往左计算右边最大
        for(int i = n-2; i >= 0; i--){
            rmax[i] = Math.max(height[i], rmax[i+1]);
        }
        int res = 0;
        // 计算
        for(int i = 1; i < n -1; i++){

            res += Math.min(lmax[i], rmax[i])- height[i];
        }

        return res;

    }
}
```



## 双指针

使用双指针边走边算，减少空间 复杂度。

```java
class Solution {
    public int trap(int[] height) {
        if(height.length == 0)  return 0;
        int n = height.length;
        int  left = 0;
        int right  = n-1;
        int l_max=height[0], r_max = height[n-1];
        int ans = 0;
        while(left <= right){
            l_max = Math.max(l_max, height[left]);
            r_max = Math.max(r_max, height[right]);

            if(l_max < r_max){
                ans += l_max - height[left];
                left++;
            }else{
                ans +=  r_max  - height[right];     
                right--;
            }
        
        }
        return ans;
    }
}
```

