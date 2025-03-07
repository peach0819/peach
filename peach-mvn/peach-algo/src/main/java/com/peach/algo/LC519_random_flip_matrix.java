package com.peach.algo;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * @author feitao.zt
 * @date 2025/3/6
 * 给你一个 m x n 的二元矩阵 matrix ，且所有值被初始化为 0 。请你设计一个算法，随机选取一个满足 matrix[i][j] == 0 的下标 (i, j) ，并将它的值变为 1 。所有满足 matrix[i][j] == 0 的下标 (i, j) 被选取的概率应当均等。
 * 尽量最少调用内置的随机函数，并且优化时间和空间复杂度。
 * 实现 Solution 类：
 * Solution(int m, int n) 使用二元矩阵的大小 m 和 n 初始化该对象
 * int[] flip() 返回一个满足 matrix[i][j] == 0 的随机下标 [i, j] ，并将其对应格子中的值变为 1
 * void reset() 将矩阵中所有的值重置为 0
 * 示例：
 * 输入
 * ["Solution", "flip", "flip", "flip", "reset", "flip"]
 * [[3, 1], [], [], [], [], []]
 * 输出
 * [null, [1, 0], [2, 0], [0, 0], null, [2, 0]]
 * 解释
 * Solution solution = new Solution(3, 1);
 * solution.flip();  // 返回 [1, 0]，此时返回 [0,0]、[1,0] 和 [2,0] 的概率应当相同
 * solution.flip();  // 返回 [2, 0]，因为 [1,0] 已经返回过了，此时返回 [2,0] 和 [0,0] 的概率应当相同
 * solution.flip();  // 返回 [0, 0]，根据前面已经返回过的下标，此时只能返回 [0,0]
 * solution.reset(); // 所有值都重置为 0 ，并可以再次选择下标返回
 * solution.flip();  // 返回 [2, 0]，此时返回 [0,0]、[1,0] 和 [2,0] 的概率应当相同
 * 提示：
 * 1 <= m, n <= 104
 * 每次调用flip 时，矩阵中至少存在一个值为 0 的格子。
 * 最多调用 1000 次 flip 和 reset 方法。
 */
public class LC519_random_flip_matrix {

    public static void main(String[] args) {
        Solution solution = new LC519_random_flip_matrix().new Solution(2, 2);
        int[] flip = solution.flip();
        System.out.println(Arrays.toString(flip));
        flip = solution.flip();
        System.out.println(Arrays.toString(flip));
        flip = solution.flip();
        System.out.println(Arrays.toString(flip));
        flip = solution.flip();
        System.out.println(Arrays.toString(flip));
        int i = 1;
    }

    /**
     * Your Solution object will be instantiated and called as such:
     * Solution obj = new Solution(m, n);
     * int[] param_1 = obj.flip();
     * obj.reset();
     */
    /**
     * 思路是通过把最后一位代替回去，这样每次替换的概率都是相等的
     */
    class Solution {

        Random random = new Random();
        int m;
        int n;
        int total;
        Map<Integer, Integer> map;

        public Solution(int m, int n) {
            this.m = m;
            this.n = n;
            reset();
        }

        public int[] flip() {
            int index = random.nextInt(total);
            int cur = index;
            if (map.containsKey(cur)) {
                cur = map.get(cur);
            }
            if (index != total - 1) {
                map.put(index, map.getOrDefault(total - 1, total - 1));
            }
            total--;
            return new int[]{ cur / n, cur % n };
        }

        public void reset() {
            total = m * n;
            map = new HashMap<>();
        }
    }

}
