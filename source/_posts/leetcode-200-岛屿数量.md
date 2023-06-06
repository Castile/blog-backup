---
title: leetcode-200-岛屿数量
date: 2020-02-02 17:50:20
tags:
	- 算法
	- dfs
	- 并查集
	- 中等
	- 搜索
categories:
	- Algorithm
toc: true
---

## 描述

> 给定一个由 '1'（陆地）和 '0'（水）组成的的二维网格，计算岛屿的数量。一个岛被水包围，并且它是通过水平方向或垂直方向上相邻的陆地连接而成的。你可以假设网格的四个边均被水包围。
>
> 示例 1:
>
> 输入:
> 11110
> 11010
> 11000
> 00000
>
> 输出: 1
> 示例 2:
>
> 输入:
> 11000
> 11000
> 00100
> 00011
>
> 输出: 3
> 链接：https://leetcode-cn.com/problems/number-of-islands
>

## 分析

1. dfs： 深度优先搜索，很明显，这是一个连通问题，求出的连通分量的个数就是岛屿的数量
2. 并查集： 这个是并查集的一个应用，求连通分量的个数。
3. bfs： 使用队列解决

这里有一个大佬的题解，非常详细： https://leetcode-cn.com/problems/number-of-islands/solution/dfs-bfs-bing-cha-ji-python-dai-ma-java-dai-ma-by-l/ 

官方题解也可。主要是理解算法思想

直接看代码吧

## 代码

并查集：

```java
class Solution {
    int count = 0;
    public int numIslands(char[][] grid) {
        if(grid == null || grid.length == 0)    return 0;
        int m = grid.length;
        int n = grid[0].length;
        int[] parents = new int[n*m];
        int[] rank = new int [n*m];
        makeSet(grid, parents, rank);
        // 方向数组 d 是上下左右搜索的常用手法
        int[][] d = new int[][]{{1,0}, {0,1}, {0,-1}, {-1,0}};
        for(int i =0 ; i < m; i++){
            for( int j = 0; j < n; j++){
               if( grid[i][j] == '1'){
                   grid[i][j] = '0';  //  已经联合的点不需要连接了。
                   for(int k = 0; k < 4; k++){
                       int x = i + d[k][0];
                       int y = j + d[k][1];
                       if(x >= 0 && x < m && y >= 0 && y < n && grid[x][y] == '1'){
                           unoin(parents, rank, x *n +y,  i *n + j);
                       }
                   }
               }
            }
        }
        
        return count;
        
    }
    
    // 构建并查集的结构：注意这里的技巧
    public void makeSet(char[][] grid, int []parents, int []rank){
        for(int i = 0; i < grid.length ; i++){
            for(int j = 0; j < grid[0].length; j++){
                if(grid[i][j] == '1'){
                    parents[i * grid[0].length + j] = i * grid[0].length + j;
                    rank[i * grid[0].length + j] = 1;
                    count++;  // 连通分量 
                }else{
                    parents[i * grid[0].length + j] = -1;
                    rank[i * grid[0].length + j] = 0;
                }
                    
            }
           
        }    
          
    }
    public int find(int[] parents, int a){
        int root = parents[a];
        while(root != parents[root]){
           root = parents[root];
        }
        return root;
    }
    
    public void unoin(int[] parents, int []rank, int a, int b){
        int ra  = find(parents, a);
        int rb  = find(parents, b);
        if(ra != rb){
            if(rank[ra] > rank[rb]){
                parents[rb] =  ra;
                rank[ra] += rank[rb];
            }else{
                 parents[rb] =  ra;
                rank[ra] += rank[rb];
            }
            count--;
        }else
        {
            return;
        }
    }
}
```

dfs：

```java
class Solution {
    public int numIslands(char[][] grid) {
      
        int cnt = 0;
        for(int i = 0; i < grid.length; i++){
            for(int j = 0; j < grid[0].length; j++){
                if(grid[i][j] == '1'){
                    cnt++; // 岛屿的个数加一
                    infect(grid, i, j, grid.length, grid[0].length); // 感染函数
                }
            }
        }


    return cnt;
    }
    /**
     * 感染函数： 将i， j位置的上下左右位置进行检查，是否为同一个岛屿
     * @param m： 岛屿矩阵
     * @param i： 下标
     * @param j：  下标
     * @param R: 行
     * @param C： 列
     */
    public  static void infect(char[][] m, int i, int j, int R, int C){
        if(i < 0 || i >= R || j < 0 || j >= C || m[i][j] != '1')
            return;
        m[i][j] = '2';
        // 依次感染上下左右位置
        infect(m, i+1, j, R, C);
        infect(m, i-1, j, R, C);
        infect(m, i, j-1, R, C);
        infect(m, i, j+1, R, C);

    }
}
```

BFS： 使用队列

```java
class Solution {
    int m,n;
    int[][] d = new int[][]{{0,1},{1,0},{-1,0}, {0,-1}};
    // 广度优先遍历
    public int numIslands(char[][] grid) {
        if(grid == null ||  grid.length == 0)    return 0;
        m = grid.length;
        n = grid[0].length;
        LinkedList<Integer> q = new LinkedList<>();
        int count = 0;
        for(int i = 0; i < m; i++){
            for(int j = 0; j < n ; j ++){
                if(grid[i][j] == '1'){
                    q.offer(i * n + j); //  入队
                    while(!q.isEmpty()){
                    int cur = q.poll(); // 出队
                    int cx = cur / n;
                    int cy = cur % n;
                    grid[cx][cy] = '0';
                    for(int[] dd: d){
                        int x = cx + dd[0];
                        int y = cy + dd[1];
                        if(x >= 0 && y >= 0 && x < m && y < n && grid[x][y] == '1'){
                            q.offer(x * n + y);
                            grid[x][y] = '0';   // 要标志已访问，不然会严重超时
                        }
                            
                    }

                    }
                    count++;
                    
                }
            }
        }
        return count;

    }

}
```

