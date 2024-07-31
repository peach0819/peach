package com.peach.algo.LC51_100;

/**
 * @author feitao.zt
 * @date 2024/7/16
 * 一个机器人位于一个 m x n 网格的左上角 （起始点在下图中标记为 “Start” ）。
 * 机器人每次只能向下或者向右移动一步。机器人试图达到网格的右下角（在下图中标记为 “Finish” ）。
 * 问总共有多少条不同的路径？
 * 示例 1：
 * 输入：m = 3, n = 7
 * 输出：28
 * 示例 2：
 * 输入：m = 3, n = 2
 * 输出：3
 * 解释：
 * 从左上角开始，总共有 3 条路径可以到达右下角。
 * 1. 向右 -> 向下 -> 向下
 * 2. 向下 -> 向下 -> 向右
 * 3. 向下 -> 向右 -> 向下
 * 示例 3：
 * 输入：m = 7, n = 3
 * 输出：28
 * 示例 4：
 * 输入：m = 3, n = 3
 * 输出：6
 * 提示：
 * 1 <= m, n <= 100
 * 题目数据保证答案小于等于 2 * 109
 */
public class LC62_unique_paths {

    public static void main(String[] args) {
        int i = new LC62_unique_paths().uniquePaths(3, 7);
        int j = 1;
    }

    public int uniquePaths(int m, int n) {
        int[][] result = new int[m][n];
        for (int i = 0; i < m; i++) {
            for (int j = 0; j < n; j++) {
                if (i == 0 || j == 0) {
                    result[i][j] = 1;
                } else {
                    result[i][j] = result[i - 1][j] + result[i][j - 1];
                }
            }
        }
        return result[m - 1][n - 1];
    }
}
