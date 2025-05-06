package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/5/6
 * 可以用字符串表示，遵循 "实部+虚部i" 的形式，并满足下述条件：
 * 实部 是一个整数，取值范围是 [-100, 100]
 * 虚部 也是一个整数，取值范围是 [-100, 100]
 * i2 == -1
 * 给你两个字符串表示的复数 num1 和 num2 ，请你遵循复数表示形式，返回表示它们乘积的字符串。
 * 示例 1：
 * 输入：num1 = "1+1i", num2 = "1+1i"
 * 输出："0+2i"
 * 解释：(1 + i) * (1 + i) = 1 + i2 + 2 * i = 2i ，你需要将它转换为 0+2i 的形式。
 * 示例 2：
 * 输入：num1 = "1+-1i", num2 = "1+-1i"
 * 输出："0+-2i"
 * 解释：(1 - i) * (1 - i) = 1 + i2 - 2 * i = -2i ，你需要将它转换为 0+-2i 的形式。
 * 提示：
 * num1 和 num2 都是有效的复数表示。
 */
public class LC537_complex_number_multiplication {

    public String complexNumberMultiply(String num1, String num2) {
        String[] strs1 = num1.split("[+]");
        int i1 = Integer.parseInt(strs1[0]);
        int j1 = Integer.parseInt(strs1[1].substring(0, strs1[1].length() - 1));

        String[] strs2 = num2.split("[+]");
        int i2 = Integer.parseInt(strs2[0]);
        int j2 = Integer.parseInt(strs2[1].substring(0, strs2[1].length() - 1));

        return (i1 * i2 - j1 * j2) + "+" + (i1 * j2 + i2 * j1) + "i";
    }
}
