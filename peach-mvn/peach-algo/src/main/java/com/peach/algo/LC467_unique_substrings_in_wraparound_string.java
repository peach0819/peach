package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/12/18
 * 定义字符串 base 为一个 "abcdefghijklmnopqrstuvwxyz" 无限环绕的字符串，所以 base 看起来是这样的：
 * "...zabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcd....".
 * 给你一个字符串 s ，请你统计并返回 s 中有多少 不同非空子串 也在 base 中出现。
 * 示例 1：
 * 输入：s = "a"
 * 输出：1
 * 解释：字符串 s 的子字符串 "a" 在 base 中出现。
 * 示例 2：
 * 输入：s = "cac"
 * 输出：2
 * 解释：字符串 s 有两个子字符串 ("a", "c") 在 base 中出现。
 * 示例 3：
 * 输入：s = "zab"
 * 输出：6
 * 解释：字符串 s 有六个子字符串 ("z", "a", "b", "za", "ab", and "zab") 在 base 中出现。
 * 提示：
 * 1 <= s.length <= 105
 * s 由小写英文字母组成
 */
public class LC467_unique_substrings_in_wraparound_string {

    public static void main(String[] args) {
        new LC467_unique_substrings_in_wraparound_string().findSubstringInWraproundString("cacd");
    }

    public int findSubstringInWraproundString(String s) {
        int[] array = new int[26];
        int begin = 0;
        while (begin < s.length()) {
            char c = s.charAt(begin);
            int cur = begin + 1;
            while (cur < s.length() && isNext(s.charAt(cur - 1), s.charAt(cur))) {
                cur++;
            }
            array[c - 'a'] = Math.max(array[c - 'a'], cur - begin);
            begin = cur;
        }
        for (int i = 0; i < array.length; i++) {
            char c = (char) ('a' + i);
            int cur = array[i];
            for (int j = 0; j < Math.min(25, cur); j++) {
                char c1 = getAdd(c, j);
                array[c1 - 'a'] = Math.max(array[c1 - 'a'], cur - j);
            }
        }
        int result = 0;
        for (int i = 0; i < array.length; i++) {
            result += array[i];
        }
        return result;
    }

    private boolean isNext(char pre, char next) {
        if (pre == 'z' && next == 'a') {
            return true;
        }
        return next == (pre + 1);
    }

    private char getAdd(char before, int addition) {
        int i = before + addition;
        if (i > 'z') {
            return (char) (i - 26);
        }
        return (char) i;
    }

}
