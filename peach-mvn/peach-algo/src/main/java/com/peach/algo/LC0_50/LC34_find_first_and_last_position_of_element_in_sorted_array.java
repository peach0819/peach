package com.peach.algo.LC0_50;

/**
 * @author feitao.zt
 * @date 2024/7/8
 * 给你一个按照非递减顺序排列的整数数组 nums，和一个目标值 target。请你找出给定目标值在数组中的开始位置和结束位置。
 * 如果数组中不存在目标值 target，返回 [-1, -1]。
 * 你必须设计并实现时间复杂度为 O(log n) 的算法解决此问题。
 * 示例 1：
 * 输入：nums = [5,7,7,8,8,10], target = 8
 * 输出：[3,4]
 * 示例 2：
 * 输入：nums = [5,7,7,8,8,10], target = 6
 * 输出：[-1,-1]
 * 示例 3：
 * 输入：nums = [], target = 0
 * 输出：[-1,-1]
 * 提示：
 * 0 <= nums.length <= 105
 * -109 <= nums[i] <= 109
 * nums 是一个非递减数组
 * -109 <= target <= 109
 */
public class LC34_find_first_and_last_position_of_element_in_sorted_array {

    public static void main(String[] args) {
        new LC34_find_first_and_last_position_of_element_in_sorted_array().searchRange(new int[]{ 2, 2 }, 2);
    }

    int[] nums;
    int target;

    public int[] searchRange(int[] nums, int target) {
        if (nums.length == 0) {
            return new int[]{ -1, -1 };
        }
        if (nums.length == 1) {
            return nums[0] == target ? new int[]{ 0, 0 } : new int[]{ -1, -1 };
        }
        this.nums = nums;
        this.target = target;
        return handle(0, nums.length - 1);
    }

    private int[] handle(int begin, int end) {
        int beginVal = nums[begin];
        int endVal = nums[end];
        if (beginVal == target) {
            return result(begin);
        }
        if (endVal == target) {
            return result(end);
        }
        if (begin + 1 == end) {
            return new int[]{ -1, -1 };
        }
        int mid = (begin + end) / 2;
        int midVal = nums[mid];
        if (midVal == target) {
            return result(mid);
        }
        if (midVal > target) {
            return handle(begin, mid);
        } else {
            return handle(mid, end);
        }
    }

    private int[] result(int index) {
        int begin = index;
        int end = index;
        while (begin > 0 && nums[begin - 1] == target) {
            begin--;
        }
        while (end < nums.length - 1 && nums[end + 1] == target) {
            end++;
        }
        return new int[]{ begin, end };
    }
}
