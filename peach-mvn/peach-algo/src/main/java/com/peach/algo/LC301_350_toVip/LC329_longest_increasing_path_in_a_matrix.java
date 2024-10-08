package com.peach.algo.LC301_350_toVip;

import java.util.HashSet;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/9/25
 * 给定一个 m x n 整数矩阵 matrix ，找出其中 最长递增路径 的长度。
 * 对于每个单元格，你可以往上，下，左，右四个方向移动。 你 不能 在 对角线 方向上移动或移动到 边界外（即不允许环绕）。
 * 示例 1：
 * 输入：matrix = [[9,9,4],[6,6,8],[2,1,1]]
 * 输出：4
 * 解释：最长递增路径为 [1, 2, 6, 9]。
 * 示例 2：
 * 输入：matrix = [[3,4,5],[3,2,6],[2,2,1]]
 * 输出：4
 * 解释：最长递增路径是 [3, 4, 5, 6]。注意不允许在对角线方向上移动。
 * 示例 3：
 * 输入：matrix = [[1]]
 * 输出：1
 * 提示：
 * m == matrix.length
 * n == matrix[i].length
 * 1 <= m, n <= 200
 * 0 <= matrix[i][j] <= 231 - 1
 */
public class LC329_longest_increasing_path_in_a_matrix {

    public static void main(String[] args) {
        int i = new LC329_longest_increasing_path_in_a_matrix()
                .longestIncreasingPath(new int[][]{ { 3, 4, 5 }, { 3, 2, 6 }, { 2, 2, 1 } });
        i = 1;
    }

    int[][] matrix;

    boolean[][] has;

    public int longestIncreasingPath(int[][] matrix) {
        this.matrix = matrix;
        Set<int[]> set = new HashSet<>();
        has = new boolean[matrix.length][matrix[0].length];
        int index = 1;
        for (int i = 0; i < matrix.length; i++) {
            for (int j = 0; j < matrix[i].length; j++) {
                if (isMin(i, j)) {
                    set.add(new int[]{ i, j });
                    has[i][j] = true;
                }
            }
        }
        Set<int[]> temp;
        while (!set.isEmpty()) {
            temp = new HashSet<>();
            for (int[] point : set) {
                int i = point[0];
                int j = point[1];
                int val = matrix[i][j];
                isLarger(temp, i - 1, j, val);
                isLarger(temp, i + 1, j, val);
                isLarger(temp, i, j - 1, val);
                isLarger(temp, i, j + 1, val);
            }
            if (temp.isEmpty()) {
                break;
            } else {
                set = temp;
                index++;
                has = new boolean[matrix.length][matrix[0].length];
            }
        }

        return index;
    }

    private void isLarger(Set<int[]> temp, int i, int j, int val) {
        if (i < 0 || i >= matrix.length || j < 0 || j >= matrix[0].length || has[i][j]) {
            return;
        }
        int cur = matrix[i][j];
        if (cur > val) {
            temp.add(new int[]{ i, j });
            has[i][j] = true;
        }
    }

    private boolean isMin(int i, int j) {
        int cur = matrix[i][j];
        return cur <= get(i - 1, j)
                && cur <= get(i + 1, j)
                && cur <= get(i, j - 1)
                && cur <= get(i, j + 1);
    }

    private int get(int i, int j) {
        if (i < 0 || i >= matrix.length || j < 0 || j >= matrix[0].length) {
            return Integer.MAX_VALUE;
        }
        return matrix[i][j];
    }
}
