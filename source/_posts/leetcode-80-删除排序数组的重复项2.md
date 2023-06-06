---
title: leetcode-80-删除排序数组的重复项2
date: 2020-01-22 16:47:45
tags:
	- 算法
	- 数组
	- 双指针
	- 中等
categories: 
	- Algorithm
---

## 描述

leetcode-80-删除排序数组的重复项2：

> 给定一个排序数组，你需要在原地删除重复出现的元素，使得每个元素最多出现两次，返回移除后数组的新长度。不要使用额外的数组空间，你必须在原地修改输入数组并在使用 O(1) 额外空间的条件下完成。
> 链接：https://leetcode-cn.com/problems/remove-duplicates-from-sorted-array-ii
> 相似题目： [https:/Castile.github.io/2020/01/21/leetcode26-删除排序数组的重复项/](https://castile.github.io/Castile.github.io/2020/01/21/leetcode26-删除排序数组的重复项/) 
>
> **==tag：双指针思想==**

示例 1:

给定 nums = [1,1,1,2,2,3],

函数应返回新长度 length = 5, 并且原数组的前五个元素被修改为 1, 1, 2, 2, 3 。

你不需要考虑数组中超出新长度后面的元素。
示例 2:

给定 nums = [0,0,1,1,1,1,2,3,3],

函数应返回新长度 length = 7, 并且原数组的前五个元素被修改为 0, 0, 1, 1, 2, 3, 3 。

你不需要考虑数组中超出新长度后面的元素。

------



## 分析

​	覆盖多余的重复项。由于题目要求原地操作，设置两个指针，一个为快指针，用来遍历整个数组，一个慢指针，用来记录数组的长度以及覆盖数组的位置下标。题目要求每个元素最多出现两次，则应该引入一个计数变量，记录元素出现的次数。

​	特别地，题目给的数组为已经排好序的数组，如果未排序，则需要引入一个hashmap来记录出现次数。

​	从下标1开始遍历，nums[i-1]  ?= nums[i] ：如果相等，则更新

 时间复杂度O(n)， 空间复杂度O(1)

## Java代码实现



```java
/**
 * @author Hongliang Zhu
 * @create 2020-01-22 10:07
 */
public class leetcode_80_remove_duplicates_from_sorted_array_ii {

    public static int removeDuplicates(int[] nums) {
        if(nums.length == 0)
            return 0;
        int p = 1;
        int c = 1; // 计数
        for(int i = 1; i < nums.length;  i++){
            if(nums[i] == nums[i-1]){
                c++;
            }else {
                c = 1;  //复位
            }

            if( c <= 2) {
                nums[p] = nums[i];
                p++;
            }

        }

        return p;
    }

    public static void main(String[] args) {

        int []nums = {0,0,1,1,1,1,2,3,3};
        int len = removeDuplicates(nums);
        System.out.println(len);
        for (int i = 0; i < len; i++) {
            System.out.println(nums[i]);
        }

    }

}

```

输出：

```c#
7
0,0,1,1,2,3,3,
```



另外：

```java
    public static int removeDuplicates2(int[] nums) {
        if (nums.length <= 2){
            return nums.length;
        }
        int index = 2;
        for(int i = 2; i < nums.length; i++){
            if(nums[index-2] != nums[i]){
                nums[index++] = nums[i];
            }
        }


        return index;
    }
```

扩展性，例如将上面的数字2	改为	3	， 就变成了允许重复最多3次。

**相似题目： [https:/Castile.github.io/2020/01/21/leetcode26-删除排序数组的重复项/](https://castile.github.io/Castile.github.io/2020/01/21/leetcode26-删除排序数组的重复项/) 

