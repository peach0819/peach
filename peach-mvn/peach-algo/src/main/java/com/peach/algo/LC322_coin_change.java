package com.peach.algo;

import java.util.Arrays;
import java.util.PriorityQueue;

/**
 * @author feitao.zt
 * @date 2024/9/24
 * 给你一个整数数组 coins ，表示不同面额的硬币；以及一个整数 amount ，表示总金额。
 * 计算并返回可以凑成总金额所需的 最少的硬币个数 。如果没有任何一种硬币组合能组成总金额，返回 -1 。
 * 你可以认为每种硬币的数量是无限的。
 * 示例 1：
 * 输入：coins = [1, 2, 5], amount = 11
 * 输出：3
 * 解释：11 = 5 + 5 + 1
 * 示例 2：
 * 输入：coins = [2], amount = 3
 * 输出：-1
 * 示例 3：
 * 输入：coins = [1], amount = 0
 * 输出：0
 * 提示：
 * 1 <= coins.length <= 12
 * 1 <= coins[i] <= 231 - 1
 * 0 <= amount <= 104
 */
public class LC322_coin_change {

    public int coinChange1(int[] coins, int amount) {
        if (amount == 0) {
            return 0;
        }
        Arrays.sort(coins);
        int[] dp = new int[amount + 1];
        Arrays.fill(dp, Integer.MAX_VALUE);
        PriorityQueue<Integer> queue = new PriorityQueue<>();
        for (int coin : coins) {
            if (coin > amount) {
                break;
            }
            dp[coin] = 1;
            queue.offer(coin);
        }
        while (true) {
            if (queue.isEmpty()) {
                return -1;
            }
            int poll = queue.poll();
            if (poll > amount) {
                return -1;
            }
            if (poll == amount) {
                return dp[amount];
            }
            int cur = dp[poll];
            for (int coin : coins) {
                if (coin > amount - poll) {
                    break;
                }
                int next = dp[coin + poll];
                dp[coin + poll] = Math.min(next, cur + 1);
                if (next == Integer.MAX_VALUE) {
                    queue.offer(coin + poll);
                }
            }
        }
    }

    public static void main(String[] args) {
        new LC322_coin_change().coinChange(new int[]{ 1, 2, 5 }, 11);
    }

    public int coinChange(int[] coins, int amount) {
        if (amount == 0) {
            return 0;
        }
        Arrays.sort(coins);
        int[] dp = new int[amount + 1];
        Arrays.fill(dp, -1);
        dp[0] = 0;
        for (int i = 1; i <= amount; i++) {
            int cur = Integer.MAX_VALUE;
            for (int coin : coins) {
                if (coin > i) {
                    break;
                }
                if (dp[i - coin] < 0) {
                    continue;
                }
                cur = Math.min(cur, dp[i - coin] + 1);
            }
            if (cur != Integer.MAX_VALUE) {
                dp[i] = cur;
            }
        }
        return dp[amount];
    }

}
