package com.peach.algo.LC101_150;

/**
 * @author feitao.zt
 * @date 2024/8/2
 * 给你一个数组 points ，其中 points[i] = [xi, yi] 表示 X-Y 平面上的一个点。求最多有多少个点在同一条直线上。
 * 示例 1：
 * 输入：points = [[1,1],[2,2],[3,3]]
 * 输出：3
 * 示例 2：
 * 输入：points = [[1,1],[3,2],[5,3],[4,1],[2,3],[1,4]]
 * 输出：4
 * 提示：
 * 1 <= points.length <= 300
 * points[i].length == 2
 * -104 <= xi, yi <= 104
 * points 中的所有点 互不相同
 */
public class LC149_max_points_on_a_line {

    public static void main(String[] args) {
        new LC149_max_points_on_a_line()
                .maxPoints(new int[][]{ { 1, 1 }, { 3, 2 }, { 5, 3 }, { 4, 1 }, { 2, 3 }, { 1, 4 } });
    }

    public int maxPoints(int[][] points) {
        if (points.length == 1) {
            return 1;
        }
        if (points.length == 2) {
            return 2;
        }
        int max = 2;
        for (int i = 0; i < points.length; i++) {
            int[] cur = points[i];
            for (int j = i + 1; j < points.length; j++) {
                int[] cur2 = points[j];
                int curMax = 2;
                for (int k = j + 1; k < points.length; k++) {
                    int[] cur3 = points[k];
                    if (isLine(cur, cur2, cur3)) {
                        curMax++;
                    }
                }
                max = Math.max(max, curMax);
            }
        }
        return max;
    }

    private boolean isLine(int[] a, int[] b, int[] c) {
        return (b[1] - a[1]) * (c[0] - a[0]) == (c[1] - a[1]) * (b[0] - a[0]);
    }
}
