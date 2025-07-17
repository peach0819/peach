package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/7/16
 * 给你一个整数数组 nums ，你需要找出一个 连续子数组 ，如果对这个子数组进行升序排序，那么整个数组都会变为升序排序。
 * 请你找出符合题意的 最短 子数组，并输出它的长度。
 * 示例 1：
 * 输入：nums = [2,6,4,8,10,9,15]
 * 输出：5
 * 解释：你只需要对 [6, 4, 8, 10, 9] 进行升序排序，那么整个表都会变为升序排序。
 * 示例 2：
 * 输入：nums = [1,2,3,4]
 * 输出：0
 * 示例 3：
 * 输入：nums = [1]
 * 输出：0
 * 提示：
 * 1 <= nums.length <= 104
 * -105 <= nums[i] <= 105
 * 进阶：你可以设计一个时间复杂度为 O(n) 的解决方案吗？
 */
public class LC581_shortest_unsorted_continuous_subarray {

    public static void main(String[] args) {
        int i = new LC581_shortest_unsorted_continuous_subarray().findUnsortedSubarray(
                new int[]{ 3, 2, 5, 1, 4 });
    }

    //4 6 2 8 10 9 15
    public int findUnsortedSubarray(int[] nums) {
        if (nums.length == 1) {
            return 0;
        }
        boolean first = false;
        int minVal = Integer.MIN_VALUE;
        int maxVal = Integer.MIN_VALUE;

        int minIndex = -1;
        int maxIndex = -1;

        for (int i = 1; i < nums.length; i++) {
            if (nums[i] >= nums[i - 1]) {
                if (first) {
                    if (nums[i] >= maxVal) {
                        continue;
                    } else {
                        maxIndex = i;
                    }
                }
            } else {
                if (first) {
                    if (nums[i] >= minVal) {
                        maxIndex = i;
                        maxVal = Math.max(nums[i - 1], maxVal);
                    } else {
                        minIndex = find(nums, minIndex - 1, nums[i]);
                        minVal = nums[i];
                        maxIndex = i;
                        maxVal = Math.max(nums[i - 1], maxVal);
                    }
                } else {
                    maxIndex = i;
                    maxVal = nums[i - 1];
                    minIndex = find(nums, i - 2, nums[i]);
                    minVal = nums[i];
                    first = true;
                }
            }
        }
        return first ? maxIndex - minIndex + 1 : 0;
    }

    private int find(int[] nums, int lastIndex, int val) {
        for (int i = lastIndex; i >= 0; i--) {
            if (nums[i] <= val) {
                return i + 1;
            }
        }
        return 0;
    }
}
