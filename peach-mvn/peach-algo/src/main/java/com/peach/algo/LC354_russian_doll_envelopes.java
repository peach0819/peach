package com.peach.algo;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2024/10/10
 * 给你一个二维整数数组 envelopes ，其中 envelopes[i] = [wi, hi] ，表示第 i 个信封的宽度和高度。
 * 当另一个信封的宽度和高度都比这个信封大的时候，这个信封就可以放进另一个信封里，如同俄罗斯套娃一样。
 * 请计算 最多能有多少个 信封能组成一组“俄罗斯套娃”信封（即可以把一个信封放到另一个信封里面）。
 * 注意：不允许旋转信封。
 * 示例 1：
 * 输入：envelopes = [[5,4],[6,4],[6,7],[2,3]]
 * 输出：3
 * 解释：最多信封的个数为 3, 组合为: [2,3] => [5,4] => [6,7]。
 * 示例 2：
 * 输入：envelopes = [[1,1],[1,1],[1,1]]
 * 输出：1
 * 提示：
 * 1 <= envelopes.length <= 105
 * envelopes[i].length == 2
 * 1 <= wi, hi <= 105
 */
public class LC354_russian_doll_envelopes {

    /**
     * 我是傻逼
     * 这个题解太吊了
     * LIS问题变种，参考LC300
     * 先对宽度 w 进行升序排序，如果遇到 w 相同的情况，则按照高度 h 降序排序。之后把所有的 h 作为一个数组，在这个数组上计算 LIS 的长度就是答案。
     * 这个解法的关键在于，对于宽度 w 相同的数对，要对其高度 h 进行降序排序。因为两个宽度相同的信封不能相互包含的，逆序排序保证在 w 相同的数对中最多只选取一个。
     * https://leetcode.cn/problems/russian-doll-envelopes/solutions/19681/zui-chang-di-zeng-zi-xu-lie-kuo-zhan-dao-er-wei-er/
     */
    public int maxEnvelopes(int[][] envelopes) {
        Arrays.sort(envelopes, (o1, o2) -> {
            if (o1[0] != o2[0]) {
                return o1[0] - o2[0];
            }
            return o2[1] - o1[1];
        });
        int[] dp = new int[envelopes.length];
        dp[0] = 1;
        int max = 1;
        for (int i = 1; i < envelopes.length; i++) {
            int cur = 1;
            for (int j = 0; j < i; j++) {
                if (envelopes[i][1] > envelopes[j][1]) {
                    cur = Math.max(cur, dp[j] + 1);
                }
            }
            dp[i] = cur;
            max = Math.max(max, cur);
        }
        return max;
    }
}
