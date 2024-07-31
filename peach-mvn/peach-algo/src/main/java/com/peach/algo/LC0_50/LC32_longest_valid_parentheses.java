package com.peach.algo.LC0_50;

/**
 * @author feitao.zt
 * @date 2023/9/4
 * 给你一个只包含 '(' 和 ')' 的字符串，找出最长有效（格式正确且连续）括号子串的长度。
 * 示例 1：
 * 输入：s = "(()"
 * 输出：2
 * 解释：最长有效括号子串是 "()"
 * 示例 2：
 * 输入：s = ")()())"
 * 输出：4
 * 解释：最长有效括号子串是 "()()"
 * 示例 3：
 * 输入：s = ""
 * 输出：0
 */
public class LC32_longest_valid_parentheses {

    public int longestValidParentheses(String s) {
        if (s.equals("")) {
            return 0;
        }
        char[] chars = s.toCharArray();
        int[] result = new int[chars.length];
        int max = 0;
        for (int i = 0; i < chars.length; i++) {
            char curChar = chars[i];
            if (curChar == ')' && i - 1 >= 0) {
                if (chars[i - 1] == '(') {
                    result[i] = 2;
                    if (i - 2 >= 0) {
                        result[i] += result[i - 2];
                    }
                } else if (chars[i - 1] == ')') {
                    if (i - 1 - result[i - 1] >= 0 && chars[i - 1 - result[i - 1]] == '(') {
                        result[i] = result[i - 1] + 2;
                        if (i - 2 - result[i - 1] >= 0) {
                            result[i] += result[i - 2 - result[i - 1]];
                        }
                    }
                }
            }
            max = Math.max(max, result[i]);
        }
        return max;
    }
}
