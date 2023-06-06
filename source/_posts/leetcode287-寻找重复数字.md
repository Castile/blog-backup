---
title: leetcode287_寻找重复数字
tags:
  - 中等
  - 腾讯
categories:
  - Algorithm
date: 2020-09-02 23:28:01
---


# 寻找重复数字

给定一个包含 n + 1 个整数的数组 nums，其数字都在 1 到 n 之间（包括 1 和 n），可知至少存在一个重复的整数。假设只有一个重复的整数，找出这个重复的数。

示例 1:

输入: [1,3,4,2,2]
输出: 2
示例 2:

输入: [3,1,3,4,2]
输出: 3



# 解决思路

使用环形链表II的方法解题（142.环形链表II），使用 142 题的思想来解决此题的关键是要理解如何将输入的数组看作为链表。

首先明确前提，整数的数组 nums 中的数字范围是 [1,n]。考虑一下两种情况：

如果数组中没有重复的数，以数组 [1,3,4,2]为例，我们将数组下标 n 和数 nums[n] 建立一个映射关系 f(n)f(n)f(n)，
其映射关系 n->f(n)为：
0->1
1->3
2->4
3->2
我们从下标为 0 出发，根据 f(n)f(n)f(n) 计算出一个值，以这个值为新的下标，再用这个函数计算，以此类推，直到下标超界。这样可以产生一个类似链表一样的序列。
0->1->3->2->4->null

如果数组中有重复的数，以数组 [1,3,4,2,2] 为例,我们将数组下标 n 和数 nums[n] 建立一个映射关系 f(n)f(n)f(n)，
其映射关系 n->f(n) 为：
0->1
1->3
2->4
3->2
4->2
同样的，我们从下标为 0 出发，根据 f(n)计算出一个值，以这个值为新的下标，再用这个函数计算，以此类推产生一个类似链表一样的序列。
0->1->3->2->4->2->4->2->……

![1599056330724](leetcode287-寻找重复数字\1599056330724.png)

从理论上讲，数组中如果有重复的数，那么就会产生多对一的映射，这样，形成的链表就一定会有环路了。

综上:

1.数组中有一个重复的整数->链表中存在环

2.找到数组中的重复整数 ->找到链表的环入口

至此，问题转换为 142 题。那么针对此题，快、慢指针该如何走呢。根据上述数组转链表的映射关系，可推出
142 题中慢指针走一步 slow = slow.next ==> 本题 slow = nums[slow]
142 题中快指针走两步 fast = fast.next.next ==> 本题 fast = nums[nums[fast]]

```java
class Solution {
    public int findDuplicate(int[] nums) {

        int slow = 0;
        int fast = 0;
        slow = nums[slow];
        fast = nums[nums[fast]];
        while(slow != fast){
            slow = nums[slow];
            fast = nums[nums[fast]];
        }

        int p = slow;
        int q = 0;
        while(p != q){
            p = nums[p];
            q = nums[q];
        }

        return q;
    }
}
```



# 二分法

二分法的思路是先猜一个数（有效范围 [left, right]里的中间数 mid），然后统计原始数组中小于等于这个中间数的元素的个数 cnt，如果 cnt 严格大于 mid，（注意我加了着重号的部分「小于等于」、「严格大于」）。根据抽屉原理，重复元素就在区间 [left, mid] 里；

以 [2, 4, 5, 2, 3, 1, 6, 7] 为例，一共 8 个数，n + 1 = 8，n = 7，根据题目意思，每个数都在 1 和 7 之间。

例如：区间\[1,7]的中位数是 4，遍历整个数组，统计小于等于 4 的整数的个数，如果不存在重复元素，最多为 4 个。等于 4 的时候区间 \[1,4] 内也可能有重复元素。但是，如果整个数组里小于等于 4 的整数的个数严格大于 4 的时候，就可以说明重复的数存在于区间\[1,4]。

```java
public class Solution {

    public int findDuplicate(int[] nums) {
        int len = nums.length;
        int left = 1;
        int right = len - 1;
        while (left < right) {
// 在 Java 里可以这么用，当 left + right 溢出的时候，无符号右移保证结果依然正确
            int mid = (left + right) >>> 1;
            int cnt = 0;
            for (int num : nums) {
                if (num <= mid) {
                    cnt += 1;
                }
            }

            // 根据抽屉原理，小于等于 4 的个数如果严格大于 4 个
            // 此时重复元素一定出现在 [1, 4] 区间里
            if (cnt > mid) {
                // 重复元素位于区间 [left, mid]
                right = mid;
            } else {
                // if 分析正确了以后，else 搜索的区间就是 if 的反面
                // [mid + 1, right]
                left = mid + 1;
            }
        }
        return left;
    }
}

```





# 参考



1. https://leetcode-cn.com/problems/find-the-duplicate-number/solution/287xun-zhao-zhong-fu-shu-by-kirsche/
2. https://leetcode-cn.com/problems/find-the-duplicate-number/solution/er-fen-fa-si-lu-ji-dai-ma-python-by-liweiwei1419/