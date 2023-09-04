package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2023/9/4
 * 给你一个满足下述两条属性的 m x n 整数矩阵：
 * 每行中的整数从左到右按非递减顺序排列。
 * 每行的第一个整数大于前一行的最后一个整数。
 * 给你一个整数 target ，如果 target 在矩阵中，返回 true ；否则，返回 false 。
 * 示例 1：
 * 输入：matrix = [[1,3,5,7],[10,11,16,20],[23,30,34,60]], target = 3
 * 输出：true
 * 示例 2：
 * 输入：matrix = [[1,3,5,7],[10,11,16,20],[23,30,34,60]], target = 13
 * 输出：false
 */
public class LC74_search_a_2d_matrix {

    public boolean searchMatrix(int[][] matrix, int target) {
        int m = matrix.length;
        if (target < matrix[0][0]) {
            return false;
        }

        int left = 0;
        int right = m;
        while (true) {
            int cur = left + (right - left) / 2;

            boolean isCur = false;
            int curVal = matrix[cur][0];
            if (curVal == target) {
                return true;
            }
            if (cur == (matrix.length - 1)) {
                if (target >= curVal) {
                    isCur = true;
                }
            } else {
                int nextVal = matrix[cur + 1][0];
                if (nextVal == target) {
                    return true;
                }
                if (target >= curVal && target < nextVal) {
                    isCur = true;
                }
            }

            if (isCur) {
                return curContains(matrix[cur], target);
            } else {
                if (target < curVal) {
                    right = cur;
                } else {
                    left = cur;
                }
            }
        }
    }

    private boolean curContains(int[] matrix, int target) {
        if (target > matrix[matrix.length - 1]) {
            return false;
        }
        int left = 0;
        int right = matrix.length;
        while (true) {
            int cur = left + (right - left) / 2;
            int curVal = matrix[cur];
            if (curVal == target) {
                return true;
            } else if (target > curVal) {
                left = cur;
            } else {
                right = cur;
            }
            if (left == right || (right == (left + 1) && target < matrix[right] && target > matrix[left])) {
                return false;
            }
        }
    }

    public static void main(String[] args) {
        int[][] ints = { { 1 }, { 3 } };
        boolean b = new LC74_search_a_2d_matrix().searchMatrix(ints, 1);
        int i = 1;
    }

}
