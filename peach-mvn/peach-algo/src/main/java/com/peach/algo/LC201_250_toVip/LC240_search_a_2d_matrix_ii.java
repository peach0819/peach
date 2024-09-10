package com.peach.algo.LC201_250_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/10
 * 编写一个高效的算法来搜索 m x n 矩阵 matrix 中的一个目标值 target 。该矩阵具有以下特性：
 * 每行的元素从左到右升序排列。
 * 每列的元素从上到下升序排列。
 * 示例 1：
 * 输入：matrix = [[1,4,7,11,15],[2,5,8,12,19],[3,6,9,16,22],[10,13,14,17,24],[18,21,23,26,30]], target = 5
 * 输出：true
 * 示例 2：
 * 输入：matrix = [[1,4,7,11,15],[2,5,8,12,19],[3,6,9,16,22],[10,13,14,17,24],[18,21,23,26,30]], target = 20
 * 输出：false
 * 提示：
 * m == matrix.length
 * n == matrix[i].length
 * 1 <= n, m <= 300
 * -109 <= matrix[i][j] <= 109
 * 每行的所有元素从左到右升序排列
 * 每列的所有元素从上到下升序排列
 * -109 <= target <= 109
 */
public class LC240_search_a_2d_matrix_ii {

    int[][] matrix;
    int target;

    public boolean searchMatrix(int[][] matrix, int target) {
        this.matrix = matrix;
        this.target = target;
        return handle(0, 0);
    }

    private boolean handle(int i, int j) {
        if (i >= matrix.length || j >= matrix[0].length) {
            return false;
        }
        int cur = this.matrix[i][j];
        if (cur == target) {
            return true;
        }
        if (cur > target) {
            return false;
        }
        boolean b = handle(i + 1, j) || handle(i, j + 1);
        if (!b) {
            matrix[i][j] = target + 1;
        }
        return b;
    }

}
