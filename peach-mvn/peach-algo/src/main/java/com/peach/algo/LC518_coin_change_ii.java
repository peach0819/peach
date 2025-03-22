package com.peach.algo;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2025/3/5
 * 给你一个整数数组 coins 表示不同面额的硬币，另给一个整数 amount 表示总金额。
 * 请你计算并返回可以凑成总金额的硬币组合数。如果任何硬币组合都无法凑出总金额，返回 0 。
 * 假设每一种面额的硬币有无限个。
 * 题目数据保证结果符合 32 位带符号整数。
 * 示例 1：
 * 输入：amount = 5, coins = [1, 2, 5]
 * 输出：4
 * 解释：有四种方式可以凑成总金额：
 * 5=5
 * 5=2+2+1
 * 5=2+1+1+1
 * 5=1+1+1+1+1
 * 示例 2：
 * 输入：amount = 3, coins = [2]
 * 输出：0
 * 解释：只用面额 2 的硬币不能凑成总金额 3 。
 * 示例 3：
 * 输入：amount = 10, coins = [10]
 * 输出：1
 * 提示：
 * 1 <= coins.length <= 300
 * 1 <= coins[i] <= 5000
 * coins 中的所有值 互不相同
 * 0 <= amount <= 5000
 */
public class LC518_coin_change_ii {

    public static void main(String[] args) {
        int i = new LC518_coin_change_ii().change(500, new int[]{ 1, 2, 5 });
        i = 1;
    }

    /**
     * 官方按照硬币做规划， 就是从1开始先把1全部加完了，在处理2，在处理5
     */
    public int change(int amount, int[] coins) {
        if (amount == 0) {
            return 1;
        }
        Arrays.sort(coins);
        if (amount < coins[0]) {
            return 0;
        }
        int[][] dp = new int[amount + 1][coins.length];
        int[] dp1 = new int[amount + 1];
        //初始化
        for (int i = 0; i < coins.length; i++) {
            int coin = coins[i];
            if (coin > amount) {
                break;
            }
            dp[coin][i] = 1;
            dp1[coin]++;
        }
        for (int cur = 0; cur < amount; cur++) {
            for (int i = 0; i < coins.length; i++) {
                if (dp[cur][i] == 0) {
                    continue;
                }
                int last = dp[cur][i];
                for (int j = i; j < coins.length; j++) {
                    int coin = coins[j];
                    if (cur + coin > amount) {
                        break;
                    }
                    int nextAmount = cur + coin;
                    dp[nextAmount][j] = dp[nextAmount][j] + last;
                    dp1[nextAmount] += last;
                }
            }
        }
        return dp1[amount];
    }
}
