package com.peach.algo.LC51_100;

/**
 * @author feitao.zt
 * @date 2024/7/15
 * 给你一个正整数 n ，生成一个包含 1 到 n2 所有元素，且元素按顺时针顺序螺旋排列的 n x n 正方形矩阵 matrix 。
 * 示例 1：
 * 输入：n = 3
 * 输出：[[1,2,3],[8,9,4],[7,6,5]]
 * 示例 2：
 * 输入：n = 1
 * 输出：[[1]]
 * 提示：
 * 1 <= n <= 20
 */
public class LC59_spiral_matrix_ii {

    public int[][] generateMatrix(int n) {
        int[][] result = new int[n][n];

        int cur = 0;
        int val = 1;
        while (cur <= n - 1 - cur) {
            if (cur == n - 1 - cur) {
                result[cur][cur] = val;
                break;
            }
            for (int i = cur; i < n - cur; i++) {
                result[cur][i] = val++;
            }
            for (int i = cur + 1; i < n - cur - 1; i++) {
                result[i][n - 1 - cur] = val++;
            }
            for (int i = n - 1 - cur; i >= cur; i--) {
                result[n - 1 - cur][i] = val++;
            }
            for (int i = n - 2 - cur; i > cur; i--) {
                result[i][cur] = val++;
            }
            cur++;
        }
        return result;
    }

}
