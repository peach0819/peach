package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2023/9/5
 * 给定一个包含非负整数的 m x n 网格 grid ，请找出一条从左上角到右下角的路径，使得路径上的数字总和为最小。
 * 说明：每次只能向下或者向右移动一步。
 * 示例 1：
 * 输入：grid = [[1,3,1],[1,5,1],[4,2,1]]
 * 输出：7
 * 解释：因为路径 1→3→1→1→1 的总和最小。
 * 示例 2：
 * 输入：grid = [[1,2,3],[4,5,6]]
 * 输出：12
 */
public class LC64_minimum_path_sum {

    int[][] map;
    boolean[][] bMap;

    public int minPathSum(int[][] grid) {
        //f(m, n) = min( f(m-1, n) , f(m, n-1) ) + grid[m][n];
        int m = grid.length - 1;
        int n = grid[0].length - 1;
        map = new int[grid.length][grid[0].length];
        bMap = new boolean[grid.length][grid[0].length];
        map[0][0] = grid[0][0];
        bMap[0][0] = true;
        return path(m, n, grid);
    }

    private int path(int m, int n, int[][] grid) {
        boolean b = bMap[m][n];
        int path = map[m][n];
        if (b) {
            return path;
        }
        if (m == 0) {
            path = path(m, n - 1, grid) + grid[m][n];
        } else if (n == 0) {
            path = path(m - 1, n, grid) + grid[m][n];
        } else {
            path = Math.min(path(m - 1, n, grid), path(m, n - 1, grid)) + grid[m][n];
        }
        map[m][n] = path;
        bMap[m][n] = true;
        return path;
    }

    public static void main(String[] args) {
        int i = new LC64_minimum_path_sum().minPathSum(new int[][]{ { 0 } });
        int k = 1;
    }
}
