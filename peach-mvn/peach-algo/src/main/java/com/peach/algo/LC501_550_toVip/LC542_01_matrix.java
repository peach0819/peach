package com.peach.algo.LC501_550_toVip;

import java.util.LinkedList;
import java.util.Queue;

/**
 * @author feitao.zt
 * @date 2025/5/6
 * 给定一个由 0 和 1 组成的矩阵 mat ，请输出一个大小相同的矩阵，其中每一个格子是 mat 中对应位置元素到最近的 0 的距离。
 * 两个相邻元素间的距离为 1 。
 * 示例 1：
 * 输入：mat = [[0,0,0],[0,1,0],[0,0,0]]
 * 输出：[[0,0,0],[0,1,0],[0,0,0]]
 * 示例 2：
 * 输入：mat = [[0,0,0],[0,1,0],[1,1,1]]
 * 输出：[[0,0,0],[0,1,0],[1,2,1]]
 * 提示：
 * m == mat.length
 * n == mat[i].length
 * 1 <= m, n <= 104
 * 1 <= m * n <= 104
 * mat[i][j] is either 0 or 1.
 * mat 中至少有一个 0
 */
public class LC542_01_matrix {

    boolean[][] visit;

    int[][] mat;

    int[][] arrays = new int[][]{ { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } };

    int[][] result;

    /**
     * 这道题的本质就是多起点的BFS，从一个个起点开始，后面遍历的一层就继续入队，作为下一层的起点
     */
    public int[][] updateMatrix(int[][] mat) {
        this.mat = mat;
        this.visit = new boolean[mat.length][mat[0].length];
        this.result = new int[mat.length][mat[0].length];
        Queue<int[]> queue = new LinkedList<>();
        for (int i = 0; i < mat.length; i++) {
            for (int j = 0; j < mat[0].length; j++) {
                if (mat[i][j] == 0) {
                    visit[i][j] = true;
                    queue.add(new int[]{ i, j });
                }
            }
        }
        while (!queue.isEmpty()) {
            int[] cur = queue.poll();
            for (int[] array : arrays) {
                int i = cur[0];
                int j = cur[1];
                if (!isValid(i + array[0], j + array[1])) {
                    continue;
                }
                visit[i + array[0]][j + array[1]] = true;
                result[i + array[0]][j + array[1]] = result[i][j] + 1;
                queue.add(new int[]{ i + array[0], j + array[1] });
            }
        }
        return result;
    }

    private boolean isValid(int i, int j) {
        return i >= 0 && i < mat.length && j >= 0 && j < mat[0].length && !visit[i][j];
    }
}
