package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/10/24
 * 给定一个包含大写字母和小写字母的字符串 s ，返回 通过这些字母构造成的 最长的
 * 回文串
 * 的长度。
 * 在构造过程中，请注意 区分大小写 。比如 "Aa" 不能当做一个回文字符串。
 * 示例 1:
 * 输入:s = "abccccdd"
 * 输出:7
 * 解释:
 * 我们可以构造的最长的回文串是"dccaccd", 它的长度是 7。
 * 示例 2:
 * 输入:s = "a"
 * 输出:1
 * 解释：可以构造的最长回文串是"a"，它的长度是 1。
 * 提示:
 * 1 <= s.length <= 2000
 * s 只由小写 和/或 大写英文字母组成
 */
public class LC409_longest_palindrome {

    public int longestPalindrome(String s) {
        int result = 0;
        int oneCount = 0;
        int[] array = new int[128];

        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            array[c - 'A']++;
            if (array[c - 'A'] % 2 == 0) {
                result += 2;
                oneCount--;
            } else {
                oneCount++;
            }
        }
        if (oneCount > 0) {
            result++;
        }
        return result;
    }
}
