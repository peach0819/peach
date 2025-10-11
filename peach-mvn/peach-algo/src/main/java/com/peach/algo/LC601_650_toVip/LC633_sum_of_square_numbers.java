package com.peach.algo.LC601_650_toVip;

/**
 * @author feitao.zt
 * @date 2025/9/11
 * 给定一个非负整数 c ，你要判断是否存在两个整数 a 和 b，使得 a2 + b2 = c 。
 * 示例 1：
 * 输入：c = 5
 * 输出：true
 * 解释：1 * 1 + 2 * 2 = 5
 * 示例 2：
 * 输入：c = 3
 * 输出：false
 * 提示：
 * 0 <= c <= 231 - 1
 */
public class LC633_sum_of_square_numbers {

    public boolean judgeSquareSum(int c) {
        if (c % 4 == 3) {
            return false;
        }
        int sqrt = (int) Math.sqrt(c / 2);
        for (int i = 0; i <= sqrt; i++) {
            if (isSquare(c - i * i)) {
                return true;
            }
        }
        return false;
    }

    private boolean isSquare(int n) {
        int sqrt = (int) Math.sqrt(n);
        return sqrt * sqrt == n;
    }
}
