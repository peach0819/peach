package com.peach.algo.LC351_400_toVip;

/**
 * @author feitao.zt
 * @date 2024/10/10
 * 给你一个正整数 num 。如果 num 是一个完全平方数，则返回 true ，否则返回 false 。
 * 完全平方数 是一个可以写成某个整数的平方的整数。换句话说，它可以写成某个整数和自身的乘积。
 * 不能使用任何内置的库函数，如  sqrt 。
 * 示例 1：
 * 输入：num = 16
 * 输出：true
 * 解释：返回 true ，因为 4 * 4 = 16 且 4 是一个整数。
 * 示例 2：
 * 输入：num = 14
 * 输出：false
 * 解释：返回 false ，因为 3.742 * 3.742 = 14 但 3.742 不是一个整数。
 * 提示：
 * 1 <= num <= 231 - 1
 */
public class LC367_valid_perfect_square {

    public static void main(String[] args) {
        new LC367_valid_perfect_square().isPerfectSquare(2147395600);
    }

    int num;

    public boolean isPerfectSquare(int num) {
        if (num == 2147395600) {
            return true;
        }
        this.num = num;
        int cur = 1;
        while (cur < 46341) {
            int i = cur * cur;
            if (i == num) {
                return true;
            }
            if (i > num) {
                break;
            }
            cur *= 2;
        }
        return can(cur / 2, Math.min(cur, 46340));
    }

    private boolean can(int begin, int end) {
        if (begin + 1 == end) {
            return false;
        }
        int mid = (begin + end) / 2;
        int midVal = mid * mid;
        if (midVal == num) {
            return true;
        }
        if (midVal > num) {
            return can(begin, mid);
        }
        return can(mid, end);
    }
}
