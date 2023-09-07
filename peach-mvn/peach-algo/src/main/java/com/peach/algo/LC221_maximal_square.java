package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2023/9/7
 * 在一个由 '0' 和 '1' 组成的二维矩阵内，找到只包含 '1' 的最大正方形，并返回其面积。
 * 示例 1：
 * 输入：matrix = [["1","0","1","0","0"],["1","0","1","1","1"],["1","1","1","1","1"],["1","0","0","1","0"]]
 * 输出：4
 * 示例 2：
 * 输入：matrix = [["0","1"],["1","0"]]
 * 输出：1
 * 示例 3：
 * 输入：matrix = [["0"]]
 * 输出：0
 * 提示：
 * m == matrix.length
 * n == matrix[i].length
 * 1 <= m, n <= 300
 * matrix[i][j] 为 '0' 或 '1'
 */
public class LC221_maximal_square {

    int[][] result;
    int max = 0;

    public int maximalSquare(char[][] matrix) {
        int m = matrix.length;
        int n = matrix[0].length;
        result = new int[m][n];

        for (int i = 0; i < m; i++) {
            for (int j = 0; j < n; j++) {
                get(i, j, matrix);
            }
        }
        return max * max;
    }

    private int get(int x, int y, char[][] matrix) {
        int cur;
        char val = matrix[x][y];
        if (val == '0') {
            cur = 0;
        } else if (x == 0 || y == 0) {
            cur = 1;
        } else if (matrix[x - 1][y] == '0' || matrix[x][y - 1] == '0' || matrix[x - 1][y - 1] == '0') {
            cur = 1;
        } else {
            cur = Math.min(Math.min(result[x - 1][y - 1], result[x - 1][y]), result[x][y - 1]) + 1;
        }
        result[x][y] = cur;
        max = Math.max(max, cur);
        return cur;
    }

    public static void main(String[] args) {
        new LC221_maximal_square().maximalSquare(
                new char[][]{ { '1', '0', '1', '0', '0' }, { '1', '0', '1', '1', '1' }, { '1', '1', '1', '1', '1' },
                        { '1', '0', '0', '1', '0' } });
    }
}
