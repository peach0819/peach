package com.peach.algo.LC0_50;

/**
 * @author feitao.zt
 * @date 2024/6/19
 * 示例 1：
 * 输入：s = "babad"
 * 输出："bab"
 * 解释："aba" 同样是符合题意的答案。
 * 示例 2：
 * 输入：s = "cbbd"
 * 输出："bb"
 * 提示：
 * 1 <= s.length <= 1000
 * s 仅由数字和英文字母组成
 */
public class LC5_longest_palindromic_substring {

    public String longestPalindrome(String s) {
        char[] chars = s.toCharArray();
        int length = chars.length;

        int begin = 0;
        int end = 0;
        int max = 0;
        for (int i = 0; i < length; i++) {
            int curMax;
            if ((i + 2) < length && chars[i] == chars[i + 2]) {
                int result = handle(chars, i, i + 2);
                curMax = 3 + 2 * result;
                if (curMax > max) {
                    begin = i - result;
                    end = i + 2 + result;
                    max = curMax;
                }
            }

            if ((i + 1) < length && chars[i] == chars[i + 1]) {
                int result = handle(chars, i, i + 1);
                curMax = 2 + 2 * result;
                if (curMax > max) {
                    begin = i - result;
                    end = i + 1 + result;
                    max = curMax;
                }
            }
        }
        return s.substring(begin, end + 1);
    }

    private int handle(char[] chars, int curBegin, int curEnd) {
        int result = 0;
        while (curBegin != 0 && curEnd != chars.length - 1 && chars[curBegin - 1] == chars[curEnd + 1]) {
            result++;
            curBegin = curBegin - 1;
            curEnd = curEnd + 1;
        }
        return result;
    }
}
