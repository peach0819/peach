package com.peach.algo;

import java.util.Queue;
import java.util.concurrent.LinkedBlockingQueue;

/**
 * @author feitao.zt
 * @date 2026/1/21
 * 在一个 n x n 的国际象棋棋盘上，一个骑士从单元格 (row, column) 开始，并尝试进行 k 次移动。行和列是 从 0 开始 的，所以左上单元格是 (0,0) ，右下单元格是 (n - 1, n - 1) 。
 * 象棋骑士有8种可能的走法，如下图所示。每次移动在基本方向上是两个单元格，然后在正交方向上是一个单元格。
 * 每次骑士要移动时，它都会随机从8种可能的移动中选择一种(即使棋子会离开棋盘)，然后移动到那里。
 * 骑士继续移动，直到它走了 k 步或离开了棋盘。
 * 返回 骑士在棋盘停止移动后仍留在棋盘上的概率 。
 * 示例 1：
 * 输入: n = 3, k = 2, row = 0, column = 0
 * 输出: 0.0625
 * 解释: 有两步(到(1,2)，(2,1))可以让骑士留在棋盘上。
 * 在每一个位置上，也有两种移动可以让骑士留在棋盘上。
 * 骑士留在棋盘上的总概率是0.0625。
 * 示例 2：
 * 输入: n = 1, k = 0, row = 0, column = 0
 * 输出: 1.00000
 * 提示:
 * 1 <= n <= 25
 * 0 <= k <= 100
 * 0 <= row, column <= n - 1
 */
public class LC688_knight_probability_in_chessboard {

    public static int[][] indexList =
            { { -1, -2 }, { -2, -1 }, { -2, 1 }, { -1, 2 }, { 1, 2 }, { 2, 1 }, { 2, -1 }, { 1, -2 } };

    public double knightProbability(int n, int k, int row, int column) {
        if (k == 0) {
            return 1d;
        }
        double[][][] dp = new double[k + 1][n][n];
        dp[0][row][column] = 1d;
        Queue<int[]> queue = new LinkedBlockingQueue<>();
        queue.add(new int[]{ row, column });

        int begin = 0;
        while (begin < k) {
            begin++;
            Queue<int[]> newQueue = new LinkedBlockingQueue<>();
            for (int[] cur : queue) {
                for (int[] index : indexList) {
                    int x = cur[0] + index[0];
                    int y = cur[1] + index[1];
                    if (x < 0 || x >= n || y < 0 || y >= n) {
                        continue;
                    }
                    if (dp[begin][x][y] == 0) {
                        newQueue.add(new int[]{ x, y });
                    }
                    dp[begin][x][y] += dp[begin - 1][cur[0]][cur[1]] / 8;
                }
            }
            queue = newQueue;
            if (queue.isEmpty()) {
                return 0d;
            }
        }
        double result = 0d;
        for (int[] cur : queue) {
            result += dp[k][cur[0]][cur[1]];
        }
        return result;
    }
}
