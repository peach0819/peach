package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/10/10
 * 给你一个字符串 s ，请你统计并返回这个字符串中 回文子串 的数目。
 * 回文字符串 是正着读和倒过来读一样的字符串。
 * 子字符串 是字符串中的由连续字符组成的一个序列。
 * 示例 1：
 * 输入：s = "abc"
 * 输出：3
 * 解释：三个回文子串: "a", "b", "c"
 * 示例 2：
 * 输入：s = "aaa"
 * 输出：6
 * 解释：6个回文子串: "a", "a", "a", "aa", "aa", "aaa"
 * 提示：
 * 1 <= s.length <= 1000
 * s 由小写英文字母组成
 */
public class LC647_palindromic_substrings {

    public static void main(String[] args) {
        LC647_palindromic_substrings lc647_palindromic_substrings = new LC647_palindromic_substrings();
        System.out.println(lc647_palindromic_substrings.countSubstrings("abc"));
    }

    char[] before;
    char[] after;
    int n;

    /**
     * 更好的做法是找回文中心，分奇中心和偶中心
     *
     * @param s
     * @return
     */
    public int countSubstrings(String s) {
        before = s.toCharArray();
        after = new StringBuilder(s).reverse().toString().toCharArray();
        n = before.length;

        int result = n;
        for (int i = 0; i < n - 1; i++) {
            for (int j = i + 1; j < n; j++) {
                if (isSub(i, j)) {
                    result++;
                }
            }
        }
        return result;
    }

    private boolean isSub(int beginIndex, int endIndex) {
        int offset = n - 1 - endIndex - beginIndex;
        for (int i = beginIndex; i <= endIndex; i++) {
            if (before[i] != after[i + offset]) {
                return false;
            }
        }
        return true;
    }

}
