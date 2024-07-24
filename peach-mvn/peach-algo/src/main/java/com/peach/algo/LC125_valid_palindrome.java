package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/7/24
 * 如果在将所有大写字符转换为小写字符、并移除所有非字母数字字符之后，短语正着读和反着读都一样。则可以认为该短语是一个 回文串 。
 * 字母和数字都属于字母数字字符。
 * 给你一个字符串 s，如果它是 回文串 ，返回 true ；否则，返回 false 。
 * 示例 1：
 * 输入: s = "A man, a plan, a canal: Panama"
 * 输出：true
 * 解释："amanaplanacanalpanama" 是回文串。
 * 示例 2：
 * 输入：s = "race a car"
 * 输出：false
 * 解释："raceacar" 不是回文串。
 * 示例 3：
 * 输入：s = " "
 * 输出：true
 * 解释：在移除非字母数字字符之后，s 是一个空字符串 "" 。
 * 由于空字符串正着反着读都一样，所以是回文串。
 * 提示：
 * 1 <= s.length <= 2 * 105
 * s 仅由可打印的 ASCII 字符组成
 */
public class LC125_valid_palindrome {

    public static void main(String[] args) {
        new LC125_valid_palindrome().isPalindrome("A man, a plan, a canal: Panama");
    }

    public boolean isPalindrome(String s) {
        s = s.toLowerCase();
        char[] chars = s.toCharArray();
        int begin = 0;
        int end = chars.length - 1;
        while (begin < end) {
            if (!isValid(chars[begin])) {
                begin++;
            } else if (!isValid(chars[end])) {
                end--;
            } else if (chars[begin] != chars[end]) {
                return false;
            } else {
                begin++;
                end--;
            }
        }
        return true;
    }

    public boolean isValid(char c) {
        if (c >= '0' && c <= '9') {
            return true;
        }
        if (c >= 'a' && c <= 'z') {
            return true;
        }
        return false;
    }
}
