package com.peach.algo.LC51_100;

/**
 * @author feitao.zt
 * @date 2024/7/16
 * 给你一个非负整数 x ，计算并返回 x 的 算术平方根 。
 * 由于返回类型是整数，结果只保留 整数部分 ，小数部分将被 舍去 。
 * 注意：不允许使用任何内置指数函数和算符，例如 pow(x, 0.5) 或者 x ** 0.5 。
 * 示例 1：
 * 输入：x = 4
 * 输出：2
 * 示例 2：
 * 输入：x = 8
 * 输出：2
 * 解释：8 的算术平方根是 2.82842..., 由于返回类型是整数，小数部分将被舍去。
 * 提示：
 * 0 <= x <= 231 - 1
 */
public class LC69_sqrtx {

    public static void main(String[] args) {
        new LC69_sqrtx().mySqrt(4);
    }

    public int mySqrt(int x) {
        if (x == 0 || x == 1) {
            return x;
        }
        int length = (String.valueOf(x).length() + 1) / 2;
        int num = 1;
        for (int i = 1; i < length; i++) {
            num *= 10;
        }
        int begin = num;
        int end = Math.min(num * 10, 46341);
        int mid;
        int midVal;
        while (true) {
            if (begin + 1 == end) {
                return begin;
            }
            if (begin * begin == x) {
                return begin;
            }
            if (end * end == x) {
                return end;
            }
            mid = (begin + end) / 2;
            midVal = mid * mid;
            if (midVal == x) {
                return mid;
            } else if (midVal > x) {
                end = mid;
            } else {
                begin = mid;
            }
        }
    }

}
