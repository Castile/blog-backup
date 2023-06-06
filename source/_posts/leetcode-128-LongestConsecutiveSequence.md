---
title: leetcode-128-最长连续序列
date: 2020-01-22 18:15:19
tags:
	- 数组
	- 算法
	- 哈希
	- 困难
categories:
	- Algorithm
---

## 描述

> LeetCode128: 最长连续序列longest-consecutive-sequence
>
> 给定一个未排序的整数数组，找出最长连续序列的长度。
>
> 要求算法的时间复杂度为 ==**O(n)**==。 【困难】
>
> 示例:
>
> 输入: [100, 4, 200, 1, 3, 2]
> 输出: 4
> 解释: 最长连续序列是 [1, 2, 3, 4]。它的长度为 4。
>
> 链接：https://leetcode-cn.com/problems/longest-consecutive-sequence

## 分析



​	如果允许O(nlogn)的复杂度，那么可以先排序，可是本题要求	O(n)	。
由于序列里的元素是无序的，又要求	O(n)	，首先要想到用哈希表。
用一个哈希表存储所有出现过的元素，对每个元素，以该元素为中心，往左右扩张，直到不连续为止，记 录下最长的长度。

##  Java代码实现

```java
package Arrays;

import java.util.HashSet;

/**
 * @author Hongliang Zhu
 * @create 2020-01-22 18:15
 */

/*
给定一个未排序的整数数组，找出最长连续序列的长度。
要求算法的时间复杂度为 O(n)。
 */
public class leetcode128_LongestConsecutiveSequence {
    public static int longestConsecutive(int[] nums) {
        HashSet<Integer> myset = new HashSet<>();
        for(int i: nums){
            myset.add(i);
        }
        int longest = 0;
        for(int i: nums) {
            int len = 1;
            for(int j = i+1; myset.contains(j); j++){
                myset.remove(j);
                len++;
            }
            for (int j = i - 1; myset.contains(j); j--){
                myset.remove(j);
                len++;
            }
            longest = Math.max(longest, len);
        }

        return longest;

    }

    public static void main(String[] args) {
        int []nums = {100, 4, 200, 1, 3, 2};
        int len = longestConsecutive(nums);
        System.out.println(len);

    }
}

```

输出4

时间复杂度为O(n) ， 空间复杂度O(n)

Leetcode官方：

```java
class Solution {
    public int longestConsecutive(int[] nums) {
        if (nums.length == 0) {
            return 0;
        }

        Arrays.sort(nums);

        int longestStreak = 1;
        int currentStreak = 1;

        for (int i = 1; i < nums.length; i++) {
            if (nums[i] != nums[i-1]) {
                if (nums[i] == nums[i-1]+1) {
                    currentStreak += 1;
                }
                else {
                    longestStreak = Math.max(longestStreak, currentStreak);
                    currentStreak = 1;
                }
            }
        }

        return Math.max(longestStreak, currentStreak);
    }
}

作者：LeetCode
链接：https://leetcode-cn.com/problems/longest-consecutive-sequence/solution/zui-chang-lian-xu-xu-lie-by-leetcode/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

