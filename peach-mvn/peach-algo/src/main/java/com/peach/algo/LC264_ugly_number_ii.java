package com.peach.algo;

import java.util.HashSet;
import java.util.PriorityQueue;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/9/10
 * 给你一个整数 n ，请你找出并返回第 n 个 丑数 。
 * 丑数 就是质因子只包含 2、3 和 5 的正整数。
 * 示例 1：
 * 输入：n = 10
 * 输出：12
 * 解释：[1, 2, 3, 4, 5, 6, 8, 9, 10, 12] 是由前 10 个丑数组成的序列。
 * 示例 2：
 * 输入：n = 1
 * 输出：1
 * 解释：1 通常被视为丑数。
 * 提示：
 * 1 <= n <= 1690
 */
public class LC264_ugly_number_ii {

    public static void main(String[] args) {
        new LC264_ugly_number_ii().nthUglyNumber(10);
    }

    /**
     * PriorityQueue 带排序的优先级队列
     */
    public int nthUglyNumber(int n) {
        Set<Long> set = new HashSet<>();
        PriorityQueue<Long> queue = new PriorityQueue<>();
        set.add(1L);
        queue.add(1L);
        long begin;
        int[] array = new int[]{ 2, 3, 5 };
        while (true) {
            begin = queue.poll();
            set.remove(begin);
            for (int i : array) {
                if (set.add(begin * i)) {
                    queue.add(begin * i);
                }
            }
            n--;
            if (n == 0) {
                return (int) begin;
            }
        }
    }
}
