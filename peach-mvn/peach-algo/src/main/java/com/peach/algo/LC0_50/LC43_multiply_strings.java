package com.peach.algo.LC0_50;

/**
 * @author feitao.zt
 * @date 2024/7/10
 * 给定两个以字符串形式表示的非负整数 num1 和 num2，返回 num1 和 num2 的乘积，它们的乘积也表示为字符串形式。
 * 注意：不能使用任何内置的 BigInteger 库或直接将输入转换为整数。
 * 示例 1:
 * 输入: num1 = "2", num2 = "3"
 * 输出: "6"
 * 示例 2:
 * 输入: num1 = "123", num2 = "456"
 * 输出: "56088"
 * 提示：
 * 1 <= num1.length, num2.length <= 200
 * num1 和 num2 只能由数字组成。
 * num1 和 num2 都不包含任何前导零，除了数字0本身。
 */
public class LC43_multiply_strings {

    public static void main(String[] args) {
        new LC43_multiply_strings().multiply("9", "99");
    }

    public String multiply(String num1, String num2) {
        if (num1.equals("0") || num2.equals("0")) {
            return "0";
        }
        if (num1.equals("1")) {
            return num2;
        }
        if (num2.equals("1")) {
            return num1;
        }
        char[] chars1 = num1.toCharArray();
        int length1 = chars1.length;
        char[] chars2 = num2.toCharArray();
        int length2 = chars2.length;
        int addition = 0;
        int cur;
        StringBuilder s = new StringBuilder();
        for (int i = 0; i < num1.length() + num2.length() - 1; i++) {
            cur = 0;
            for (int j = Math.max(0, i - num2.length() + 1); j <= i && j < num1.length(); j++) {
                int val1 = chars1[length1 - 1 - j] - '0';
                int val2 = chars2[length2 - 1 - i + j] - '0';
                cur += (val1 * val2);
            }
            cur += addition;
            s.append(cur % 10);
            addition = cur / 10;
        }
        if (addition != 0) {
            s.append(addition);
        }
        return s.reverse().toString();
    }
}
