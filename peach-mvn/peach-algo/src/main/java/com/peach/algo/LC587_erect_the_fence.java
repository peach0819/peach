package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2025/7/22
 * 给定一个数组 trees，其中 trees[i] = [xi, yi] 表示树在花园中的位置。
 * 你被要求用最短长度的绳子把整个花园围起来，因为绳子很贵。只有把 所有的树都围起来，花园才围得很好。
 * 返回恰好位于围栏周边的树木的坐标。
 * 示例 1:
 * 输入: points = [[1,1],[2,2],[2,0],[2,4],[3,3],[4,2]]
 * 输出: [[1,1],[2,0],[3,3],[2,4],[4,2]]
 * 示例 2:
 * 输入: points = [[1,2],[2,2],[4,2]]
 * 输出: [[4,2],[2,2],[1,2]]
 * 注意:
 * 1 <= points.length <= 3000
 * points[i].length == 2
 * 0 <= xi, yi <= 100
 * 所有给定的点都是 唯一 的。
 */
public class LC587_erect_the_fence {

    /**
     * 从最左边的点开始，一个个点找出最凸的点
     */
    public int[][] outerTrees(int[][] trees) {
        int n = trees.length;
        if (n < 4) {
            return trees;
        }
        int leftMost = 0;
        for (int i = 0; i < n; i++) {
            if (trees[i][0] < trees[leftMost][0] ||
                    (trees[i][0] == trees[leftMost][0] &&
                            trees[i][1] < trees[leftMost][1])) {
                leftMost = i;
            }
        }

        List<int[]> res = new ArrayList<int[]>();
        boolean[] visit = new boolean[n];
        int p = leftMost;
        do {
            int q = (p + 1) % n;
            for (int r = 0; r < n; r++) {
                /* 如果 r 在 pq 的右侧，则 q = r */
                if (cross(trees[p], trees[q], trees[r]) < 0) {
                    q = r;
                }
            }
            /* 是否存在点 i, 使得 p 、q 、i 在同一条直线上 */
            for (int i = 0; i < n; i++) {
                if (visit[i] || i == p || i == q) {
                    continue;
                }
                if (cross(trees[p], trees[q], trees[i]) == 0) {
                    res.add(trees[i]);
                    visit[i] = true;
                }
            }
            if (!visit[q]) {
                res.add(trees[q]);
                visit[q] = true;
            }
            p = q;
        } while (p != leftMost);
        return res.toArray(new int[][]{});
    }

    public int cross(int[] p, int[] q, int[] r) {
        return (q[0] - p[0]) * (r[1] - q[1]) - (q[1] - p[1]) * (r[0] - q[0]);
    }

    //int[] top;
    //int[] bottom;
    //int[] left;
    //int[] right;
    //
    //List<int[]> result = new ArrayList<>();
    //
    //public int[][] outerTrees(int[][] trees) {
    //    this.top = trees[0];
    //    this.bottom = trees[0];
    //    this.left = trees[0];
    //    this.right = trees[0];
    //    for (int[] tree : trees) {
    //        if (tree[1] > top[1]) {
    //            top = tree;
    //        } else if (tree[1] < bottom[1]) {
    //            bottom = tree;
    //        } else if (tree[0] < left[0]) {
    //            left = tree;
    //        } else if (tree[0] > right[0]) {
    //            right = tree;
    //        }
    //    }
    //    result.add(top);
    //    result.add(bottom);
    //    result.add(left);
    //    result.add(right);
    //
    //    List<int[]> topLeft = new ArrayList<>();
    //    List<int[]> topRight = new ArrayList<>();
    //    List<int[]> bottomLeft = new ArrayList<>();
    //    List<int[]> bottomRight = new ArrayList<>();
    //    for (int[] tree : trees) {
    //        if(tree[0])
    //    }
    //
    //
    //}
}
