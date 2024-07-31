package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/7/31
 * 给你一个字符串 s，请你将 s 分割成一些子串，使每个子串都是
 * 回文串
 * 。
 * 返回符合要求的 最少分割次数 。
 * 示例 1：
 * 输入：s = "aab"
 * 输出：1
 * 解释：只需一次分割就可将 s 分割成 ["aa","b"] 这样两个回文子串。
 * 示例 2：
 * 输入：s = "a"
 * 输出：0
 * 示例 3：
 * 输入：s = "ab"
 * 输出：1
 * 提示：
 * 1 <= s.length <= 2000
 * s 仅由小写英文字母组成
 */
public class LC132_palindrome_partitioning_ii {

    public static void main(String[] args) {
        int i = new LC132_palindrome_partitioning_ii().minCut("aab");
        int j = 1;
    }

    String s;
    int[] dp;

    public int minCut(String s) {
        this.s = s;
        dp = new int[s.length()];
        return handle(0) - 1;
    }

    private int handle(int beginIndex) {
        if (beginIndex == s.length()) {
            return 0;
        }
        if (dp[beginIndex] > 0) {
            return dp[beginIndex];
        }
        int min = Integer.MAX_VALUE;
        for (int i = s.length() - 1; i >= beginIndex; i--) {
            if (isReturnWord(i, beginIndex)) {
                min = Math.min(handle(i + 1), min);
            }
        }
        dp[beginIndex] = min + 1;
        return min + 1;

    }

    private boolean isReturnWord(int curIndex, int beginIndex) {
        while (beginIndex < curIndex) {
            if (s.charAt(beginIndex) != s.charAt(curIndex)) {
                return false;
            }
            beginIndex++;
            curIndex--;
        }
        return true;
    }
}
