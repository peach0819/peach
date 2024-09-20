package com.peach.algo;

import java.util.PriorityQueue;

/**
 * @author feitao.zt
 * @date 2024/9/20
 * 超级丑数 是一个正整数，并满足其所有质因数都出现在质数数组 primes 中。
 * 给你一个整数 n 和一个整数数组 primes ，返回第 n 个 超级丑数 。
 * 题目数据保证第 n 个 超级丑数 在 32-bit 带符号整数范围内。
 * 示例 1：
 * 输入：n = 12, primes = [2,7,13,19]
 * 输出：32
 * 解释：给定长度为 4 的质数数组 primes = [2,7,13,19]，前 12 个超级丑数序列为：[1,2,4,7,8,13,14,16,19,26,28,32] 。
 * 示例 2：
 * 输入：n = 1, primes = [2,3,5]
 * 输出：1
 * 解释：1 不含质因数，因此它的所有质因数都在质数数组 primes = [2,3,5] 中。
 * 提示：
 * 1 <= n <= 105
 * 1 <= primes.length <= 100
 * 2 <= primes[i] <= 1000
 * 题目数据 保证 primes[i] 是一个质数
 * primes 中的所有值都 互不相同 ，且按 递增顺序 排列
 */
public class LC313_super_ugly_number {

    public int nthSuperUglyNumber(int n, int[] primes) {
        if (n == 1) {
            return 1;
        }
        long cur = 1;
        int index = 1;
        PriorityQueue<Long> queue = new PriorityQueue<>();
        while (true) {
            for (int prime : primes) {
                if (cur < Integer.MAX_VALUE / prime) {
                    queue.offer(prime * cur);
                }
                //只和小于等于自己的的乘，大的后面大的时候会乘
                if (cur % prime == 0) {
                    break;
                }
            }

            cur = queue.poll();
            index++;
            if (index == n) {
                return (int) cur;
            }
        }
    }
}
