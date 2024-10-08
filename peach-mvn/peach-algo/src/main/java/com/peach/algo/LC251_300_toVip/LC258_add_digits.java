package com.peach.algo.LC251_300_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/10
 * 给定一个非负整数 num，反复将各个位上的数字相加，直到结果为一位数。返回这个结果。
 * 示例 1:
 * 输入: num = 38
 * 输出: 2
 * 解释: 各位相加的过程为：
 * 38 --> 3 + 8 --> 11
 * 11 --> 1 + 1 --> 2
 * 由于 2 是一位数，所以返回 2。
 * 示例 2:
 * 输入: num = 0
 * 输出: 0
 * 提示：
 * 0 <= num <= 231 - 1
 * 进阶：你可以不使用循环或者递归，在 O(1) 时间复杂度内解决这个问题吗？
 */
public class LC258_add_digits {

    /**
     * 我是傻逼
     * x100+y10+z=x99+y9+x+y+z
     */
    public int addDigits(int num) {
        if (num < 9) {
            return num;
        }
        int i = num % 9;
        if (i == 0) {
            return 9;
        }
        return i;
    }
}
