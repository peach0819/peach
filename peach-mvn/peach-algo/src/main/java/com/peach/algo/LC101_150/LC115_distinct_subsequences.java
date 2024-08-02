package com.peach.algo.LC101_150;

/**
 * @author feitao.zt
 * @date 2024/7/25
 * 给你两个字符串 s 和 t ，统计并返回在 s 的 子序列 中 t 出现的个数，结果需要对 109 + 7 取模。
 * 示例 1：
 * 输入：s = "rabbbit", t = "rabbit"
 * 输出：3
 * 解释：
 * 如下所示, 有 3 种可以从 s 中得到 "rabbit" 的方案。
 * rabbbit
 * rabbbit
 * rabbbit
 * 示例 2：
 * 输入：s = "babgbag", t = "bag"
 * 输出：5
 * 解释：
 * 如下所示, 有 5 种可以从 s 中得到 "bag" 的方案。
 * babgbag
 * babgbag
 * babgbag
 * babgbag
 * babgbag
 * 提示：
 * 1 <= s.length, t.length <= 1000
 * s 和 t 由英文字母组成
 */
public class LC115_distinct_subsequences {

    /**
     * 动态规划，我是傻逼
     * dp[i][j] 表示 s的第i位 和 t的第j位匹配的个数
     * 当 S[j] == T[i] , dp[i][j] = dp[i-1][j-1] + dp[i][j-1];
     * 当 S[j] != T[i] , dp[i][j] = dp[i][j-1]
     */
    public int numDistinct1(String s, String t) {
        char[] chars = s.toCharArray();
        char[] chart = t.toCharArray();

        int[][] dp = new int[s.length()][t.length()];
        dp[0][0] = 1;
        for (int i = 1; i < s.length(); i++) {
            dp[i][0] = 1;
        }
        for (int i = 0; i < t.length(); i++) {
            dp[0][i] = 0;
        }
        for (int i = 1; i < s.length(); i++) {
            for (int j = 1; j < t.length(); j++) {
                if (chars[i] == chart[j]) {
                    dp[i][j] = dp[i - 1][j - 1] + dp[i][j - 1];
                } else {
                    dp[i][j] = dp[i][j - 1];
                }
            }
        }
        return dp[s.length() - 1][t.length() - 1];
    }

    public int numDistinct(String s, String t) {
        int[] dp = new int[t.length() + 1];
        dp[t.length()] = 1;
        for (int i = s.length() - 1; i >= 0; i--) {
            for (int j = 0; j < t.length(); j++) {
                if (t.charAt(j) == s.charAt(i)) {
                    dp[j] += dp[j + 1];
                }
            }
        }
        return dp[0];
    }
}
