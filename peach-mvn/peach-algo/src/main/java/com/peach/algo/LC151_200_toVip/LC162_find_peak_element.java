package com.peach.algo.LC151_200_toVip;

/**
 * @author feitao.zt
 * @date 2024/8/7
 * 峰值元素是指其值严格大于左右相邻值的元素。
 * 给你一个整数数组 nums，找到峰值元素并返回其索引。数组可能包含多个峰值，在这种情况下，返回 任何一个峰值 所在位置即可。
 * 你可以假设 nums[-1] = nums[n] = -∞ 。
 * 你必须实现时间复杂度为 O(log n) 的算法来解决此问题。
 * 示例 1：
 * 输入：nums = [1,2,3,1]
 * 输出：2
 * 解释：3 是峰值元素，你的函数应该返回其索引 2。
 * 示例 2：
 * 输入：nums = [1,2,1,3,5,6,4]
 * 输出：1 或 5
 * 解释：你的函数可以返回索引 1，其峰值元素为 2；
 * 或者返回索引 5， 其峰值元素为 6。
 * 提示：
 * 1 <= nums.length <= 1000
 * -231 <= nums[i] <= 231 - 1
 * 对于所有有效的 i 都有 nums[i] != nums[i + 1]
 */
public class LC162_find_peak_element {

    public static void main(String[] args) {
        new LC162_find_peak_element().findPeakElement(new int[]{ 1, 2 });
    }

    int[] nums;

    public int findPeakElement(int[] nums) {
        if (nums.length == 1) {
            return 0;
        }
        this.nums = nums;
        return handle(0, nums.length - 1);
    }

    private int handle(int begin, int end) {
        if (begin == end || begin + 1 == end) {
            if (valid(begin)) {
                return begin;
            }
            if (valid(end)) {
                return end;
            }
            return 0;
        }
        int mid = (begin + end) / 2;
        if (valid(mid)) {
            return mid;
        }
        int handleLeft = handle(begin, mid);
        if (handleLeft > 0) {
            return handleLeft;
        }
        return handle(mid, end);
    }

    private boolean valid(int index) {
        if (index == 0) {
            return nums[0] > nums[1];
        }
        if (index == nums.length - 1) {
            return nums[index] > nums[index - 1];
        }
        return nums[index] > nums[index - 1] && nums[index] > nums[index + 1];
    }

}
