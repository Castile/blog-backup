---
title: leetcode-119-杨辉三角2
date: 2020-02-06 15:28:31
tags:
	- 算法
	- 简单
	- dp
	- 递归
categories:
	- Algorithm
---

# 描述

> leetcode119： 杨辉三角2 【简单】
>
>  给定一个非负索引 *k*，其中 *k* ≤ 33，返回杨辉三角的第 *k* 行。 
>
> <img src="F:\blog\source\_posts\leetcode-119-杨辉三角2\PascalTriangleAnimated2.gif" alt="img" style="zoom:80%;" />
>
> 在杨辉三角中，每个数是它左上方和右上方的数的和。
>
> **示例:**
>
> ```
> 输入: 3
> 输出: [1,3,3,1]
> ```



# 分析

1.  这题和前一题一样，只不过返回特定层，同样的思路

   ```java
   class Solution {
       public List<Integer> getRow(int rowIndex) {
           List<List<Integer>> triangle = new ArrayList<>();
           int[][] dp = new int[rowIndex+2][rowIndex+2];
           if(rowIndex+1 == 0) return null;
           for(int i = 1 ; i <= rowIndex+1; i++){
               List<Integer> list =  new ArrayList<>();
               for(int j = 1; j <= i ; j++){
                   list.add(calc(dp, i, j));
               }
               triangle.add(list);
           }
           return triangle.get(rowIndex);  // 注意返回的是指定层
       }
       public int calc(int[][] dp, int i, int j){
           if( j == 1 || i == j){
               dp[i][j] = 1;
               return 1;
           }      
           if(dp[i][j] != 0)   return dp[i][j];
           dp[i][j] = calc(dp, i - 1, j - 1) + calc(dp, i - 1, j);
           return dp[i][j];
       }
   }
   ```

   

2. 这题和[杨辉三角1]( [https:/Castile.github.io/2020/02/06/leetcode-118-杨辉三角1/]([https:/Castile.github.io/2020/02/06/leetcode-118-杨辉三角1/) )的题目差不多，118题需要保存所有的，但是这题只需要返回指定层，因为当前层的值只依赖于上一层的值，故使用一个list来保存上一层的值。

   ```java
   public List<Integer> getRow(int rowIndex) {
           List<Integer> pre = new ArrayList<>();
           List<Integer> cur = new ArrayList<>();
           for (int i = 0; i <= rowIndex; i++){
               cur = new ArrayList<>();
               for(int j = 0; j <= i ; j++){
                   if(j == 0 || i == j){
                       cur.add(1);
                   }else{
                       cur.add(pre.get(j - 1) + pre.get(j));
                   }
               }
               pre = cur;
           }
           return cur;
       }
   ```

3. 基于2可以继续优化：以把 pre 的 List 省去。这样的话，cur每次不去新建 List，而是把cur当作pre。

   又因为更新当前 `j` 的时候，就把之前`j`的信息覆盖掉了。而更新 `j + 1` 的时候又需要之前j的信息，所以在更新前，我们需要一个变量把之前`j`的信息保存起来。

   ```java
    public List<Integer> getRow(int rowIndex) {
           int pre = 1;
           List<Integer> cur = new ArrayList<>();
           cur.add(1); // j == 0
           for(int i = 1; i <= rowIndex; i++){
               for(int j = 1; j < i; j++){
                   int tmp = cur.get(j);
                   cur.set(j, pre + cur.get(j));
                   pre = tmp;
               }
               cur.add(1);  // j == i
           }
           return cur;
       }
   ```

4. 除了上边优化的思路，还有一种想法，那就是倒着进行，这样就不会存在覆盖的情况了。因为更新完j的信息后，虽然把`j`之前的信息覆盖掉了。但是下一次我们更新的是`j - 1`，需要的是`j - 1`和`j - 2` 的信息，`j`信息覆盖就不会造成影响了。







# 代码



 https://github.com/Castile/algorithm/blob/master/leetcode/src/RecurrenceAndDynamicProgramming/leetcode119_PascalTriangle2.java 



相似题目：[杨辉三角](https:/Castile.github.io/2020/02/06/leetcode-118-杨辉三角1/ )

