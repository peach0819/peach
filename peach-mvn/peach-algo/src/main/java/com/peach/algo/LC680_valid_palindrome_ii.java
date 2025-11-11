package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/11/11
 * 给你一个字符串 s，最多 可以从中删除一个字符。
 * 请你判断 s 是否能成为回文字符串：如果能，返回 true ；否则，返回 false 。
 * 示例 1：
 * 输入：s = "aba"
 * 输出：true
 * 示例 2：
 * 输入：s = "abca"
 * 输出：true
 * 解释：你可以删除字符 'c' 。
 * 示例 3：
 * 输入：s = "abc"
 * 输出：false
 * 提示：
 * 1 <= s.length <= 105
 * s 由小写英文字母组成
 */
public class LC680_valid_palindrome_ii {

    public static void main(String[] args) {
        //System.out.println(new LC680_valid_palindrome_ii().validPalindrome("cupuufxoohdfpgjdmysgvhmvffcnqxjjxqncffvmhvgsymdjgpfdhooxfuupucu"));
        System.out.println(new LC680_valid_palindrome_ii().validPalindrome("abca"));
    }

    char[] array;

    public boolean validPalindrome(String s) {
        array = s.toCharArray();
        return isPalindrome(0, array.length - 1, false);
    }

    private boolean isPalindrome(int begin, int end, boolean replace) {
        while (begin < end) {
            char c1 = array[begin];
            char c2 = array[end];
            if (c1 == c2) {
                begin++;
                end--;
            } else if (replace) {
                return false;
            } else {
                return isPalindrome(begin + 1, end, true) || isPalindrome(begin, end - 1, true);
            }
        }
        return true;
    }
}
