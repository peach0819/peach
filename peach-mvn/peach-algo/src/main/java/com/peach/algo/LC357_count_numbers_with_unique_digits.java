package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/10/10
 * 给你一个整数 n ，统计并返回各位数字都不同的数字 x 的个数，其中 0 <= x < 10n 。
 * 示例 1：
 * 输入：n = 2
 * 输出：91
 * 解释：答案应为除去 11、22、33、44、55、66、77、88、99 外，在 0 ≤ x < 100 范围内的所有数字。
 * 示例 2：
 * 输入：n = 0
 * 输出：1
 * 提示：
 * 0 <= n <= 8
 */
public class LC357_count_numbers_with_unique_digits {

    public int countNumbersWithUniqueDigits(int n) {
        //0 1
        //1-9  9
        //10-99 9*9 81
        //100-999 9*9*8
        if (n == 0) {
            return 1;
        }
        if (n == 1) {
            return 10;
        }
        int result = 10;
        int index = 9;
        int temp = 9;
        for (int i = 2; i <= n; i++) {
            temp *= index;
            result += temp;
            index--;
        }
        return result;
    }
}
