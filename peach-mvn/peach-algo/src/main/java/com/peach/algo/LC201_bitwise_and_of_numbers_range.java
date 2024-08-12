package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/8/12
 * 给你两个整数 left 和 right ，表示区间 [left, right] ，返回此区间内所有数字 按位与 的结果（包含 left 、right 端点）。
 * 示例 1：
 * 输入：left = 5, right = 7
 * 输出：4
 * 示例 2：
 * 输入：left = 0, right = 0
 * 输出：0
 * 示例 3：
 * 输入：left = 1, right = 2147483647
 * 输出：0
 * 提示：
 * 0 <= left <= right <= 231 - 1
 */
public class LC201_bitwise_and_of_numbers_range {

    public static void main(String[] args) {
        new LC201_bitwise_and_of_numbers_range().rangeBitwiseAnd(1073741824, 2147483647);
    }

    public int rangeBitwiseAnd(int left, int right) {
        if (left == 0) {
            return 0;
        }
        if (left == right) {
            return left;
        }
        if (left + 1 == right) {
            return left & right;
        }
        int begin = 1;
        while (2 * begin <= left && begin < Integer.MAX_VALUE / 2) {
            begin *= 2;
        }
        if (right / 2 >= begin) {
            return 0;
        }
        return begin + rangeBitwiseAnd(left - begin, right - begin);
    }
}
