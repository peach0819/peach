package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/9/30
 * 给定一个正整数 n ，将其拆分为 k 个 正整数 的和（ k >= 2 ），并使这些整数的乘积最大化。
 * 返回 你可以获得的最大乘积 。
 * 示例 1:
 * 输入: n = 2
 * 输出: 1
 * 解释: 2 = 1 + 1, 1 × 1 = 1。
 * 示例 2:
 * 输入: n = 10
 * 输出: 36
 * 解释: 10 = 3 + 3 + 4, 3 × 3 × 4 = 36。
 * 提示:
 * 2 <= n <= 58
 */
public class LC343_integer_break {

    public static void main(String[] args) {
        new LC343_integer_break().integerBreak(2);
    }

    /**
     * 将数字 n 尽可能以因子 3 等分时，乘积最大。
     */
    public int integerBreak(int n) {
        int[] dp = new int[59];
        dp[2] = 1;
        dp[3] = 2;
        dp[4] = 4;
        dp[5] = 6;
        dp[6] = 9;
        for (int i = 7; i <= n; i++) {
            dp[i] = dp[i - 3] * 3;
        }
        return dp[n];
    }
}
