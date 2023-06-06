---
title: topK问题
tags:
  - topK
  - 中等
  - 算法
categories:
  - Algorithm
date: 2020-09-07 23:15:49
toc: true
---


leetcode上有不少topK的问题，而且topK问题也是面试必问的，所以在此做一个总结。

# [347. 前 K 个高频元素](https://leetcode-cn.com/problems/top-k-frequent-elements/)

给定一个非空的整数数组，返回其中出现频率前 k 高的元素。 

> 示例 1:
>
> 输入: nums = [1,1,1,2,2,3], k = 2
>
> 输出: [1,2]
>
> 
>
> 示例 2:
>
> 输入: nums = [1], k = 1
>
> 输出: [1]

要求时间复杂度为`O(nlogn)`

## 堆排序思想

先统计每一个数字出现的次数，然后维护一个大小为k的小根堆，小根堆按照数字出现 的频率排序，当堆中元素小于k时，加入小根堆当中，如果小根堆元素=k，则比较堆顶与当前元素的频率，如果比堆顶小，说明，当前堆中已经有k个元素出现的频率比这个数大；如果堆顶元素的频率比当前元素出现的频率小的话，则堆顶弹出，新元素进堆。

```java 
public int[] topKFrequent(int[] nums, int k) {
//        Map<Integer, Integer> map = new HashMap<>();

        // 统计每个数字出现的次数
        Map<Integer, Integer> map = IntStream.of(nums).boxed().collect(Collectors.toMap(e -> e, e -> 1, Integer::sum));

        PriorityQueue<Integer> q = new PriorityQueue<>((a, b)->map.get(a) - map.get(b)); // 小根堆

        Set<Integer> integers = map.keySet();
        for(int num: integers){
            if(q.size() < k){
                q.offer(num);
            }else{
                if( map.get(q.peek()) < map.get(num)){
                    q.poll();
                    q.offer(num);
                }
            }
        }
        int i = 0;
        int[] res = new int[k];
        while (!q.isEmpty()){
            res[i++] = q.poll();
        }
        return res;

    }
```



## 基于二叉搜索树

```java
class Solution {
    public int[] topKFrequent(int[] nums, int k) {
        // 统计每个数字出现的次数
        Map<Integer, Integer> counterMap = IntStream.of(nums).boxed().collect(Collectors.toMap(e -> e, e -> 1, Integer::sum));
        // 定义二叉搜索树：key 是数字出现的次数，value 是出现了key次的数字列表。
        TreeMap<Integer, List<Integer>> treeMap = new TreeMap<>();
        // 维护一个有 k 个数字的二叉搜索树：
        // 不足 k 个直接将当前数字加入到树中；否则判断当前树中的最小次数是否小于当前数字的出现次数，若是，则删掉树中出现次数最少的一个数字，将当前数字加入树中。
        int count = 0;
        for(Map.Entry<Integer, Integer> entry: counterMap.entrySet()) {
            int num = entry.getKey();
            int cnt = entry.getValue();
            if (count < k) {
                treeMap.computeIfAbsent(cnt, ArrayList::new).add(num);
                count++;
            } else {
                Map.Entry<Integer, List<Integer>> firstEntry = treeMap.firstEntry();
                if (cnt > firstEntry.getKey()) {
                    treeMap.computeIfAbsent(cnt, ArrayList::new).add(num);
                    List<Integer> list = firstEntry.getValue();
                    if (list.size() == 1) {
                        treeMap.pollFirstEntry();
                    } else {
                        list.remove(list.size() - 1);
                    }
                }
            }
        }
        // 构造返回结果
        int[] res = new int[k];
        int idx = 0;
        for (List<Integer> list: treeMap.values()) {
            for (int num: list) {
                res[idx++] = num;
            }
        }
        return res;
    }
}

```



## 基于桶排序

```java 
  public int[] topKFrequent1(int[] nums, int k) {

        Map<Integer, Integer> map = IntStream.of(nums).boxed().collect(Collectors.toMap(e -> e, e -> 1, Integer::sum));
        // 每个桶 存放当前频率的元素
        List<Integer>[]  bucket = new ArrayList[nums.length+1];
//        Arrays.fill(bucket, new ArrayList());

        for(int i = 0;  i< bucket.length; i++){
            bucket[i] = new ArrayList<>();
        }

        map.forEach((key, count)->{
            bucket[count].add(key);
        });

        int[] res = new int[k];
        int n = 0;
        // 从后往前遍历
        for(int i = bucket.length-1; i > 0; i--){
            for(int num : bucket[i]){
                res[n++] = num;
                if(n == k){
                    return res;
                }
            }
        }

        return res;
    }
```

## 基于快速选择算法

```java
 /**
     * 基于快速排序
     * @param nums
     * @param k
     * @return
     */
    public  int[] topKFrequent2(int[] nums, int k) {
        // 统计每个数字出现的次数
        Map<Integer, Integer> map = IntStream.of(nums).boxed().collect(Collectors.toMap(e -> e, e -> 1, Integer::sum));
        Pair[] p = new Pair[nums.length];
        Pair[] pairs = IntStream.of(nums).distinct().boxed().map(num -> new Pair(num, map.get(num))).toArray(Pair[]::new);
        Pair[] ans = qselect(pairs, 0, pairs.length-1, k-1); // 下标为k-1

        int[] res = new int[k];
        int i = 0;
        for(Pair pair: ans){
            res[i++] = pair.key;
        }
        return res;
    }

    private Pair[] qselect(Pair[] pairs, int l, int r, int aux) {
        if( l <= r){
            int p = partition(pairs, l, r);
            if( p == aux){
                return Arrays.copyOf(pairs, aux+1); // 包头不包尾
            }else if(p < aux){
                // 答案在其右边
                return qselect(pairs, p+1, r, aux);
            }else {
                return qselect(pairs, l, p-1, aux);
            }
        }
        return new Pair[0];
    }

    private int partition(Pair[] pairs, int l, int r) {
        int i = l;
        int j = r;
        int p = l;
        while (i < j){
            while (pairs[i].count > pairs[p].count && i < j){
                i++;
            }
            while (pairs[j].count <= pairs[p].count && i < j){
                j--;
            }
            swap(pairs, i ,j);
        }
        swap(pairs, p, i);

        return i;
    }

    private void swap(Pair[] pairs, int l, int r){
        Pair t = pairs[l];
        pairs[l] = pairs[r];
        pairs[r] = t;
    }

    class Pair {
        int key;
        int count;

        public Pair(int key, int count) {
            this.key = key;
            this.count = count;
        }
    }

```



# [剑指 Offer 40. 最小的k个数](https://leetcode-cn.com/problems/zui-xiao-de-kge-shu-lcof/)

## 基于快排

```java
class Solution {
    public int[] getLeastNumbers(int[] arr, int k) {
        if (k == 0 || arr.length == 0) {
            return new int[0];
        }
        return QuickSort(arr, 0, arr.length-1, k);
    
    }
    private int[] QuickSort(int[] arr, int low, int high, int k){
        int partition = partition(arr, low, high);
        if(partition == k-1){
            return Arrays.copyOf(arr, partition+1);

        }
        if(partition > k-1){
            return QuickSort(arr, low, partition-1, k);
        }
        else{
            return QuickSort(arr, partition+1, high, k);
        }
        
    }
    private int partition(int[] arr, int low, int high){
        int p = arr[low];
        int i = low;
        while(low < high){
            while(arr[high] > p && low < high) high--;
            while(arr[low] <= p && low < high) low++;
            
            swap(arr, low, high);
            
        }
        arr[i] = arr[low];
        arr[low] = p;
        return low;
    
    }
    private void  swap(int[]arr, int i, int j){
        int t = arr[i];
        arr[i] = arr[j];
        arr[j] = t;
    }
}


```

## 直接排序

```java
class Solution {
    public int[] getLeastNumbers(int[] arr, int k) {
        Arrays.sort(arr);
        int []res = new int[k];
        int i = 0;
        for(int j = 0; j < k; j++){
            res[i++] = arr[j];
        }
        return res;
    }
}
```

## 基于堆

```java
public int[] getLeastNumbers(int[] arr, int k) {
        
        PriorityQueue<Integer> q = new PriorityQueue<>((a,b)->b-a); // 大根堆
        int[] res = new int[k];
        if(k == 0){  //  避免空指针异常
            return res;
        }
        for(int num: arr){
            if(q.size() < k){
                q.offer(num);
            }else{
                if( q.peek() > num){
                    q.poll();
                    q.offer(num);
                }
            }
        }

        int i = 0;
        for(int num: q){
            res[i++] = num;
        }

        return res;
        

    }
```

# 参考

1. https://leetcode-cn.com/problems/top-k-frequent-elements/solution/4-chong-fang-fa-miao-sha-topkji-shu-pai-xu-kuai-pa/

