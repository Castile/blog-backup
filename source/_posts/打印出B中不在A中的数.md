---
title: 打印出B中不在A中的数
tags:
  - 数组
  - 二分
  - 中等
categories:
  - Algorithm
date: 2020-02-28 22:25:36
---


# 描述

> 一个有序数组A，另一个无序数组B，请打印B中的所有不在A中的数，A数 组长度为N，B数组长度为M。

  

# 分析

方法一： 暴力求解。 对于数组B中的每一个数，都在A中通过遍历的方式找一下； 相当于：B 中每一个数都要在 A 中遍历一遍，则需要操作 N 遍，而 B 中 M 个数都需要按照上面操作一遍，共操作 M * N 遍，因此时间复杂为：O(M*N)。



方法二：二分法。因为A数组有序， 在A中查找的时候使用二分查找算法，故总体时间复杂度为$O(M* log_2^N)$.



方法三：

​		先把数组B排序，然后用类似外排的方式打印所有不在A中出现的数； 因为可以是会用快速排序对数组 B 进行排序 。所以整体时间复杂度为$O(M*log_2^M)$ 。 

​		具体地， 数组 A 开头放置下标 a，数组 B 开头放置下标 b，比较两个下标指向的值若 b 指向的值 < a 指向的值，则 b++同时打印 b 指向的数，否则a++ , 若等于则a++, b++不打印； 因此整体外排时间复杂度最差O(M+N)。则整个算法时间复杂度为    $O(M*log_2^M) + O(M+N)$  。



>  分析：  当 A 数组较短的时候，方法二较好，当 B 数组较短的时候，方法三较好，因为方法三需要对 B 进行排序； 



# 代码实现

## 方法一

```java
// 方法一： 暴力 O(M*N)
    public List<Integer> getNotInArrays(int[] A, int[] B){
        List<Integer> list = new ArrayList<>();
        List<Integer> res = new ArrayList<>();
        for(int a: A){
            list.add(a);
        }
        //循环遍历B数组
        for(int i = 0; i < B.length; i++){
            if(!list.contains(B[i])){
                res.add(B[i]);
            }
        }
        return res;
    }
```

## 方法二

```java
 // 方法二： 二分查找  O(M*longN)
    public List<Integer> getNotInArrays_V2(int[] A, int[] B){
        List<Integer> res = new ArrayList<>();
        boolean contains = false;
        for(int i: B){
            int low = 0;
            int high = A.length - 1;
            while(low <= high){
                int mid = (low+high) >> 1;
                if(A[mid] == i ) {
                    contains = true;
                    break;  //找到了
                }
                else if(A[mid] > i){ //  在A的左边， 更改low和high
                    high = mid - 1;
                }else if(A[mid] < i){ //  在A的右边， 更改low和high
                    low = mid + 1;
                }
            }
            if(!contains){ //  不存在
                res.add(i);
            }
            contains = false; // 复位
        }
        return res;
    }
```

## 方法三

```java
// 方法三： 对B先排序，然后使用外部排序来 求解
    public List<Integer> getNotInArrays_V3(int[] A, int[] B) {
        // 对B先 排序
        Arrays.sort(B);
        List<Integer> res = new ArrayList<>();
        int a = 0;
        int b = 0;
        while ((a < A.length) && (b < B.length)) {
            if (A[a] == B[b]) {
                a++;
                b++;
            } else if (A[a] < B[b]) {
                a++;
            } else if (A[a] > B[b]) {
                res.add(B[b]);
                b++;
            }
        }
        while (b < B.length){
            res.add(B[b++]);
        }
        return res;

    }
```

完整代码：  https://github.com/Castile/algorithm/blob/master/leetcode/src/Sort/GetNotInArrays.java 