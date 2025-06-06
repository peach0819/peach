package com.peach.algo.LC501_550_toVip;

import java.util.Random;

/**
 * @author feitao.zt
 * @date 2025/3/27
 * 给你一个 下标从 0 开始 的正整数数组 w ，其中 w[i] 代表第 i 个下标的权重。
 * 请你实现一个函数 pickIndex ，它可以 随机地 从范围 [0, w.length - 1] 内（含 0 和 w.length - 1）选出并返回一个下标。选取下标 i 的 概率 为 w[i] / sum(w) 。
 * 例如，对于 w = [1, 3]，挑选下标 0 的概率为 1 / (1 + 3) = 0.25 （即，25%），而选取下标 1 的概率为 3 / (1 + 3) = 0.75（即，75%）。
 * 示例 1：
 * 输入：
 * ["Solution","pickIndex"]
 * [[[1]],[]]
 * 输出：
 * [null,0]
 * 解释：
 * Solution solution = new Solution([1]);
 * solution.pickIndex(); // 返回 0，因为数组中只有一个元素，所以唯一的选择是返回下标 0。
 * 示例 2：
 * 输入：
 * ["Solution","pickIndex","pickIndex","pickIndex","pickIndex","pickIndex"]
 * [[[1,3]],[],[],[],[],[]]
 * 输出：
 * [null,1,1,1,1,0]
 * 解释：
 * Solution solution = new Solution([1, 3]);
 * solution.pickIndex(); // 返回 1，返回下标 1，返回该下标概率为 3/4 。
 * solution.pickIndex(); // 返回 1
 * solution.pickIndex(); // 返回 1
 * solution.pickIndex(); // 返回 1
 * solution.pickIndex(); // 返回 0，返回下标 0，返回该下标概率为 1/4 。
 * 由于这是一个随机问题，允许多个答案，因此下列输出都可以被认为是正确的:
 * [null,1,1,1,1,0]
 * [null,1,1,1,1,1]
 * [null,1,1,1,0,0]
 * [null,1,1,1,0,1]
 * [null,1,0,1,0,0]
 * ......
 * 诸若此类。
 * 提示：
 * 1 <= w.length <= 104
 * 1 <= w[i] <= 105
 * pickIndex 将被调用不超过 104 次
 */
public class LC528_random_pick_with_weight {

    /**
     * Your Solution object will be instantiated and called as such:
     * Solution obj = new Solution(w);
     * int param_1 = obj.pickIndex();
     */
    class Solution {

        private int[][] pre;

        private int sum = 0;

        private Random random = new Random();

        public Solution(int[] w) {
            pre = new int[w.length][2];
            for (int i = 0; i < w.length; i++) {
                pre[i] = new int[]{ sum, sum + w[i] - 1 };
                sum += w[i];
            }
        }

        public int pickIndex() {
            int i = random.nextInt(sum);
            return binarySearch(0, pre.length - 1, i);
        }

        private int binarySearch(int begin, int end, int target) {
            if (begin == end) {
                return begin;
            }
            int mid = (begin + end) / 2;
            if (pre[mid][0] <= target && target <= pre[mid][1]) {
                return mid;
            }
            if (pre[mid][0] > target) {
                return binarySearch(begin, mid, target);
            } else {
                return binarySearch(mid + 1, end, target);
            }
        }
    }

}
