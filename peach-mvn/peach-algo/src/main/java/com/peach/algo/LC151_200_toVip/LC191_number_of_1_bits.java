package com.peach.algo.LC151_200_toVip;

/**
 * @author feitao.zt
 * @date 2024/8/12
 * 编写一个函数，获取一个正整数的二进制形式并返回其二进制表达式中
 * 设置位
 * 的个数（也被称为汉明重量）。
 * 示例 1：
 * 输入：n = 11
 * 输出：3
 * 解释：输入的二进制串 1011 中，共有 3 个设置位。
 * 示例 2：
 * 输入：n = 128
 * 输出：1
 * 解释：输入的二进制串 10000000 中，共有 1 个设置位。
 * 示例 3：
 * 输入：n = 2147483645
 * 输出：30
 * 解释：输入的二进制串 11111111111111111111111111111101 中，共有 30 个设置位。
 * 提示：
 * 1 <= n <= 231 - 1
 * 进阶：
 * 如果多次调用这个函数，你将如何优化你的算法？
 */
public class LC191_number_of_1_bits {

    public int hammingWeight(int n) {
        int result = 0;
        while (true) {
            if ((n & 1) == 1) {
                result++;
            }
            n = n >> 1;
            if (n == 0) {
                break;
            }
        }
        return result;
    }
}
