package com.peach.algo.LC0_50;

/**
 * @author feitao.zt
 * @date 2024/7/8
 * 给定一个排序数组和一个目标值，在数组中找到目标值，并返回其索引。如果目标值不存在于数组中，返回它将会被按顺序插入的位置。
 * 请必须使用时间复杂度为 O(log n) 的算法。
 * 示例 1:
 * 输入: nums = [1,3,5,6], target = 5
 * 输出: 2
 * 示例 2:
 * 输入: nums = [1,3,5,6], target = 2
 * 输出: 1
 * 示例 3:
 * 输入: nums = [1,3,5,6], target = 7
 * 输出: 4
 * 提示:
 * 1 <= nums.length <= 104
 * -104 <= nums[i] <= 104
 * nums 为 无重复元素 的 升序 排列数组
 * -104 <= target <= 104
 */
public class LC35_search_insert_position {

    public static void main(String[] args) {
        new LC35_search_insert_position().searchInsert(new int[]{ 1, 3, 5, 6 }, 2);
    }

    public int searchInsert(int[] nums, int target) {
        if (target < nums[0]) {
            return 0;
        }
        if (target > nums[nums.length - 1]) {
            return nums.length;
        }
        return handle(nums, 0, nums.length - 1, target);
    }

    private int handle(int[] nums, int begin, int end, int target) {
        int beginVal = nums[begin];
        int endVal = nums[end];
        if (beginVal == target) {
            return begin;
        }
        if (endVal == target) {
            return end;
        }
        if (begin + 1 == end) {
            return end;
        }
        int mid = (begin + end) / 2;
        int midVal = nums[mid];
        if (midVal == target) {
            return mid;
        }
        if (midVal > target) {
            return handle(nums, begin, mid, target);
        } else {
            return handle(nums, mid, end, target);
        }
    }
}
