---
title: leetcode-21-合并两个有序的链表
date: 2020-02-16 12:48:30
tags:
	- 链表
	- 递归
	- 简单
categories:
	- Algorithm

cover: /img/cover/mergeList.jpg

---

​	

# 描述

> Leetcode-21： 合并两个有序的链表
>
> 将两个有序链表合并为一个新的有序链表并返回。新链表是通过拼接给定的两个链表的所有节点组成的。 
>
> 示例：
>
> 输入：1->2->4, 1->3->4
> 输出：1->1->2->3->4->4
> 链接：https://leetcode-cn.com/problems/merge-two-sorted-lists
>



# 分析

1. 迭代：这题目是简单题，其实就是归并排序中的归并操作。不再赘述。

2. 递归：

   ​	终止条件：两条链表分别名为 l1 和 l2，当 l1 为空或 l2 为空时结束

   ​	返回值：每一层调用都返回排序好的链表头
   ​	本级递归内容：如果 l1 的 val 值更小，则将 l1.next 与排序好的链表头相接，l2 同理

   时间复杂度： O(n+m)   空间复杂度：O(n+m)



# 代码

github： https://github.com/Castile/algorithm/blob/master/leetcode/src/LinkedList/Leetcode21_MergeLinkedList.java 

```java
class Solution {
    public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
        ListNode dummy= new ListNode(-1);
        ListNode list = dummy;
        ListNode p1 = l1;
        ListNode p2 = l2;
        while(p1 != null && p2 != null){
            if(p1.val > p2.val){
                list.next = p2;
                p2 = p2.next;

            }else
            {
                list.next = p1;
                p1 =  p1.next;
            }
            list = list.next;
        }
        //处理p1
        if(p1 != null){
            list.next = p1;
        }
        if(p2 != null){
            list.next = p2;
        }

        return dummy.next;


    }

    // 递归
    public ListNode mergeTwoLists_Cur(ListNode l1, ListNode l2) {
        if(l1 == null)  return l2;
        if(l2 == null)  return l1;
        if(l1.val > l2.val){
            l2.next = mergeTwoLists_Cur(l1, l2.next);
            return l2;
        }else{
            l1.next = mergeTwoLists_Cur(l1.next, l2);
            return l1;
        }
    }



}
```

