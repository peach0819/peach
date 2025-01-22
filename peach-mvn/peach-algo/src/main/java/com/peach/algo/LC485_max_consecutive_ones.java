package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/1/22
 * 给定一个二进制数组 nums ， 计算其中最大连续 1 的个数。
 * 示例 1：
 * 输入：nums = [1,1,0,1,1,1]
 * 输出：3
 * 解释：开头的两位和最后的三位都是连续 1 ，所以最大连续 1 的个数是 3.
 * 示例 2:
 * 输入：nums = [1,0,1,1,0,1]
 * 输出：2
 * 提示：
 * 1 <= nums.length <= 105
 * nums[i] 不是 0 就是 1.
 */
public class LC485_max_consecutive_ones {

    public int findMaxConsecutiveOnes(int[] nums) {
        int max = 0;
        int index = 0;
        while (index < nums.length) {
            if (nums[index] == 0) {
                index++;
            } else {
                int begin = index;
                while (index < nums.length && nums[index] == 1) {
                    index++;
                }
                max = Math.max(max, index - begin);
            }
        }
        return max;
    }
}
