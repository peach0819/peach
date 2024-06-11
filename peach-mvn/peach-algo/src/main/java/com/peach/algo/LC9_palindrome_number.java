package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/6/11
 * 给你一个整数 x ，如果 x 是一个回文整数，返回 true ；否则，返回 false 。
 * 回文数
 * 是指正序（从左向右）和倒序（从右向左）读都是一样的整数。
 * 例如，121 是回文，而 123 不是。
 * 示例 1：
 * 输入：x = 121
 * 输出：true
 * 示例 2：
 * 输入：x = -121
 * 输出：false
 * 解释：从左向右读, 为 -121 。 从右向左读, 为 121- 。因此它不是一个回文数。
 * 示例 3：
 * 输入：x = 10
 * 输出：false
 * 解释：从右向左读, 为 01 。因此它不是一个回文数。
 * 提示：
 * -231 <= x <= 231 - 1
 * 进阶：你能不将整数转为字符串来解决这个问题吗？
 */
public class LC9_palindrome_number {

    public boolean isPalindrome0(int x) {
        if (x < 0) {
            return false;
        }
        String s = String.valueOf(x);
        char[] chars = s.toCharArray();
        for (int i = 0; i < chars.length; i++) {
            int j = chars.length - 1 - i;
            if (j < i) {
                break;
            }
            if (chars[i] != chars[j]) {
                return false;
            }
        }
        return true;
    }

    public boolean isPalindrome(int x) {
        if (x < 0) {
            return false;
        }
        int cur = 0;
        int num = x;
        while (true) {
            cur = cur * 10 + num % 10;
            num = num / 10;
            if (num == 0) {
                break;
            }
        }
        return cur == x;
    }
}
