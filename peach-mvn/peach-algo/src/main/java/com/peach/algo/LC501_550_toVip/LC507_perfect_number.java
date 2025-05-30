package com.peach.algo.LC501_550_toVip;

/**
 * @author feitao.zt
 * @date 2025/2/27
 * 对于一个 正整数，如果它和除了它自身以外的所有 正因子 之和相等，我们称它为 「完美数」。
 * 给定一个 整数 n， 如果是完美数，返回 true；否则返回 false。
 * 示例 1：
 * 输入：num = 28
 * 输出：true
 * 解释：28 = 1 + 2 + 4 + 7 + 14
 * 1, 2, 4, 7, 和 14 是 28 的所有正因子。
 * 示例 2：
 * 输入：num = 7
 * 输出：false
 * 提示：
 * 1 <= num <= 108
 */
public class LC507_perfect_number {

    public boolean checkPerfectNumber(int num) {
        if (num == 1) {
            return false;
        }
        int result = 1;
        for (int i = 2; i <= (int) Math.sqrt(num); i++) {
            if (num % i == 0) {
                int divide = num / i;
                result += i;
                if (divide != i) {
                    result += divide;
                }
            }
        }
        return result == num;
    }
}
