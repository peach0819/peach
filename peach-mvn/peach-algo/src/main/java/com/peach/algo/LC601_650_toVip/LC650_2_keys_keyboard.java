package com.peach.algo.LC601_650_toVip;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2025/10/11
 * 最初记事本上只有一个字符 'A' 。你每次可以对这个记事本进行两种操作：
 * Copy All（复制全部）：复制这个记事本中的所有字符（不允许仅复制部分字符）。
 * Paste（粘贴）：粘贴 上一次 复制的字符。
 * 给你一个数字 n ，你需要使用最少的操作次数，在记事本上输出 恰好 n 个 'A' 。返回能够打印出 n 个 'A' 的最少操作次数。
 * 示例 1：
 * 输入：3
 * 输出：3
 * 解释：
 * 最初, 只有一个字符 'A'。
 * 第 1 步, 使用 Copy All 操作。
 * 第 2 步, 使用 Paste 操作来获得 'AA'。
 * 第 3 步, 使用 Paste 操作来获得 'AAA'。
 * 示例 2：
 * 输入：n = 1
 * 输出：0
 * 提示：
 * 1 <= n <= 1000
 */
public class LC650_2_keys_keyboard {

    public static void main(String[] args) {
        LC650_2_keys_keyboard lc650_2_keys_keyboard = new LC650_2_keys_keyboard();
        System.out.println(lc650_2_keys_keyboard.minSteps1(3));
    }

    public int minSteps(int n) {
        int[][] dp = new int[n + 1][n + 1];
        dp[1][0] = 0;
        dp[1][1] = 1;
        for (int i = 2; i <= n; i++) {
            Arrays.fill(dp[i], 1000000);
            int min = Integer.MAX_VALUE;
            for (int j = 1; j <= i / 2; j++) {
                dp[i][j] = dp[i - j][j] + 1;
                min = Math.min(min, dp[i][j]);
            }
            dp[i][i] = min + 1;
        }
        int result = Integer.MAX_VALUE;
        for (int i = 1; i <= n; i++) {
            result = Math.min(result, dp[n][i]);
        }
        return result;
    }

    public int minSteps1(int n) {
        if (n == 1) {
            return 0;
        }
        int[][] dp = new int[n + 1][n + 1];
        dp[1][0] = 0;
        dp[1][1] = 1;
        for (int i = 2; i <= n; i++) {
            Arrays.fill(dp[i], 1000000);
            int min = Integer.MAX_VALUE;
            for (int j = 1; j <= i / 2; j++) {
                dp[i][j] = dp[i - j][j] + 1;
                min = Math.min(min, dp[i][j]);
            }
            dp[i][i] = min + 1;
        }
        int result = Integer.MAX_VALUE;
        for (int i = 1; i <= n; i++) {
            result = Math.min(result, dp[n][i]);
        }
        return result;
    }
}
