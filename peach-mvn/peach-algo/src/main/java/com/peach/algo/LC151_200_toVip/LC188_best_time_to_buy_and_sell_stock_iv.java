package com.peach.algo.LC151_200_toVip;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2024/8/9
 * 给你一个整数数组 prices 和一个整数 k ，其中 prices[i] 是某支给定的股票在第 i 天的价格。
 * 设计一个算法来计算你所能获取的最大利润。你最多可以完成 k 笔交易。也就是说，你最多可以买 k 次，卖 k 次。
 * 注意：你不能同时参与多笔交易（你必须在再次购买前出售掉之前的股票）。
 * 示例 1：
 * 输入：k = 2, prices = [2,4,1]
 * 输出：2
 * 解释：在第 1 天 (股票价格 = 2) 的时候买入，在第 2 天 (股票价格 = 4) 的时候卖出，这笔交易所能获得利润 = 4-2 = 2 。
 * 示例 2：
 * 输入：k = 2, prices = [3,2,6,5,0,3]
 * 输出：7
 * 解释：在第 2 天 (股票价格 = 2) 的时候买入，在第 3 天 (股票价格 = 6) 的时候卖出, 这笔交易所能获得利润 = 6-2 = 4 。
 * 随后，在第 5 天 (股票价格 = 0) 的时候买入，在第 6 天 (股票价格 = 3) 的时候卖出, 这笔交易所能获得利润 = 3-0 = 3 。
 * 提示：
 * 1 <= k <= 100
 * 1 <= prices.length <= 1000
 * 0 <= prices[i] <= 1000
 */
public class LC188_best_time_to_buy_and_sell_stock_iv {

    public static void main(String[] args) {
        new LC188_best_time_to_buy_and_sell_stock_iv().maxProfit(2, new int[]{ 1, 2, 4, 7 });
    }

    /**
     * i = 天数， j = 已经参与的交易数量, m = 手上是否有股票 0否 1是
     * dp[i][j][0] = max(dp[i-1][j][0], dp[i-1][j][1] + price[i])
     * dp[i][j][1] = max(dp[i-1][j][1], dp[i-1][j-1][0] - price[i])
     */
    public int maxProfit(int k, int[] prices) {
        if (prices.length < 2) {
            return 0;
        }
        int[][][] dp = new int[prices.length][k + 1][2];
        for (int[][] ints : dp) {
            for (int i = 1; i < ints.length; i++) {
                Arrays.fill(ints[i], Integer.MIN_VALUE);
            }
        }
        dp[0][1][1] = -prices[0];
        for (int i = 1; i < prices.length; i++) {
            for (int j = 1; j <= k && j <= (i + 2) / 2; j++) {
                dp[i][j][0] = Math.max(dp[i - 1][j][0], dp[i - 1][j][1] + prices[i]);
                dp[i][j][1] = Math.max(dp[i - 1][j][1], dp[i - 1][j - 1][0] - prices[i]);
            }
        }
        int result = 0;
        for (int i = 0; i <= prices.length / 2 && i <= k; i++) {
            result = Math.max(dp[prices.length - 1][i][0], result);
        }
        return result;
    }
}
