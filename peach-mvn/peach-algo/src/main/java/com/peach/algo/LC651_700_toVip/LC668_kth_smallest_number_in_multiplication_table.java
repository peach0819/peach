package com.peach.algo.LC651_700_toVip;

/**
 * @author feitao.zt
 * @date 2025/11/3
 * 几乎每一个人都用 乘法表。但是你能在乘法表中快速找到第 k 小的数字吗？
 * 乘法表是大小为 m x n 的一个整数矩阵，其中 mat[i][j] == i * j（下标从 1 开始）。
 * 给你三个整数 m、n 和 k，请你在大小为 m x n 的乘法表中，找出并返回第 k 小的数字。
 * 示例 1：
 * 输入：m = 3, n = 3, k = 5
 * 输出：3
 * 解释：第 5 小的数字是 3 。
 * 示例 2：
 * 输入：m = 2, n = 3, k = 6
 * 输出：6
 * 解释：第 6 小的数字是 6 。
 * 提示：
 * 1 <= m, n <= 3 * 104
 * 1 <= k <= m * n
 */
public class LC668_kth_smallest_number_in_multiplication_table {

    /**
     * 我是傻逼
     * 通过二分法，从1到m*n之间，找小于每个数的数有多少，不停二分
     * 找小于的方式为每行遍历
     */
    public int findKthNumber(int m, int n, int k) {
        int left = 1, right = m * n;
        while (left < right) {
            int x = left + (right - left) / 2;
            int count = x / n * n;
            for (int i = x / n + 1; i <= m; ++i) {
                count += x / i;
            }
            if (count >= k) {
                right = x;
            } else {
                left = x + 1;
            }
        }
        return left;
    }

    //public int findKthNumber(int m, int n, int k) {
    //    //int[3] 0:val 1:第几行 2：第几列
    //    PriorityQueue<int[]> queue = new PriorityQueue<>((a, b) -> {
    //        return a[0] - b[0];
    //    });
    //
    //    for (int i = 1; i <= m; i++) {
    //        queue.offer(new int[]{ i, i, 1 });
    //    }
    //
    //    int index = 1;
    //    while (true) {
    //        int[] poll = queue.poll();
    //        if (index == k) {
    //            return poll[0];
    //        }
    //        index++;
    //        if (poll[2] < n) {
    //            queue.offer(new int[]{ poll[1] * (poll[2] + 1), poll[1], poll[2] + 1 });
    //        }
    //    }
    //}
}
