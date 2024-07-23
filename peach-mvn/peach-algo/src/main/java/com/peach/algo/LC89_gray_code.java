package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/22
 * n 位格雷码序列 是一个由 2n 个整数组成的序列，其中：
 * 每个整数都在范围 [0, 2n - 1] 内（含 0 和 2n - 1）
 * 第一个整数是 0
 * 一个整数在序列中出现 不超过一次
 * 每对 相邻 整数的二进制表示 恰好一位不同 ，且
 * 第一个 和 最后一个 整数的二进制表示 恰好一位不同
 * 给你一个整数 n ，返回任一有效的 n 位格雷码序列 。
 * 示例 1：
 * 输入：n = 2
 * 输出：[0,1,3,2]
 * 解释：
 * [0,1,3,2] 的二进制表示是 [00,01,11,10] 。
 * - 00 和 01 有一位不同
 * - 01 和 11 有一位不同
 * - 11 和 10 有一位不同
 * - 10 和 00 有一位不同
 * [0,2,3,1] 也是一个有效的格雷码序列，其二进制表示是 [00,10,11,01] 。
 * - 00 和 10 有一位不同
 * - 10 和 11 有一位不同
 * - 11 和 01 有一位不同
 * - 01 和 00 有一位不同
 * 示例 2：
 * 输入：n = 1
 * 输出：[0,1]
 * 提示：
 * 1 <= n <= 16
 */
public class LC89_gray_code {

    public static void main(String[] args) {
        new LC89_gray_code().grayCode(2);
    }

    /**
     * 0 +1
     * 0
     * 1
     * 0 +1 +2 -1
     * 00
     * 01
     * 11
     * 10
     * 0 +1 +2 -1 +4 +1 -2 -1
     * 000
     * 001
     * 011
     * 010
     * 110
     * 111
     * 101
     * 100
     * 0 +1 +2  -1 +4  +1 -2 -1 +8  +1 +2 -1 -4 +1 -2 -1
     * 0000
     * 0001
     * 0011
     * 0010
     * 0110
     * 0111
     * 0101
     * 0100
     * 1100
     * 1101
     * 1111
     * 1110
     * 1010
     * 1011
     * 1001
     * 1000
     * n = 2
     * 0 1 3 2
     */
    public List<Integer> grayCode(int n) {
        if (n == 1) {
            List<Integer> list = new ArrayList<>();
            list.add(0);
            list.add(1);
            return list;
        }
        int length = 1;
        for (int i = 0; i < n; i++) {
            length *= 2;
        }
        int[] list = new int[length];
        list[0] = 0;
        list[1] = 1;

        int max = 2;
        int index = 2;
        int cur = 1;
        while (true) {
            if (index == max) {
                if (cur == n) {
                    break;
                }
                list[index] = max;
                max *= 2;
                cur++;
            } else {
                list[index] = -list[max - index];
            }
            index++;
        }
        List<Integer> result = new ArrayList<>();
        int num = 0;
        for (int integer : list) {
            num += integer;
            result.add(num);
        }
        return result;
    }
}
