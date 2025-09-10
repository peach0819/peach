package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/9/10
 * 对于一个整数数组 nums，逆序对是一对满足 0 <= i < j < nums.length 且 nums[i] > nums[j]的整数对 [i, j] 。
 * 给你两个整数 n 和 k，找出所有包含从 1 到 n 的数字，且恰好拥有 k 个 逆序对 的不同的数组的个数。由于答案可能很大，只需要返回对 109 + 7 取余的结果。
 * 示例 1：
 * 输入：n = 3, k = 0
 * 输出：1
 * 解释：
 * 只有数组 [1,2,3] 包含了从1到3的整数并且正好拥有 0 个逆序对。
 * 示例 2：
 * 输入：n = 3, k = 1
 * 输出：2
 * 解释：
 * 数组 [1,3,2] 和 [2,1,3] 都有 1 个逆序对。
 * 提示：
 * 1 <= n <= 1000
 * 0 <= k <= 1000
 */
public class LC629_k_inverse_pairs_array {

    /**
     * 我是傻逼
     */
    public int kInversePairs(int n, int k) {
        final int MOD = 1000000007;
        int[][] f = new int[2][k + 1];
        f[0][0] = 1;
        for (int i = 1; i <= n; ++i) {
            for (int j = 0; j <= k; ++j) {
                int cur = i & 1, prev = cur ^ 1;
                f[cur][j] = (j - 1 >= 0 ? f[cur][j - 1] : 0) - (j - i >= 0 ? f[prev][j - i] : 0) + f[prev][j];
                if (f[cur][j] >= MOD) {
                    f[cur][j] -= MOD;
                } else if (f[cur][j] < 0) {
                    f[cur][j] += MOD;
                }
            }
        }
        return f[n & 1][k];
    }

}
