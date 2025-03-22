package com.peach.algo.LC451_500_toVip;

/**
 * @author feitao.zt
 * @date 2025/2/11
 * 给你一个大小为 m x n 的矩阵 mat ，请以对角线遍历的顺序，用一个数组返回这个矩阵中的所有元素。
 * 示例 1：
 * 输入：mat = [[1,2,3],[4,5,6],[7,8,9]]
 * 输出：[1,2,4,7,5,3,6,8,9]
 * 示例 2：
 * 输入：mat = [[1,2],[3,4]]
 * 输出：[1,2,3,4]
 * 提示：
 * m == mat.length
 * n == mat[i].length
 * 1 <= m, n <= 104
 * 1 <= m * n <= 104
 * -105 <= mat[i][j] <= 105
 */
public class LC498_diagonal_traverse {

    public static void main(String[] args) {
        int[] ints = new LC498_diagonal_traverse().findDiagonalOrder(
                new int[][]{ { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 } });
        int i = 1;
    }

    public int[] findDiagonalOrder(int[][] mat) {
        int m = mat.length;
        int n = mat[0].length;
        int[] result = new int[m * n];

        int index = 0;
        for (int i = 0; i <= m + n - 2; i++) {
            if (i % 2 == 0) {
                for (int j = Math.max(0, i + 1 - m); j <= Math.min(i, n - 1); j++) {
                    result[index] = mat[i - j][j];
                    index++;
                }
            } else {
                for (int j = Math.max(0, i - n + 1); j <= Math.min(i, m - 1); j++) {
                    result[index] = mat[j][i - j];
                    index++;
                }
            }
        }
        return result;
    }
}
