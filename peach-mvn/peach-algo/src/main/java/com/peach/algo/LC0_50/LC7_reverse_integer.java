package com.peach.algo.LC0_50;

/**
 * @author feitao.zt
 * @date 2024/6/28
 * 给你一个 32 位的有符号整数 x ，返回将 x 中的数字部分反转后的结果。
 * 如果反转后整数超过 32 位的有符号整数的范围 [−231,  231 − 1] ，就返回 0。
 * 假设环境不允许存储 64 位整数（有符号或无符号）。
 * 示例 1：
 * 输入：x = 123
 * 输出：321
 * 示例 2：
 * 输入：x = -123
 * 输出：-321
 * 示例 3：
 * 输入：x = 120
 * 输出：21
 * 示例 4：
 * 输入：x = 0
 * 输出：0
 * 提示：
 * -231 <= x <= 231 - 1
 */
public class LC7_reverse_integer {

    public int reverse(int x) {
        String compare = x < 0 ? String.valueOf(Integer.MIN_VALUE) : String.valueOf(Integer.MAX_VALUE);
        String result;
        if (x < 0) {
            result = "-" + reverseStr(-x);
        } else {
            result = reverseStr(x);
        }
        if (result.length() < compare.length()) {
            return Integer.parseInt(result);
        }
        if (result.length() > compare.length()) {
            return 0;
        }
        for (int i = 0; i < result.length(); i++) {
            char c1 = result.charAt(i);
            char c2 = compare.charAt(i);
            if (c1 == c2) {
                continue;
            }
            return c1 > c2 ? 0 : Integer.parseInt(result);
        }
        return Integer.parseInt(result);
    }

    private String reverseStr(int x) {
        return reverse(String.valueOf(x));
    }

    private static String reverse(String str) {
        if (str == null) {
            return null;
        }
        char[] chars = str.toCharArray();
        int n = chars.length - 1;
        for (int i = 0; i < chars.length / 2; i++) {
            char temp = chars[i];
            chars[i] = chars[n - i];
            chars[n - i] = temp;
        }
        return new String(chars);
    }
}
