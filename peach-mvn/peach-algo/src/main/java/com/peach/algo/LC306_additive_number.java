package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/9/13
 * 累加数 是一个字符串，组成它的数字可以形成累加序列。
 * 一个有效的 累加序列 必须 至少 包含 3 个数。除了最开始的两个数以外，序列中的每个后续数字必须是它之前两个数字之和。
 * 给你一个只包含数字 '0'-'9' 的字符串，编写一个算法来判断给定输入是否是 累加数 。如果是，返回 true ；否则，返回 false 。
 * 说明：累加序列里的数，除数字 0 之外，不会 以 0 开头，所以不会出现 1, 2, 03 或者 1, 02, 3 的情况。
 * 示例 1：
 * 输入："112358"
 * 输出：true
 * 解释：累加序列为: 1, 1, 2, 3, 5, 8 。1 + 1 = 2, 1 + 2 = 3, 2 + 3 = 5, 3 + 5 = 8
 * 示例 2：
 * 输入："199100199"
 * 输出：true
 * 解释：累加序列为: 1, 99, 100, 199。1 + 99 = 100, 99 + 100 = 199
 * 提示：
 * 1 <= num.length <= 35
 * num 仅由数字（0 - 9）组成
 * 进阶：你计划如何处理由过大的整数输入导致的溢出?
 */
public class LC306_additive_number {

    public static void main(String[] args) {
        boolean additiveNumber = new LC306_additive_number().isAdditiveNumber("123");
        int i = 1;
    }

    public boolean isAdditiveNumber(String num) {
        for (int i = 1; i <= num.length() / 2; i++) {
            if (num.charAt(0) == '0' && i > 1) {
                break;
            }
            for (int j = i + 1; j <= i + (num.length() - i) / 2; j++) {
                if (num.charAt(i) == '0' && j > i + 1) {
                    break;
                }
                long num1 = Long.parseLong(num.substring(0, i));
                long num2 = Long.parseLong(num.substring(i, j));
                boolean handle = handle(num1, num2, num, j);
                if (handle) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean handle(long num1, long num2, String num, int begin) {
        long l = num1 + num2;
        int length = String.valueOf(l).length();

        int endIndex = begin + length;
        if (endIndex > num.length()) {
            return false;
        }
        long sum = Long.parseLong(num.substring(begin, endIndex));
        if (sum != l) {
            return false;
        }
        if (endIndex == num.length()) {
            return true;
        }
        return handle(num2, sum, num, endIndex);
    }

}
