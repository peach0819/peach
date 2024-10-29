package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/10/29
 * 有一个 m × n 的矩形岛屿，与 太平洋 和 大西洋 相邻。 “太平洋” 处于大陆的左边界和上边界，而 “大西洋” 处于大陆的右边界和下边界。
 * 这个岛被分割成一个由若干方形单元格组成的网格。给定一个 m x n 的整数矩阵 heights ， heights[r][c] 表示坐标 (r, c) 上单元格 高于海平面的高度 。
 * 岛上雨水较多，如果相邻单元格的高度 小于或等于 当前单元格的高度，雨水可以直接向北、南、东、西流向相邻单元格。水可以从海洋附近的任何单元格流入海洋。
 * 返回网格坐标 result 的 2D 列表 ，其中 result[i] = [ri, ci] 表示雨水从单元格 (ri, ci) 流动 既可流向太平洋也可流向大西洋 。
 * 示例 1：
 * 输入: heights = [[1,2,2,3,5],[3,2,3,4,4],[2,4,5,3,1],[6,7,1,4,5],[5,1,1,2,4]]
 * 输出: [[0,4],[1,3],[1,4],[2,2],[3,0],[3,1],[4,0]]
 * 示例 2：
 * 输入: heights = [[2,1],[1,2]]
 * 输出: [[0,0],[0,1],[1,0],[1,1]]
 * 提示：
 * m == heights.length
 * n == heights[r].length
 * 1 <= m, n <= 200
 * 0 <= heights[r][c] <= 105
 */
public class LC417_pacific_atlantic_water_flow {

    public static void main(String[] args) {
        new LC417_pacific_atlantic_water_flow().pacificAtlantic(
                new int[][]{ { 1, 2, 2, 3, 5 }, { 3, 2, 3, 4, 4 }, { 2, 4, 5, 3, 1 }, { 6, 7, 1, 4, 5 },
                        { 5, 1, 1, 2, 4 } });
    }

    boolean[][][] can;
    int[][] heights;
    int[][] temp = new int[][]{ { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } };

    public List<List<Integer>> pacificAtlantic(int[][] heights) {
        //0表示太平洋  1表示大西洋
        this.heights = heights;
        this.can = new boolean[heights.length][heights[0].length][2];

        //初始化
        for (int i = 0; i < heights.length; i++) {
            handle(i, 0, 0);
            handle(i, heights[0].length - 1, 1);
        }
        for (int i = 0; i < heights[0].length; i++) {
            handle(0, i, 0);
            handle(heights.length - 1, i, 1);
        }

        List<List<Integer>> result = new ArrayList<>();
        for (int i = 0; i < heights.length; i++) {
            for (int j = 0; j < heights[0].length; j++) {
                if (can[i][j][0] && can[i][j][1]) {
                    List<Integer> list = new ArrayList<>();
                    list.add(i);
                    list.add(j);
                    result.add(list);
                }
            }
        }
        return result;
    }

    //传染
    private void handle(int i, int j, int type) {
        if (can[i][j][type]) {
            return;
        }
        can[i][j][type] = true;
        int height = heights[i][j];

        for (int[] interval : temp) {
            int i1 = i + interval[0];
            int j1 = j + interval[1];
            if (i1 < 0 || i1 > heights.length - 1 || j1 < 0 || j1 > heights[0].length - 1) {
                continue;
            }
            if (height <= heights[i1][j1]) {
                handle(i1, j1, type);
            }
        }
    }
}
