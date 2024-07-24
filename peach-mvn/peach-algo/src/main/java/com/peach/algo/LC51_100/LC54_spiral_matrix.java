package com.peach.algo.LC51_100;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/12
 * 给你一个 m 行 n 列的矩阵 matrix ，请按照 顺时针螺旋顺序 ，返回矩阵中的所有元素。
 * 示例 1：
 * 输入：matrix = [[1,2,3],[4,5,6],[7,8,9]]
 * 输出：[1,2,3,6,9,8,7,4,5]
 * 示例 2：
 * 输入：matrix = [[1,2,3,4],[5,6,7,8],[9,10,11,12]]
 * 输出：[1,2,3,4,8,12,11,10,9,5,6,7]
 * 提示：
 * m == matrix.length
 * n == matrix[i].length
 * 1 <= m, n <= 10
 * -100 <= matrix[i][j] <= 100
 */
public class LC54_spiral_matrix {

    public static void main(String[] args) {
        new LC54_spiral_matrix().spiralOrder(new int[][]{ { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 } });
    }

    public List<Integer> spiralOrder(int[][] matrix) {
        List<Integer> result = new ArrayList<>();
        int m = matrix[0].length;
        int n = matrix.length;
        int total = m * n;

        int circle = 0;
        while (true) {
            for (int i = circle; i <= m - 1 - circle; i++) {
                result.add(matrix[circle][i]);
            }
            for (int i = circle + 1; i < n - 1 - circle; i++) {
                result.add(matrix[i][m - 1 - circle]);
            }
            if (n - 1 - circle > circle) {
                for (int i = m - 1 - circle; i >= circle; i--) {
                    result.add(matrix[n - 1 - circle][i]);
                }
            }
            if (m - 1 - circle > circle) {
                for (int i = n - 2 - circle; i > circle; i--) {
                    result.add(matrix[i][circle]);
                }
            }
            if (result.size() == total) {
                break;
            } else {
                circle++;
            }
        }
        return result;
    }
}
