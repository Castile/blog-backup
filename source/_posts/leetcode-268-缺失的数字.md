---
title: leetcode-268-缺失的数字
date: 2020-02-02 10:54:27
tags:
	- 算法
	- 位操作
	- 简单
categories:
	- Algorithm
---

[toc]

## 描述

> 给定一个包含 0, 1, 2, ..., n 中 n 个数的序列，找出 0 .. n 中没有出现在序列中的那个数。
>
> 示例 1:
>
> 输入: [3,0,1]
> 输出: 2
> 示例 2:
>
> 输入: [9,6,4,2,3,5,7,0,1]
> 输出: 8
> 链接：https://leetcode-cn.com/problems/missing-number



## 分析

1. 题目说从0~n的数字，所以直接累加数组得到和为sum， 加入数组没有缺失数据，那么完整数组的元素个数为原数组大小加1，利用等差数列的性质，得到从0~n的和len，然后len - sum 就是缺失的那个数字了。

   时间复杂度：O(n)。求出数组中所有数的和的时间复杂度为 O(n)，等差数列公式的时间复杂度为 O(1)，因此总的时间复杂度为 O(n)。
   空间复杂度：O(1)。算法中只用到了O(1) 的额外空间，用来存储答案。

2. 位操作： 异或

   | a    | b    | 异或结果 |
   | ---- | ---- | :------: |
   | 0    | 0    |    0     |
   | 0    | 1    |    1     |
   | 1    | 0    |    1     |
   | 1    | 1    |    0     |

    其他数字 与 0 异或都得到它自己。

   此外异或运算满足交换律.  如：

   | 0    | 1    | 2    | 3    |
   | ---- | ---- | ---- | ---- |
   | 3    | 4    | 0    | 1    |

    下标与数组值异或操作：  4 ^ 0 ^ 3 ^ 1 ^  4 ^ 2 ^ 0 ^ 3 ^ 1 ( 前面的4是为了添加最后一位数字，为原数组的长度) ----> 可得到缺失的值为2。

   时间复杂度：O(n)。这里假设异或运算的时间复杂度是常数的，总共会进行O(n) 次异或运算，因此总的时间复杂度为 O(n)。
   空间复杂度：O(1)。算法中只用到了O(1) 的额外空间，用来存储答案。

3. 哈希表

   将数组中的元素放入HashSet哈希表中， 插入哈希表的时间复杂度为O(1)， N个数时间复杂度为O(n)， 然后从0到数组放长度区间内遍历， 判断哈希表中是否存在此数字，若不存在， 则此数字就是缺失的数字。遍历时间复杂度为O(n)，  故总体时间复杂度为O(n)。空间复杂度为O(n)。

4. 还可以先排序，再找出缺失的数字，但是排序的时间复杂度不是线性时间， 为O(logN)

   

## 代码

方法一：

```java
class Solution {
    public int missingNumber(int[] nums) {
        int  sum = 0;
        for(int i = 0 ; i < nums.length; i++){ //数组的和
            sum += nums[i];
        }
        // 缺失一个数字： 本来的和应该是：  
        int len = (nums.length + 1) * nums.length / 2; 
        return len - sum;
    }

}
```

<img src="leetcode-268-缺失的数字/1580614821325.png" alt="1580614821325" style="zoom:80%;" />



位操作：

```java
class Solution {
    public int missingNumber(int[] nums) {
        int m = nums.length;
        for(int i = 0;  i < nums.length; i++){
            m ^= i ^ nums[i];
        }
        return m;
    }
}
```

<img src="leetcode-268-缺失的数字/1580614957343.png" alt="1580614957343" style="zoom:80%;" />

哈希表：

```java
class Solution {
    public int missingNumber(int[] nums) {
        Set<Integer> set = new HashSet<Integer>();
        for( int i = 0; i <nums.length; i++){
            set.add(nums[i]);
        }
        for(int i = 0 ; i <= nums.length; i++){
            if( !set.contains(i))
                return i;
        }
        
        return -1;
    }
       

}
```

<img src="leetcode-268-缺失的数字/1580615699820.png" alt="1580615699820" style="zoom:80%;" />

排序：

```java
class Solution {
    public int missingNumber(int[] nums) {
      Arrays.sort(nums);
      // 判断末尾
      if(nums[nums.length - 1] !=  nums.length){
          return nums.length;
      }
      // 判断0 是否在首位
      if(nums[0] != 0){
          return 0;
      }

      for( int i = 0; i <nums.length ; i++){
          if(i != nums[i])
            return i;
      }
      return -1;
    }   
}
```

<img src="leetcode-268-缺失的数字/1580616038690.png" alt="1580616038690" style="zoom:80%;" />