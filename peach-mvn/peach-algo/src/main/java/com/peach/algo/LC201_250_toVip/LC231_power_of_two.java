package com.peach.algo.LC201_250_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/6
 * 给你一个整数 n，请你判断该整数是否是 2 的幂次方。如果是，返回 true ；否则，返回 false 。
 * 如果存在一个整数 x 使得 n == 2x ，则认为 n 是 2 的幂次方。
 * 示例 1：
 * 输入：n = 1
 * 输出：true
 * 解释：20 = 1
 * 示例 2：
 * 输入：n = 16
 * 输出：true
 * 解释：24 = 16
 * 示例 3：
 * 输入：n = 3
 * 输出：false
 * 提示：
 * -231 <= n <= 231 - 1
 * 进阶：你能够不使用循环/递归解决此问题吗？
 */
public class LC231_power_of_two {

    public boolean isPowerOfTwo(int n) {
        if (n <= 0) {
            return false;
        }
        int i = n & (n - 1);
        return i == 0;
    }

}
