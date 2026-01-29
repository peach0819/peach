package com.peach.algo.LC651_700_toVip;

/**
 * @author feitao.zt
 * @date 2026/1/27
 * 给定一个正整数，检查它的二进制表示是否总是 0、1 交替出现：换句话说，就是二进制表示中相邻两位的数字永不相同。
 * 示例 1：
 * 输入：n = 5
 * 输出：true
 * 解释：5 的二进制表示是：101
 * 示例 2：
 * 输入：n = 7
 * 输出：false
 * 解释：7 的二进制表示是：111.
 * 示例 3：
 * 输入：n = 11
 * 输出：false
 * 解释：11 的二进制表示是：1011.
 * 提示：
 * 1 <= n <= 231 - 1
 */
public class LC693_binary_number_with_alternating_bits {

    public boolean hasAlternatingBits(int n) {
        boolean flag = (n & 1) == 1;
        n = n >> 1;
        while (n != 0) {
            boolean curFlag = (n & 1) == 1;
            if (curFlag == flag) {
                return false;
            }
            flag = curFlag;
            n = n >> 1;
        }
        return true;
    }
}
