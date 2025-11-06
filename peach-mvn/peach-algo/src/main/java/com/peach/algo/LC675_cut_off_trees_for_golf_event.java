package com.peach.algo;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.List;
import java.util.Queue;

/**
 * @author feitao.zt
 * @date 2025/11/6
 * 你被请来给一个要举办高尔夫比赛的树林砍树。树林由一个 m x n 的矩阵表示， 在这个矩阵中：
 * 0 表示障碍，无法触碰
 * 1 表示地面，可以行走
 * 比 1 大的数 表示有树的单元格，可以行走，数值表示树的高度
 * 每一步，你都可以向上、下、左、右四个方向之一移动一个单位，如果你站的地方有一棵树，那么你可以决定是否要砍倒它。
 * 你需要按照树的高度从低向高砍掉所有的树，每砍过一颗树，该单元格的值变为 1（即变为地面）。
 * 你将从 (0, 0) 点开始工作，返回你砍完所有树需要走的最小步数。 如果你无法砍完所有的树，返回 -1 。
 * 可以保证的是，没有两棵树的高度是相同的，并且你至少需要砍倒一棵树。
 * 示例 1：
 * 输入：forest = [[1,2,3],[0,0,4],[7,6,5]]
 * 输出：6
 * 解释：沿着上面的路径，你可以用 6 步，按从最矮到最高的顺序砍掉这些树。
 * 示例 2：
 * 输入：forest = [[1,2,3],[0,0,0],[7,6,5]]
 * 输出：-1
 * 解释：由于中间一行被障碍阻塞，无法访问最下面一行中的树。
 * 示例 3：
 * 输入：forest = [[2,3,4],[0,0,5],[8,7,6]]
 * 输出：6
 * 解释：可以按与示例 1 相同的路径来砍掉所有的树。
 * (0,0) 位置的树，可以直接砍去，不用算步数。
 * 提示：
 * m == forest.length
 * n == forest[i].length
 * 1 <= m, n <= 50
 * 0 <= forest[i][j] <= 109
 */
public class LC675_cut_off_trees_for_golf_event {

    int[][] dirs = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } };
    List<List<Integer>> forest;

    /**
     * 我是傻逼，按值排序，然后一步步走，按BFS走，广度优先搜索
     */
    public int cutOffTree(List<List<Integer>> forest) {
        this.forest = forest;
        List<int[]> trees = new ArrayList<>();
        for (int i = 0; i < forest.size(); ++i) {
            for (int j = 0; j < forest.get(0).size(); ++j) {
                if (forest.get(i).get(j) > 1) {
                    trees.add(new int[]{ i, j });
                }
            }
        }
        trees.sort((a, b) -> forest.get(a[0]).get(a[1]) - forest.get(b[0]).get(b[1]));

        int cx = 0;
        int cy = 0;
        int result = 0;
        for (int[] tree : trees) {
            int steps = bfs(cx, cy, tree[0], tree[1]);
            if (steps == -1) {
                return -1;
            }
            result += steps;
            cx = tree[0];
            cy = tree[1];
        }
        return result;
    }

    public int bfs(int beginX, int beginY, int endX, int endY) {
        if (beginX == endX && beginY == endY) {
            return 0;
        }

        int step = 0;
        Queue<int[]> queue = new ArrayDeque<>();
        queue.offer(new int[]{ beginX, beginY });

        boolean[][] visited = new boolean[forest.size()][forest.get(0).size()];
        visited[beginX][beginY] = true;
        while (!queue.isEmpty()) {
            step++;
            for (int i = 0; i < queue.size(); ++i) {
                int[] cell = queue.poll();
                int curX = cell[0];
                int curY = cell[1];
                for (int j = 0; j < 4; ++j) {
                    int nextX = curX + dirs[j][0];
                    int nextY = curY + dirs[j][1];
                    if (nextX >= 0 && nextX < forest.size() && nextY >= 0 && nextY < forest.get(0).size()) {
                        if (!visited[nextX][nextY] && forest.get(nextX).get(nextY) > 0) {
                            if (nextX == endX && nextY == endY) {
                                return step;
                            }
                            queue.offer(new int[]{ nextX, nextY });
                            visited[nextX][nextY] = true;
                        }
                    }
                }
            }
        }
        return -1;
    }

}
