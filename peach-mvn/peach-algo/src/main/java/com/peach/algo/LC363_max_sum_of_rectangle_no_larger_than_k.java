package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2023/9/7
 * 给你一个 m x n 的矩阵 matrix 和一个整数 k ，找出并返回矩阵内部矩形区域的不超过 k 的最大数值和。
 * 题目数据保证总会存在一个数值和不超过 k 的矩形区域。
 * 示例 1：
 * 输入：matrix = [[1,0,1],[0,-2,3]], k = 2
 * 输出：2
 * 解释：蓝色边框圈出来的矩形区域 [[0, 1], [-2, 3]] 的数值和是 2，且 2 是不超过 k 的最大数字（k = 2）。
 * 示例 2：
 * 输入：matrix = [[2,2,-1]], k = 3
 * 输出：3
 * m == matrix.length
 * n == matrix[i].length
 * 1 <= m, n <= 100
 * -100 <= matrix[i][j] <= 100
 * -105 <= k <= 105
 */
public class LC363_max_sum_of_rectangle_no_larger_than_k {

    public int maxSumSubmatrix(int[][] matrix, int k) {
        int rows = matrix.length;
        int cols = matrix[0].length;
        int max = Integer.MIN_VALUE;
        for (int i = 1; i <= rows; i++) {
            for (int j = 1; j <= cols; j++) {
                int[][] sum = new int[rows + 1][cols + 1];
                sum[i][j] = matrix[i - 1][j - 1];
                for (int m = i; m <= rows; m++) {
                    for (int n = j; n <= cols; n++) {
                        sum[m][n] = sum[m - 1][n] + sum[m][n - 1] - sum[m - 1][n - 1] + matrix[m - 1][n - 1];
                        if (sum[m][n] <= k && sum[m][n] > max) max = sum[m][n];
                    }
                }
            }
        }
        return max;
    }

    public static void main(String[] args) {
        new LC363_max_sum_of_rectangle_no_larger_than_k()
                .maxSumSubmatrix(new int[][]{ { 5, -4, -3, 4 }, { -3, -4, 4, 5 }, { 5, 1, 5, -4 } }, 10);
    }
}
