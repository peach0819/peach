package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/8/30
 * 给定一个字符串 s，你可以通过在字符串前面添加字符将其转换为
 * 回文串
 * 。找到并返回可以用这种方式转换的最短回文串。
 * 示例 1：
 * 输入：s = "aacecaaa"
 * 输出："aaacecaaa"
 * 示例 2：
 * 输入：s = "abcd"
 * 输出："dcbabcd"
 * 提示：
 * 0 <= s.length <= 5 * 104
 * s 仅由小写英文字母组成
 */
public class LC214_shortest_palindrome {

    /**
     * 题解用的KMP算法
     */
    public String shortestPalindrome(String s) {
        char[] chars = s.toCharArray();
        int last = chars.length - 1;
        while (last > 0) {
            if (isRText(chars, 0, last)) {
                break;
            }
            last--;
        }
        StringBuilder result = new StringBuilder();
        for (int i = s.length() - 1; i > last; i--) {
            result.append(s.charAt(i));
        }
        result.append(s);
        return result.toString();
    }

    private boolean isRText(char[] array, int begin, int end) {
        while (begin < end) {
            if (array[begin] != array[end]) {
                return false;
            }
            begin++;
            end--;
        }
        return true;
    }
}
