package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/7/24
 * 给定一个数组，它的第 i 个元素是一支给定的股票在第 i 天的价格。
 * 设计一个算法来计算你所能获取的最大利润。你最多可以完成 两笔 交易。
 * 注意：你不能同时参与多笔交易（你必须在再次购买前出售掉之前的股票）。
 * 示例 1:
 * 输入：prices = [3,3,5,0,0,3,1,4]
 * 输出：6
 * 解释：在第 4 天（股票价格 = 0）的时候买入，在第 6 天（股票价格 = 3）的时候卖出，这笔交易所能获得利润 = 3-0 = 3 。
 * 随后，在第 7 天（股票价格 = 1）的时候买入，在第 8 天 （股票价格 = 4）的时候卖出，这笔交易所能获得利润 = 4-1 = 3 。
 * 示例 2：
 * 输入：prices = [1,2,3,4,5]
 * 输出：4
 * 解释：在第 1 天（股票价格 = 1）的时候买入，在第 5 天 （股票价格 = 5）的时候卖出, 这笔交易所能获得利润 = 5-1 = 4 。
 * 注意你不能在第 1 天和第 2 天接连购买股票，之后再将它们卖出。
 * 因为这样属于同时参与了多笔交易，你必须在再次购买前出售掉之前的股票。
 * 示例 3：
 * 输入：prices = [7,6,4,3,1]
 * 输出：0
 * 解释：在这个情况下, 没有交易完成, 所以最大利润为 0。
 * 示例 4：
 * 输入：prices = [1]
 * 输出：0
 * 提示：
 * 1 <= prices.length <= 105
 * 0 <= prices[i] <= 105
 */
public class LC123_best_time_to_buy_and_sell_stock_iii {

    public int maxProfit1(int[] prices) {
        int max1 = 0;
        int max2 = 0;

        int index = 1;
        int beginIndex;
        int cur;
        while (index < prices.length) {
            if (prices[index] < prices[index - 1]) {
                index++;
            } else {
                beginIndex = index - 1;
                while (index < prices.length && prices[index] >= prices[index - 1]) {
                    index++;
                }
                cur = prices[index - 1] - prices[beginIndex];
                if (cur > max2) {
                    if (cur > max1) {
                        max2 = max1;
                        max1 = cur;
                    } else {
                        max2 = cur;
                    }
                }
                index++;
            }
        }
        return max1 + max2;
    }

    public int maxProfit2(int[] prices) {
        int[] array = new int[prices.length];
        int arrayIndex = 0;

        int index = 1;
        int beginIndex;
        while (index < prices.length) {
            if (prices[index] < prices[index - 1]) {
                beginIndex = index - 1;
                while (index < prices.length && prices[index] < prices[index - 1]) {
                    index++;
                }
                array[arrayIndex++] = prices[index - 1] - prices[beginIndex];
            } else {
                beginIndex = index - 1;
                while (index < prices.length && prices[index] >= prices[index - 1]) {
                    index++;
                }
                array[arrayIndex++] = prices[index - 1] - prices[beginIndex];
            }
        }
        return 1;
    }

    public static void main(String[] args) {
        new LC123_best_time_to_buy_and_sell_stock_iii().maxProfit(new int[]{ 1, 2, 3, 4, 5 });
    }

    //我是傻逼
    //定义在股票买入时k才会自增。可以得到状态转移如下
    //base case：dp[i][0][0]为从头到尾一次交易都没做过，全部初始化为0，dp[0][1][1]=−prices[0]表示第0天买入股票。
    //
    //一般情况：
    //dp[i][k][0]=max(dp[i−1][k][0],dp[i−1][k][1]+prices[i])
    //dp[i][k][1]=max(dp[i−1][k][1],dp[i−1][k−1][0]−prices[i])
    public int maxProfit(int[] prices) {
        int[][][] dp = new int[prices.length][3][2];
        dp[0][1][1] = -prices[0];
        dp[0][2][1] = Integer.MIN_VALUE;
        for (int i = 1; i < prices.length; i++) {
            for (int j = 1; j <= 2; j++) {
                dp[i][j][0] = Math.max(dp[i - 1][j][0], dp[i - 1][j][1] + prices[i]);
                dp[i][j][1] = Math.max(dp[i - 1][j][1], dp[i - 1][j - 1][0] - prices[i]);
            }
        }
        return Math.max(dp[prices.length - 1][1][0], dp[prices.length - 1][2][0]);
    }
}
