package com.peach.algo.LC201_250_toVip;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/8/13
 * 给定整数 n ，返回 所有小于非负整数 n 的质数的数量 。
 * 示例 1：
 * 输入：n = 10
 * 输出：4
 * 解释：小于 10 的质数一共有 4 个, 它们是 2, 3, 5, 7 。
 * 示例 2：
 * 输入：n = 0
 * 输出：0
 * 示例 3：
 * 输入：n = 1
 * 输出：0
 * 提示：
 * 0 <= n <= 5 * 106
 */
public class LC204_count_primes {

    public static void main(String[] args) {
        new LC204_count_primes().countPrimes(10);
    }

    /**
     * 我是傻逼
     * 埃氏筛, 从 i * i 开始标记
     */
    public int countPrimes(int n) {
        if (n < 3) {
            return 0;
        }
        if (n == 3) {
            return 1;
        }
        List<Integer> result = new ArrayList<>();
        int[] array = new int[n];
        boolean over = false;
        for (int i = 2; i < n; i++) {
            if (array[i] == 1) {
                continue;
            }
            result.add(i);
            if (over) {
                continue;
            }
            for (int j = i; j * i < n; j++) {
                array[i * j] = 1;
            }
            if (i * i > n) {
                over = true;
            }
        }
        return result.size();
    }
}
