package com.peach.algo.LC451_500_toVip;

/**
 * @author feitao.zt
 * @date 2024/12/18
 * 两个整数之间的 汉明距离 指的是这两个数字对应二进制位不同的位置的数目。
 * 给你两个整数 x 和 y，计算并返回它们之间的汉明距离。
 * 示例 1：
 * 输入：x = 1, y = 4
 * 输出：2
 * 解释：
 * 1   (0 0 0 1)
 * 4   (0 1 0 0)
 * ↑   ↑
 * 上面的箭头指出了对应二进制位不同的位置。
 * 示例 2：
 * 输入：x = 3, y = 1
 * 输出：1
 * 提示：
 * 0 <= x, y <= 231 - 1
 * 注意：本题与 2220. 转换数字的最少位翻转次数 相同。
 */
public class LC461_hamming_distance {

    public static void main(String[] args) {
        new LC461_hamming_distance().hammingDistance(1, 4);
    }

    public int hammingDistance(int x, int y) {
        int result = 0;
        while (x > 0 || y > 0) {
            if (((x & 1) ^ (y & 1)) == 1) {
                result++;
            }
            x = x >> 1;
            y = y >> 1;
        }
        return result;
    }
}
