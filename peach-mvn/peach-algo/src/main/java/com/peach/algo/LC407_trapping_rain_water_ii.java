package com.peach.algo;

import java.util.Comparator;
import java.util.PriorityQueue;

/**
 * @author feitao.zt
 * @date 2024/10/24
 * 给你一个 m x n 的矩阵，其中的值均为非负整数，代表二维高度图每个单元的高度，请计算图中形状最多能接多少体积的雨水。
 * 示例 1:
 * 输入: heightMap = [[1,4,3,1,3,2],[3,2,1,3,2,4],[2,3,3,2,3,1]]
 * 输出: 4
 * 解释: 下雨后，雨水将会被上图蓝色的方块中。总的接雨水量为1+2+1=4。
 * 示例 2:
 * 输入: heightMap = [[3,3,3,3,3],[3,2,2,2,3],[3,2,1,2,3],[3,2,2,2,3],[3,3,3,3,3]]
 * 输出: 10
 * 提示:
 * m == heightMap.length
 * n == heightMap[i].length
 * 1 <= m, n <= 200
 * 0 <= heightMap[i][j] <= 2 * 104
 */
public class LC407_trapping_rain_water_ii {

    /**
     * 我是傻逼
     */
    public int trapRainWater(int[][] heightMap) {
        if (heightMap.length <= 2 || heightMap[0].length <= 2) {
            return 0;
        }
        int m = heightMap.length;
        int n = heightMap[0].length;
        boolean[][] visit = new boolean[m][n];
        PriorityQueue<int[]> pq = new PriorityQueue<>(Comparator.comparingInt(o -> o[1]));

        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                if (i == 0 || i == m - 1 || j == 0 || j == n - 1) {
                    pq.offer(new int[]{ i * n + j, heightMap[i][j] });
                    visit[i][j] = true;
                }
            }
        }
        int res = 0;
        int[] dirs = { -1, 0, 1, 0, -1 };
        while (!pq.isEmpty()) {
            int[] curr = pq.poll();
            for (int k = 0; k < 4; ++k) {
                int nx = curr[0] / n + dirs[k];
                int ny = curr[0] % n + dirs[k + 1];
                if (nx >= 0 && nx < m && ny >= 0 && ny < n && !visit[nx][ny]) {
                    if (curr[1] > heightMap[nx][ny]) {
                        res += curr[1] - heightMap[nx][ny];
                    }
                    pq.offer(new int[]{ nx * n + ny, Math.max(heightMap[nx][ny], curr[1]) });
                    visit[nx][ny] = true;
                }
            }
        }
        return res;
    }

    //
    //int[][] minHeight;
    //int[][] heightMap;
    //
    //boolean[][] visit;
    //
    //int[][] test = new int[][]{ { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } };
    //
    //public int trapRainWater(int[][] heightMap) {
    //    this.heightMap = heightMap;
    //    this.minHeight = new int[heightMap.length][heightMap[0].length];
    //    this.visit = new boolean[heightMap.length][heightMap[0].length];
    //    for (int[] ints : minHeight) {
    //        Arrays.fill(ints, -1);
    //    }
    //    for (int i = 0; i < heightMap.length; i++) {
    //        if (i != 0 && i != heightMap.length - 1) {
    //            continue;
    //        }
    //        for (int j = 0; j < heightMap[i].length; j++) {
    //            if (j != 0 && j != heightMap[i].length - 1) {
    //                continue;
    //            }
    //            minHeight[i][j] = heightMap[i][j];
    //            visit[i][j] = true;
    //        }
    //    }
    //    for (int i = 1; i < heightMap.length - 1; i++) {
    //        for (int j = 1; j < heightMap[i].length - 1; j++) {
    //            int maxHeight = heightMap[i][j];
    //
    //        }
    //    }
    //
    //}
    //
    //private int getMinHeight(int m, int n) {
    //    if (minHeight[m][n] >= 0) {
    //        return minHeight[m][n];
    //    }
    //    if (m == 0 || m == minHeight.length - 1 || n == 0 || n == minHeight[0].length - 1) {
    //        minHeight[m][n] = 0;
    //        return 0;
    //    }
    //    int cur = heightMap[m][n];
    //
    //    int minHeight = 0;
    //    for (int[] ints : test) {
    //        int next = heightMap[m + ints[0]][n + ints[1]];
    //        if (cur < next)
    //    }
    //    int h1 = ;
    //    int h2;
    //    int h3;
    //    int h4;
    //}
}
