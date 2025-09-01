package com.peach.algo.LC551_600_toVip;

/**
 * @author feitao.zt
 * @date 2025/6/11
 * 给定一个字符串 s ，你需要反转字符串中每个单词的字符顺序，同时仍保留空格和单词的初始顺序。
 * 示例 1：
 * 输入：s = "Let's take LeetCode contest"
 * 输出："s'teL ekat edoCteeL tsetnoc"
 * 示例 2:
 * 输入： s = "Mr Ding"
 * 输出："rM gniD"
 * 提示：
 * 1 <= s.length <= 5 * 104
 * s 包含可打印的 ASCII 字符。
 * s 不包含任何开头或结尾空格。
 * s 里 至少 有一个词。
 * s 中的所有单词都用一个空格隔开。
 */
public class LC557_reverse_words_in_a_string_iii {

    char[] chars;

    public String reverseWords(String s) {
        chars = s.toCharArray();
        int begin = 0;
        int end = 0;
        boolean has = false;
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < chars.length; i++) {
            if (!isLetter(chars[i])) {
                if (has) {
                    sb.append(reverse(begin, end));
                    has = false;
                }
                sb.append(chars[i]);
            } else {
                if (!has) {
                    begin = i;
                    has = true;
                }
                end = i;
            }
        }
        if (has) {
            sb.append(reverse(begin, end));
        }
        return sb.toString();
    }

    private boolean isLetter(char c) {
        return c != ' ';
    }

    private String reverse(int i, int j) {
        if (i == j) {
            return String.valueOf(chars[i]);
        }
        StringBuilder sb = new StringBuilder();
        sb.append(chars, i, j - i + 1);
        sb.reverse();
        return sb.toString();
    }
}
