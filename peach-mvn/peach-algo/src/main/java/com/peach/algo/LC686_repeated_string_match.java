package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2026/1/20
 * 给定两个字符串 a 和 b，寻找重复叠加字符串 a 的最小次数，使得字符串 b 成为叠加后的字符串 a 的子串，如果不存在则返回 -1。
 * 注意：字符串 "abc" 重复叠加 0 次是 ""，重复叠加 1 次是 "abc"，重复叠加 2 次是 "abcabc"。
 * 示例 1：
 * 输入：a = "abcd", b = "cdabcdab"
 * 输出：3
 * 解释：a 重复叠加三遍后为 "abcdabcdabcd", 此时 b 是其子串。
 * 示例 2：
 * 输入：a = "a", b = "aa"
 * 输出：2
 * 示例 3：
 * 输入：a = "a", b = "a"
 * 输出：1
 * 示例 4：
 * 输入：a = "abc", b = "wxyz"
 * 输出：-1
 * 提示：
 * 1 <= a.length <= 104
 * 1 <= b.length <= 104
 * a 和 b 由小写英文字母组成
 */
public class LC686_repeated_string_match {

    public static void main(String[] args) {
        LC686_repeated_string_match test = new LC686_repeated_string_match();
        System.out.println(test.repeatedStringMatch("aa", "a"));
    }

    /**
     * 我是傻逼 官方KMP算法， KMP
     */
    public int repeatedStringMatch(String a, String b) {
        int an = a.length(), bn = b.length();
        int index = strStr(a, b);
        if (index == -1) {
            return -1;
        }
        if (an - index >= bn) {
            return 1;
        }
        return (bn + index - an - 1) / an + 2;
    }

    public int strStr(String a, String b) {
        int n = a.length(), m = b.length();
        if (m == 0) {
            return 0;
        }
        int[] pi = new int[m];
        for (int i = 1, j = 0; i < m; i++) {
            while (j > 0 && b.charAt(i) != b.charAt(j)) {
                j = pi[j - 1];
            }
            if (b.charAt(i) == b.charAt(j)) {
                j++;
            }
            pi[i] = j;
        }
        for (int i = 0, j = 0; i - j < n; i++) { // b 开始匹配的位置是否超过第一个叠加的 a
            while (j > 0 && a.charAt(i % n) != b.charAt(j)) { // a 是循环叠加的字符串，所以取 i % n
                j = pi[j - 1];
            }
            if (a.charAt(i % n) == b.charAt(j)) {
                j++;
            }
            if (j == m) {
                return i - m + 1;
            }
        }
        return -1;
    }

}
