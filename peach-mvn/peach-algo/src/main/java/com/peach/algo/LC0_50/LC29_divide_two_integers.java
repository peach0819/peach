package com.peach.algo.LC0_50;

/**
 * @author feitao.zt
 * @date 2024/7/4
 * 给你两个整数，被除数 dividend 和除数 divisor。将两数相除，要求 不使用 乘法、除法和取余运算。
 * 整数除法应该向零截断，也就是截去（truncate）其小数部分。例如，8.345 将被截断为 8 ，-2.7335 将被截断至 -2 。
 * 返回被除数 dividend 除以除数 divisor 得到的 商 。
 * 注意：假设我们的环境只能存储 32 位 有符号整数，其数值范围是 [−231,  231 − 1] 。本题中，如果商 严格大于 231 − 1 ，则返回 231 − 1 ；如果商 严格小于 -231 ，则返回 -231 。
 * 示例 1:
 * 输入: dividend = 10, divisor = 3
 * 输出: 3
 * 解释: 10/3 = 3.33333.. ，向零截断后得到 3 。
 * 示例 2:
 * 输入: dividend = 7, divisor = -3
 * 输出: -2
 * 解释: 7/-3 = -2.33333.. ，向零截断后得到 -2 。
 * 提示：
 * -231 <= dividend, divisor <= 231 - 1
 * divisor != 0
 */
public class LC29_divide_two_integers {

    public static void main(String[] args) {
        new LC29_divide_two_integers().divide(-2147483648, 2);
    }

    /**
     * 二分法 + 递归
     */
    public int divide(int dividend, int divisor) {
        if (dividend == Integer.MIN_VALUE && divisor == -1) {
            return Integer.MAX_VALUE;
        }
        if (dividend == Integer.MIN_VALUE && divisor == 1) {
            return Integer.MIN_VALUE;
        }
        if (dividend > 0) {
            return -divide(-dividend, divisor);
        }
        if (divisor > 0) {
            return -divide(dividend, -divisor);
        }
        if (divisor == -1) {
            return -dividend;
        }
        return baseDivide(dividend, divisor);
    }

    /**
     * 这个时候 两个数都是负的，并且可除, 都是负的是为了防止溢出
     */
    private int baseDivide(int dividend, int divisor) {
        if (divisor < dividend) {
            return 0;
        }
        if (dividend == divisor) {
            return 1;
        }
        int initDivisor = divisor;

        int result = 0;
        int base = 1;
        while (true) {
            if (dividend - divisor < divisor) {
                divisor = divisor + divisor;
                base = base + base;
            } else {
                while (dividend < divisor) {
                    dividend = dividend - divisor;
                    result = result + base;
                }
                break;
            }
        }
        return result + baseDivide(dividend, initDivisor);
    }
}
