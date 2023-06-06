---
title: 网易秋招编程题-回文序列
tags:
  - 数据结构
  - 算法
  - 困难
categories:
  - Algorithm
date: 2020-05-31 17:19:43
toc: true
---


# 描述

> 如果一个数字序列逆置之后跟原序列是一样的就称这样的数字序列为回文序列。例如：
>  {1, 2, 1}, {15, 78, 78, 15} , {112} 是回文序列, 
>  {1, 2, 2}, {15, 78, 87, 51} ,{112, 2, 11} 不是回文序列。
>  现在给出一个数字序列，允许使用一种转换操作：
>  选择任意两个相邻的数，然后从序列移除这两个数，并用这两个数字的和插入到这两个数之前的位置(只插入一个和)。
>  现在对于所给序列要求出最少需要多少次操作可以将其变成回文序列。 

输入：

> 输入为两行，第一行为序列长度n ( 1 ≤ n ≤ 50) 第二行为序列中的n个整数item[i] (1 ≤ item[i] ≤ 1000)，以空格分隔。

输出：

> 输出一个数，表示最少需要的转换次数

示例：

> 输入
>
> 4 1 1 1 3
>
> 输出
>
> 2

# 思路

首先回文序列一定是两端相等，对于这样的问题，选用双端队列来处理，或者双向链表，便于首尾操作。首先判断首尾是否相等，如果相等的话，则让首尾元素出队，在剩下的元素中进一步判断，减小问题的规模。 那么由于题目说需要的最少操作次数，所以需要在小的一端进行相邻元素的加操作。如果首 < 尾，则将首元素的以及其相邻的元素加起来，然后这两个元素出队，加和进队。如果首> 尾， 则在尾部元素进行相加的操作，操作和首部类似。然后在进行下一步的判断，看看首尾元素是否相等，如若还不相等，则继续操作，如果相等，则首尾出队，直至队列中元素的个数只有一个，此时一定是回文序列。



# 代码实现

```java

import java.util.LinkedList;
import java.util.Scanner;

/**
 * 回文序列
 * @author Hongliang Zhu
 * @create 2020-05-31 16:53
 */

/*

 */
public class netease01 {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int n = scanner.nextInt();  // 个数
        LinkedList<Integer> items = new LinkedList<>();
        for(int i = 0; i < n; i++){
            items.offer(scanner.nextInt());
        }
        int count = 0; // 计数

        while (items.size() > 1){
            int first = items.getFirst();
            int end = items.getLast();
            if(first == end){
                // 首尾出队列
                items.poll();
                items.removeLast();
            }else {
                int add = 0;

                if(first <= end){ // 队首小 ，加上其相邻的元素
                    count++;
                    add+=first;
                    items.removeFirst();
                    add+=items.removeFirst();
                    //  插入
                    items.addFirst(add);
                }else {
                    // 队尾小
                    count++;
                    add+=end;
                    items.removeLast();
                    add+=items.removeLast();
                    // 插入
                    items.addLast(add);
                }
            }
        }


        System.out.println(count);


    }

}

```

![1590916740319](netease/1590916740319.png)



