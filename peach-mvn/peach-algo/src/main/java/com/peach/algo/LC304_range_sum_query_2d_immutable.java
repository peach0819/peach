package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/9/13
 * 给定一个二维矩阵 matrix，以下类型的多个请求：
 * 计算其子矩形范围内元素的总和，该子矩阵的 左上角 为 (row1, col1) ，右下角 为 (row2, col2) 。
 * 实现 NumMatrix 类：
 * NumMatrix(int[][] matrix) 给定整数矩阵 matrix 进行初始化
 * int sumRegion(int row1, int col1, int row2, int col2) 返回 左上角 (row1, col1) 、右下角 (row2, col2) 所描述的子矩阵的元素 总和 。
 * 示例 1：
 * 输入:
 * ["NumMatrix","sumRegion","sumRegion","sumRegion"]
 * [[[[3,0,1,4,2],[5,6,3,2,1],[1,2,0,1,5],[4,1,0,1,7],[1,0,3,0,5]]],[2,1,4,3],[1,1,2,2],[1,2,2,4]]
 * 输出:
 * [null, 8, 11, 12]
 * 解释:
 * NumMatrix numMatrix = new NumMatrix([[3,0,1,4,2],[5,6,3,2,1],[1,2,0,1,5],[4,1,0,1,7],[1,0,3,0,5]]);
 * numMatrix.sumRegion(2, 1, 4, 3); // return 8 (红色矩形框的元素总和)
 * numMatrix.sumRegion(1, 1, 2, 2); // return 11 (绿色矩形框的元素总和)
 * numMatrix.sumRegion(1, 2, 2, 4); // return 12 (蓝色矩形框的元素总和)
 */
public class LC304_range_sum_query_2d_immutable {

    /**
     * Your NumMatrix object will be instantiated and called as such:
     * NumMatrix obj = new NumMatrix(matrix);
     * int param_1 = obj.sumRegion(row1,col1,row2,col2);
     */
    class NumMatrix {

        int[][] result;
        int[][] matrix;

        public NumMatrix(int[][] matrix) {
            this.matrix = matrix;
            result = new int[matrix.length][matrix[0].length];
            result[0][0] = matrix[0][0];
            for (int i = 1; i < matrix.length; i++) {
                result[i][0] = matrix[i][0] + result[i - 1][0];
            }
            for (int i = 1; i < matrix[0].length; i++) {
                result[0][i] = matrix[0][i] + result[0][i - 1];
            }
            for (int i = 1; i < matrix.length; i++) {
                for (int j = 1; j < matrix[0].length; j++) {
                    result[i][j] = matrix[i][j] + result[i - 1][j] + result[i][j - 1] - result[i - 1][j - 1];
                }
            }
        }

        public int sumRegion(int row1, int col1, int row2, int col2) {
            if (row1 == row2 && col1 == col2) {
                return matrix[row2][col2];
            }
            if (row1 == row2) {
                return get(row2, col2) - get(row1, col1 - 1) - get(row2 - 1, col2) + get(row1 - 1, col1 - 1);
            }
            if (col1 == col2) {
                return get(row2, col2) - get(row1 - 1, col1) - get(row2, col2 - 1) + get(row1 - 1, col1 - 1);
            }
            return get(row2, col2) - get(row1 - 1, col2) - get(row2, col1 - 1) + get(row1 - 1, col1 - 1);
        }

        private int get(int i, int j) {
            if (i < 0 || j < 0) {
                return 0;
            }
            return result[i][j];
        }
    }

}
