package com.peach.algo.LC551_600_toVip;

/**
 * @author feitao.zt
 * @date 2025/7/16
 * 给你一个大小为 m x n 的网格和一个球。球的起始坐标为 [startRow, startColumn] 。你可以将球移到在四个方向上相邻的单元格内（可以穿过网格边界到达网格之外）。你 最多 可以移动 maxMove 次球。
 * 给你五个整数 m、n、maxMove、startRow 以及 startColumn ，找出并返回可以将球移出边界的路径数量。因为答案可能非常大，返回对 109 + 7 取余 后的结果。
 * 示例 1：
 * 输入：m = 2, n = 2, maxMove = 2, startRow = 0, startColumn = 0
 * 输出：6
 * 示例 2：
 * 输入：m = 1, n = 3, maxMove = 3, startRow = 0, startColumn = 1
 * 输出：12
 * 提示：
 * 1 <= m, n <= 50
 * 0 <= maxMove <= 50
 * 0 <= startRow < m
 * 0 <= startColumn < n
 */
public class LC576_out_of_boundary_paths {

    public static void main(String[] args) {
        new LC576_out_of_boundary_paths().findPaths1(2, 2, 2, 0, 0);
    }

    long[][][] dp;
    int m;
    int n;
    int maxMove;

    int[][] dirs = new int[][]{ { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } };

    public int findPaths(int m, int n, int maxMove, int startRow, int startColumn) {
        this.dp = new long[m][n][maxMove + 1];
        this.m = m;
        this.n = n;
        this.maxMove = maxMove;
        dp[startRow][startColumn][0] = 1;
        long result = 0;
        for (int k = 0; k < maxMove; k++) {
            for (int i = 0; i < m; i++) {
                for (int j = 0; j < n; j++) {
                    for (int[] dir : dirs) {
                        int i1 = i + dir[0];
                        int j1 = j + dir[1];
                        if (i1 < 0 || i1 >= m || j1 < 0 || j1 >= n) {
                            result = (result + dp[i][j][k]) % 1000000007;
                        } else {
                            dp[i1][j1][k + 1] = (dp[i][j][k] + dp[i1][j1][k + 1]) % 1000000007;
                        }
                    }
                }
            }
        }
        return (int) (result % 1000000007);
    }

    public int findPaths1(int m, int n, int maxMove, int startRow, int startColumn) {
        this.dp = new long[m][n][maxMove + 1];
        this.m = m;
        this.n = n;
        this.maxMove = maxMove;
        handle(startRow, startColumn, 0);

        long result = 0;
        for (int k = 0; k < maxMove; k++) {
            for (int i = 0; i < m; i++) {
                result += dp[i][0][k];
                result += dp[i][n - 1][k];
            }
            for (int i = 0; i < n; i++) {
                result += dp[0][i][k];
                result += dp[m - 1][i][k];
            }
        }
        return (int) (result % 1000000007);
    }

    private void handle(int i, int j, int curMove) {
        if (i < 0 || i >= m || j < 0 || j >= n || curMove >= maxMove || !can(i, j, curMove)) {
            return;
        }
        dp[i][j][curMove]++;
        handle(i - 1, j, curMove + 1);
        handle(i + 1, j, curMove + 1);
        handle(i, j - 1, curMove + 1);
        handle(i, j + 1, curMove + 1);
    }

    private boolean can(int i, int j, int curMove) {
        int lastMove = maxMove - curMove;
        return i < lastMove || m - 1 - i <= lastMove || j < lastMove || n - 1 - j < lastMove;
    }

}
