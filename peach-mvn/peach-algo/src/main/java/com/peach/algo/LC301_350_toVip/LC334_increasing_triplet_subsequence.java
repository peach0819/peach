package com.peach.algo.LC301_350_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/30
 * 给你一个整数数组 nums ，判断这个数组中是否存在长度为 3 的递增子序列。
 * 如果存在这样的三元组下标 (i, j, k) 且满足 i < j < k ，使得 nums[i] < nums[j] < nums[k] ，返回 true ；否则，返回 false 。
 * 示例 1：
 * 输入：nums = [1,2,3,4,5]
 * 输出：true
 * 解释：任何 i < j < k 的三元组都满足题意
 * 示例 2：
 * 输入：nums = [5,4,3,2,1]
 * 输出：false
 * 解释：不存在满足题意的三元组
 * 示例 3：
 * 输入：nums = [2,1,5,0,4,6]
 * 输出：true
 * 解释：三元组 (3, 4, 5) 满足题意，因为 nums[3] == 0 < nums[4] == 4 < nums[5] == 6
 * 提示：
 * 1 <= nums.length <= 5 * 105
 * -231 <= nums[i] <= 231 - 1
 * 进阶：你能实现时间复杂度为 O(n) ，空间复杂度为 O(1) 的解决方案吗？
 */
public class LC334_increasing_triplet_subsequence {

    /**
     * 我是傻逼
     * 一共遍历3遍，维护每个数组左边的最小值，右边的最大值
     */
    public boolean increasingTriplet(int[] nums) {
        if (nums.length < 3) {
            return false;
        }
        int[] min = new int[nums.length];
        min[1] = nums[0];
        int[] max = new int[nums.length];
        max[nums.length - 2] = nums[nums.length - 1];
        for (int i = 2; i < nums.length; i++) {
            int cur = nums[i - 1];
            int recur = nums[nums.length - i];
            min[i] = Math.min(cur, min[i - 1]);
            max[nums.length - 1 - i] = Math.max(recur, max[nums.length - i]);
        }
        for (int i = 1; i < nums.length - 1; i++) {
            int cur = nums[i];
            if (cur > min[i] && cur < max[i]) {
                return true;
            }
        }
        return false;
    }
}
