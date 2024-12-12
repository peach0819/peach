package com.peach.algo.LC401_450_toVip;

/**
 * @author feitao.zt
 * @date 2024/10/23
 * 给定一个整数，编写一个算法将这个数转换为十六进制数。对于负整数，我们通常使用 补码运算 方法。
 * 答案字符串中的所有字母都应该是小写字符，并且除了 0 本身之外，答案中不应该有任何前置零。
 * 注意: 不允许使用任何由库提供的将数字直接转换或格式化为十六进制的方法来解决这个问题。
 * 示例 1：
 * 输入：num = 26
 * 输出："1a"
 * 示例 2：
 * 输入：num = -1
 * 输出："ffffffff"
 * 提示：
 * -231 <= num <= 231 - 1
 */
public class LC405_convert_a_number_to_hexadecimal {

    public static void main(String[] args) {
        new LC405_convert_a_number_to_hexadecimal().toHex(-1);
    }

    public String toHex(int num) {
        if (num == 0) {
            return "0";
        }
        StringBuilder sb = new StringBuilder();
        int temp;
        boolean start = false;
        for (int i = 0; i < 8; i++) {
            temp = num >> (7 - i) * 4;
            if (temp != 0 || start) {
                sb.append(convert(temp));
                start = true;
            }
            num -= temp << (7 - i) * 4;
        }
        return sb.toString();
    }

    private char convert(int num) {
        if (num < 0) {
            return convert(num + 16);
        }
        if (num <= 9) {
            return (char) ('0' + num);
        }
        return (char) ('a' + (num - 10));
    }

}
