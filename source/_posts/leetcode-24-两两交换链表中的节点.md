---
title: leetcode-24-两两交换链表中的节点
date: 2020-02-03 16:18:28
tags:
	- 链表
	- 算法
	- 递归
	- 中等
categories:
	- Algorithm
---



# 描述

> 给定一个链表，两两交换其中相邻的节点，并返回交换后的链表。
>
> 你不能只是单纯的改变节点内部的值，而是需要实际的进行节点交换。
>
> 示例：
>
> 给定 1->2->3->4, 你应该返回 2->1->4->3
> 链接：https://leetcode-cn.com/problems/swap-nodes-in-pairs
>



#  分析

1. 递归：

   ​		我们可以定义函数 swap(head) 以实现解决方案，其中输入的参数 head 指向链表的头节点。* 而该函数应当返回将链表中每两个相邻节点交换后得到的新列表的头节点 head 。

   ​		按照我们上面列出的步骤，我们可以按下面的流程来实现函数：

   ​		（1）首先，我们交换列表中的前两个节点，也就是 head 和 head.next；

   ​		（2）然后我们以 swap(head.next.next) 的形式调用函数自身，以交换头两个节点之后列表的其余部分。

   ​		（3）最后，我们将步骤（2）中的子列表的返回头与步骤（1）中交换的两个节点相连，以形成新的链					表。

2. 迭代

   新增一个头节点 dummy node， dummy.next = head； 更好操作链表。流程图如下：

   <img src="leetcode-24-两两交换链表中的节点/1580719129953.png" alt="1580719790068" style="zoom:80%;" />

# 代码

源码： https://github.com/Castile/algorithm/blob/master/leetcode/src/LinkedList/leetcode24_SwapNodesInPairs.java 

```java
package LinkedList;

/**
 * @author Hongliang Zhu
 * @create 2020-02-03 15:51
 */

class ListNode {
      int val;
      ListNode next;
      ListNode(int x) { val = x; }
}

public class leetcode24_SwapNodesInPairs {
   // 递归解法
    public ListNode swapPairs(ListNode head) {
        if(head == null || head.next == null)     return head;
        ListNode n = head.next.next;  // 下一次要传递的节点
        //交换这两个节点
        ListNode p = head.next;
        p.next = head;
        head.next = swapPairs(n); // 递归
        return p; // 返回交换之后的头结点
    }

    // 迭代
    public ListNode swapPairs_it(ListNode head) {
        ListNode dummy = new ListNode(-1);
        dummy.next = head;
        ListNode pre = dummy;
        while(head != null && head.next != null){
            ListNode first = head;
            ListNode second = head.next;
            // 交换
            first.next = second.next;
            second.next = first;
            pre.next = second;
            // 初始化头
            head = first.next;
            pre = first;
        }

        return dummy.next;
    }
}

```

