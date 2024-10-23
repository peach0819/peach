package com.peach.algo.LC351_400_toVip;

/**
 * @author feitao.zt
 * @date 2024/10/22
 * 给你一个整数 n ，请你在无限的整数序列 [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, ...] 中找出并返回第 n 位上的数字。
 * 示例 1：
 * 输入：n = 3
 * 输出：3
 * 示例 2：
 * 输入：n = 11
 * 输出：0
 * 解释：第 11 位数字在序列 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, ... 里是 0 ，它是 10 的一部分。
 * 提示：
 * 1 <= n <= 231 - 1
 */
public class LC400_nth_digit {

    public static void main(String[] args) {
        int nthDigit = new LC400_nth_digit().findNthDigit(1000000000);
    }

    public int findNthDigit(int n) {
        if (n <= 9) {
            return n;
        }
        int index = 10;
        int i = 2;
        int next = 100;
        n = n - 9;
        while (n / i > (next - index)) {
            n = n - i * (next - index);
            index *= 10;
            i++;
            if (next > Integer.MAX_VALUE / 10) {
                break;
            } else {
                next *= 10;
            }
        }
        int resultNum = n / i + index;
        return getNum(resultNum, n % i, i);
    }

    private int getNum(int num, int mod, int i) {
        if (mod == 0) {
            return (num - 1) % 10;
        }
        int divide = 1;
        for (int j = 0; j < (i - mod); j++) {
            divide *= 10;
        }
        return (num % (divide * 10)) / divide;
    }
}
