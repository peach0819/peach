package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/9/6
 * 给定一个整数 n，计算所有小于等于 n 的非负整数中数字 1 出现的个数。
 * 示例 1：
 * 输入：n = 13
 * 输出：6
 * 示例 2：
 * 输入：n = 0
 * 输出：0
 * 提示：
 * 0 <= n <= 109
 */
public class LC233_number_of_digit_one {

    public static void main(String[] args) {
        int i1 = new LC233_number_of_digit_one().countDigitOne(13);
        //int i2 = new LC233_number_of_digit_one().countDigitOne(21);
        int i = 1;
    }

    public int countDigitOne(int n) {
        if (n == 0) {
            return 0;
        }
        if (n < 10) {
            return 1;
        }
        int result = 0;
        long begin = 1;
        while (true) {
            long curVal = n / (begin * 10);
            if (curVal > 0) {
                result += curVal * begin;
            }
            long curN = n - curVal * (begin * 10);
            long curMode = curN / begin;
            if (curMode > 1) {
                result += begin;
            } else if (curMode == 1) {
                result += (curN - begin + 1);
            }
            if (curVal == 0) {
                break;
            }
            begin *= 10;
        }
        return result;
    }

}
