---
title: leetcode-990-等式方程的可满足性
date: 2020-01-28 22:45:18
tags:
	- 并查集
	- dfs
	- 算法
	- 中等
categories:
	- Algorithm
---

## 描述

> 给定一个由表示变量之间关系的字符串方程组成的数组，每个字符串方程 equations[i] 的长度为 4，并采用两种不同的形式之一："a==b" 或 "a!=b"。在这里，a 和 b 是小写字母（不一定不同），表示单字母变量名。只有当可以将整数分配给变量名，以便满足所有给定的方程时才返回 true，否则返回 false。 
>
> 示例 1：
>
> 输入：["a==b","b!=a"]
> 输出：false
> 解释：如果我们指定，a = 1 且 b = 1，那么可以满足第一个方程，但无法满足第二个方程。没有办法分配变量同时满足这两个方程。
> 示例 2：
>
> 输出：["b==a"，     "a==b"]
> 输入：true
> 解释：我们可以指定 a = 1 且 b = 1 以满足满足这两个方程。
> 示例 3：
>
> 输入：["a==b","b==c","a==c"]
> 输出：true
> 示例 4：
>
> 输入：["a==b", "b!=c","c==a"]
> 输出：false
> 示例 5：
>
> 输入：["c==c", "b==d", "x!=z"]
> 输出：true
>
>
> 链接：https://leetcode-cn.com/problems/satisfiability-of-equality-equations
>



## 分析

1. 根据等式的传递性，可以想到使用并查集非常快速可以解决此题。动态连通性其实就是一种等价关系，具有「自反性」「传递性」和「对称性」，其实 `==` 关系也是一种等价关系，具有这些性质。所以这个问题用 Union-Find 算法就很自然。

   **核心思想**是，**将** **`equations`** **中的算式根据** **`==`** **和** **`!=`** **分成两部分，先处理** **`==`** **算式，使得他们通过相等关系各自勾结成门派；然后处理** **`!=`** **算式，检查不等关系是否破坏了相等关系的连通性**。

   ```java
   import java.util.ArrayList;
   import java.util.Stack;
   
   /**
    * @author Hongliang Zhu
    * @create 2020-01-28 21:28
    */
   public class leetcode990_SatisfiabilityOfEqualityEquations {
   
       // 并查集
       public static boolean equationsPossible(String[] equations) {
           UF uf = new UF(26); // 26个字母
           // 所有等式连通
           for (String eq : equations) {
               if (eq.charAt(1) == '=') { // 判断为等式
                   char x = eq.charAt(0);
                   char y = eq.charAt(3);
                   uf.union(x - 'a', y - 'a');
               }
           }
           // 判断不等式会不会破坏连通性
           for (String eq : equations) {
               if (eq.charAt(1) == '!') { // 判断为不等式
                   char x = eq.charAt(0);
                   char y = eq.charAt(3);
                   if (uf.isSameSet(x - 'a', y - 'a')) {
                       return false;
                   }
               }
           }
           return true;
   
       }
   
       public static void main(String[] args) {
           String[] equations1 = {"c==c", "b==d", "x!=z"}; 
           System.out.println(equationsPossible(equations1)); // true
           String[] equations2 = {"a==b", "b==c", "a==c"};
           System.out.println(equationsPossible(equations2)); // true
           String[] equations3 = {"b==a", "a!=b"};
           System.out.println(equationsPossible(equations3)); // fasle
        
       }
   
   
   }
   
   ```

   

2. dfs，图的联通性，染色问题，这是leetcode官方题解：

   ​		思路： 所有相互等于的变量能组成一个联通分量。举一个例子，如果 `a=b, b=c, c=d`，那么 `a, b, c, d` 就在同一个联通分量中，因为它们必须相等。 

​		第一步，我们基于给定的等式，用深度优先遍历将每一个变量按照联通分量染色。

​	将联通分量染色之后，我们分析形如 a != b 的不等式。如果两个分量有相同的颜色，那么它们一定相等，因此	如果说它们不相等的话，就一定无法满足给定的方程组。返回false。



## 代码

```java
import java.util.ArrayList;
import java.util.Stack;

/**
 * @author Hongliang Zhu
 * @create 2020-01-28 21:28
 */

public class leetcode990_SatisfiabilityOfEqualityEquations {
    //连通 染色
    public static boolean equationsPossible_DFS(String[] equations) {
        ArrayList<Integer>[] graph = new ArrayList[26]; // 26个字母
        // 初始化
        for (int i = 0; i < 26; i++) {
            graph[i] = new ArrayList<Integer>();
        }
        // 等式进行连通
        for (String eq : equations) {
            if (eq.charAt(1) == '=') {
                char x = eq.charAt(0);
                char y = eq.charAt(3);
                graph[x - 'a'].add(y - 'a');
                graph[y - 'a'].add(x - 'a');
            }
        }

        int[] color = new int[26]; // 准备26种颜色
        int t = 0;
        for (int i = 0; i < 26; i++) {
            if (color[i] == 0) { // 第i个字母还没染色
                t++; // 增加一种颜色
                Stack<Integer> s = new Stack<Integer>();
                s.push(i);
                while (!s.isEmpty()) {
                    int node = s.pop();
                    for (int nn : graph[node]) {// 取出与node连通的所有点， 即取出等式两边的字母
                        if (color[nn] == 0) {
                            color[nn] = t; // 连通的节点设置成相同的颜色
                            s.push(nn); //  将与之连通的节点进栈，实现等式传递性的功能
                        }
                    }

                }

            }
        }
        // 检查不等式的合法性
        for (String eq : equations) {
            if (eq.charAt(1) == '!') {
                int x = eq.charAt(0) - 'a';
                int y = eq.charAt(3) - 'a';
                if (x == y || color[x] != 0 && color[x] == color[y]) { // 字母相等，颜色相同的一定不满足不等关系
                    return false;
                }
            }
        }
        return true;

    }


    public static void main(String[] args) {
        String[] equations1 = {"c==c", "b==d", "x!=z"};
       
        String[] equations2 = {"a==b", "b==c", "a==c"};
        
        String[] equations3 = {"b==a", "a!=b"};
     
        System.out.println(equationsPossible_DFS(equations1)); // true
        System.out.println(equationsPossible_DFS(equations2)); // true
        System.out.println(equationsPossible_DFS(equations3)); // false

    }


}

```

复杂度分析

时间复杂度： O(N)，其中 N是方程组 equations 的数量。

空间复杂度： O(1），认为字母表的大小是 O(1) 的。

















