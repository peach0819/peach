package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2026/2/3
 * 给你一个整数数组 nums 和一个整数 k ，请你返回子数组内所有元素的乘积严格小于 k 的连续子数组的数目。
 * 示例 1：
 * 输入：nums = [10,5,2,6], k = 100
 * 输出：8
 * 解释：8 个乘积小于 100 的子数组分别为：[10]、[5]、[2]、[6]、[10,5]、[5,2]、[2,6]、[5,2,6]。
 * 需要注意的是 [10,5,2] 并不是乘积小于 100 的子数组。
 * 示例 2：
 * 输入：nums = [1,2,3], k = 0
 * 输出：0
 * 提示:
 * 1 <= nums.length <= 3 * 104
 * 1 <= nums[i] <= 1000
 * 0 <= k <= 106
 */
public class LC713_subarray_product_less_than_k {

    public int numSubarrayProductLessThanK(int[] nums, int k) {
        int result = 0;

        int curIndex = 0;
        int curMultiResult = 1;

        for (int i = 0; i < nums.length; i++) {
            int num = nums[i];
            if (num >= k) {
                curIndex = i + 1;
                curMultiResult = 1;
                continue;
            }
            curMultiResult *= num;
            while (curMultiResult >= k) {
                curMultiResult /= nums[curIndex];
                curIndex++;
            }
            result += i - curIndex + 1;
        }
        return result;
    }

}
