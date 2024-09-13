package com.peach.algo.LC251_300_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/11
 * 给你一个整数 n ，返回 和为 n 的完全平方数的最少数量 。
 * 完全平方数 是一个整数，其值等于另一个整数的平方；换句话说，其值等于一个整数自乘的积。例如，1、4、9 和 16 都是完全平方数，而 3 和 11 不是。
 * 示例 1：
 * 输入：n = 12
 * 输出：3
 * 解释：12 = 4 + 4 + 4
 * 示例 2：
 * 输入：n = 13
 * 输出：2
 * 解释：13 = 4 + 9
 * 提示：
 * 1 <= n <= 104
 */
public class LC279_perfect_squares {

    public int numSquares(int n) {
        int[] array = new int[10001];
        int sqrt = 1;
        int sqrt2 = sqrt * sqrt;
        int min;
        for (int i = 1; i <= n; i++) {
            if (i == sqrt2) {
                array[i] = 1;
                sqrt++;
                sqrt2 = sqrt * sqrt;
                continue;
            }
            min = Integer.MAX_VALUE;
            for (int j = 1; j < sqrt; j++) {
                min = Math.min(min, array[i - j * j] + 1);
            }
            array[i] = min;
        }
        return array[n];
    }
}
