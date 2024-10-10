package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/10/10
 * 给你两个整数 a 和 b ，不使用 运算符 + 和 - ​​​​​​​，计算并返回两整数之和。
 * 示例 1：
 * 输入：a = 1, b = 2
 * 输出：3
 * 示例 2：
 * 输入：a = 2, b = 3
 * 输出：5
 * 提示：
 * -1000 <= a, b <= 1000
 */
public class LC371_sum_of_two_integers {

    /**
     * 我是傻逼
     */
    public int getSum(int a, int b) {
        while (b != 0) {
            int carry = (a & b) << 1;
            a = a ^ b;
            b = carry;
        }
        return a;
    }

}
