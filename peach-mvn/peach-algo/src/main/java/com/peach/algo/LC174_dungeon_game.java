package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/8/8
 * 恶魔们抓住了公主并将她关在了地下城 dungeon 的 右下角 。地下城是由 m x n 个房间组成的二维网格。我们英勇的骑士最初被安置在 左上角 的房间里，他必须穿过地下城并通过对抗恶魔来拯救公主。
 * 骑士的初始健康点数为一个正整数。如果他的健康点数在某一时刻降至 0 或以下，他会立即死亡。
 * 有些房间由恶魔守卫，因此骑士在进入这些房间时会失去健康点数（若房间里的值为负整数，则表示骑士将损失健康点数）；其他房间要么是空的（房间里的值为 0），要么包含增加骑士健康点数的魔法球（若房间里的值为正整数，则表示骑士将增加健康点数）。
 * 为了尽快解救公主，骑士决定每次只 向右 或 向下 移动一步。
 * 返回确保骑士能够拯救到公主所需的最低初始健康点数。
 * 注意：任何房间都可能对骑士的健康点数造成威胁，也可能增加骑士的健康点数，包括骑士进入的左上角房间以及公主被监禁的右下角房间。
 * 示例 1：
 * 输入：dungeon = [[-2,-3,3],[-5,-10,1],[10,30,-5]]
 * 输出：7
 * 解释：如果骑士遵循最佳路径：右 -> 右 -> 下 -> 下 ，则骑士的初始健康点数至少为 7 。
 * 示例 2：
 * 输入：dungeon = [[0]]
 * 输出：1
 * 提示：
 * m == dungeon.length
 * n == dungeon[i].length
 * 1 <= m, n <= 200
 * -1000 <= dungeon[i][j] <= 1000
 */
public class LC174_dungeon_game {

    //我是傻逼, 正向是无解的，只能反过来，从右下往坐上
    public int calculateMinimumHP1(int[][] dungeon) {
        int[][] dp = new int[dungeon.length][dungeon[0].length];
        int[][] min = new int[dungeon.length][dungeon[0].length];

        dp[0][0] = dungeon[0][0];
        min[0][0] = dungeon[0][0];
        for (int i = 1; i < dungeon.length; i++) {
            dp[i][0] = dp[i - 1][0] + dungeon[i][0];
            min[i][0] = Math.min(min[i - 1][0], dp[i][0]);
        }

        for (int i = 1; i < dungeon[0].length; i++) {
            dp[0][i] = dp[0][i - 1] + dungeon[0][i];
            min[0][i] = Math.min(min[0][i - 1], dp[0][i]);
        }

        for (int i = 1; i < dungeon.length; i++) {
            for (int j = 1; j < dungeon[0].length; j++) {
                int cur = dungeon[i][j];
                dp[i][j] = Math.max(dp[i - 1][j], dp[i][j - 1]) + cur;
                if (cur >= 0) {
                    min[i][j] = Math.max(min[i - 1][j], min[i][j - 1]);
                } else {
                    min[i][j] = Math.max(
                            Math.min(min[i - 1][j], dp[i - 1][j] + cur),
                            Math.min(min[i][j - 1], dp[i][j - 1] + cur)
                    );
                }
            }
        }
        int result = min[dungeon.length - 1][dungeon[0].length - 1];
        if (result >= 0) {
            return 1;
        }
        return 1 - result;
    }

    public static void main(String[] args) {
        //1  -4  5  -99
        //2  -2 -2  -1
        new LC174_dungeon_game().calculateMinimumHP(new int[][]{ { 0, 0 } });
    }

    public int calculateMinimumHP(int[][] dungeon) {
        int m = dungeon.length;
        int n = dungeon[0].length;
        int[][] dp = new int[m][n];
        dp[m - 1][n - 1] = Math.max(1, 1 - dungeon[m - 1][n - 1]);
        for (int i = m - 2; i >= 0; i--) {
            int cur = dp[i + 1][n - 1] - dungeon[i][n - 1];
            dp[i][n - 1] = Math.max(1, cur);
        }
        for (int i = n - 2; i >= 0; i--) {
            int cur = dp[m - 1][i + 1] - dungeon[m - 1][i];
            dp[m - 1][i] = Math.max(1, cur);
        }
        for (int i = m - 2; i >= 0; i--) {
            for (int j = n - 2; j >= 0; j--) {
                int cur = Math.min(dp[i][j + 1], dp[i + 1][j]) - dungeon[i][j];
                dp[i][j] = Math.max(1, cur);
            }
        }
        return dp[0][0];
    }
}
