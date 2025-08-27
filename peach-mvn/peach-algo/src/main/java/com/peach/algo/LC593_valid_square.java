package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/8/27
 * 给定2D空间中四个点的坐标 p1, p2, p3 和 p4，如果这四个点构成一个正方形，则返回 true 。
 * 点的坐标 pi 表示为 [xi, yi] 。 输入没有任何顺序 。
 * 一个 有效的正方形 有四条等边和四个等角(90度角)。
 * 示例 1:
 * 输入: p1 = [0,0], p2 = [1,1], p3 = [1,0], p4 = [0,1]
 * 输出: true
 * 示例 2:
 * 输入：p1 = [0,0], p2 = [1,1], p3 = [1,0], p4 = [0,12]
 * 输出：false
 * 示例 3:
 * 输入：p1 = [1,0], p2 = [-1,0], p3 = [0,1], p4 = [0,-1]
 * 输出：true
 * 提示:
 * p1.length == p2.length == p3.length == p4.length == 2
 * -104 <= xi, yi <= 104
 */
public class LC593_valid_square {

    public boolean validSquare(int[] p1, int[] p2, int[] p3, int[] p4) {
        int l12 = distance(p1, p2);
        int l13 = distance(p1, p3);
        int l14 = distance(p1, p4);
        if (l12 == 0 || l13 == 0 || l14 == 0) {
            return false;
        }
        if (l12 != l13 && l12 != l14 && l13 != l14) {
            return false;
        }
        if (l12 == l13 && l12 + l13 == l14) {
            int l23 = distance(p2, p3);
            int l24 = distance(p2, p4);
            int l34 = distance(p3, p4);
            return l23 == l14 && l24 == l34 && l12 == l24;
        }
        if (l12 == l14 && l12 + l14 == l13) {
            int l24 = distance(p2, p4);
            int l23 = distance(p2, p3);
            int l34 = distance(p3, p4);
            return l24 == l13 && l23 == l34 && l12 == l23;
        }
        if (l13 == l14 && l13 + l14 == l12) {
            int l34 = distance(p3, p4);
            int l23 = distance(p2, p3);
            int l24 = distance(p2, p4);
            return l34 == l12 && l23 == l24 && l13 == l23;
        }
        return false;
    }

    public int distance(int[] p1, int[] p2) {
        return (p1[0] - p2[0]) * (p1[0] - p2[0]) + (p1[1] - p2[1]) * (p1[1] - p2[1]);
    }
}
