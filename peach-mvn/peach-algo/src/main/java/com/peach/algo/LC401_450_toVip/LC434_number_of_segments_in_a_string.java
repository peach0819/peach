package com.peach.algo.LC401_450_toVip;

/**
 * @author feitao.zt
 * @date 2024/12/9
 * 统计字符串中的单词个数，这里的单词指的是连续的不是空格的字符。
 * 请注意，你可以假定字符串里不包括任何不可打印的字符。
 * 示例:
 * 输入: "Hello, my name is John"
 * 输出: 5
 * 解释: 这里的单词是指连续的不是空格的字符，所以 "Hello," 算作 1 个单词。
 */
public class LC434_number_of_segments_in_a_string {

    public int countSegments(String s) {
        boolean start = false;
        int result = 0;

        char c;
        for (int i = 0; i <= s.length(); i++) {
            c = i == s.length() ? ' ' : s.charAt(i);
            if (start && c == ' ') {
                result++;
                start = false;
                continue;
            }
            if (!start && c != ' ') {
                start = true;
            }
        }
        return result;
    }
}
