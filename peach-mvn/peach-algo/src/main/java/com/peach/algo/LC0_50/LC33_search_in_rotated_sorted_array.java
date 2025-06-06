package com.peach.algo.LC0_50;

/**
 * @author feitao.zt
 * @date 2024/7/8
 * 整数数组 nums 按升序排列，数组中的值 互不相同 。
 * 在传递给函数之前，nums 在预先未知的某个下标 k（0 <= k < nums.length）上进行了 旋转，使数组变为 [nums[k], nums[k+1], ..., nums[n-1], nums[0], nums[1], ..., nums[k-1]]（下标 从 0 开始 计数）。例如， [0,1,2,4,5,6,7] 在下标 3 处经旋转后可能变为 [4,5,6,7,0,1,2] 。
 * 给你 旋转后 的数组 nums 和一个整数 target ，如果 nums 中存在这个目标值 target ，则返回它的下标，否则返回 -1 。
 * 你必须设计一个时间复杂度为 O(log n) 的算法解决此问题。
 * 示例 1：
 * 输入：nums = [4,5,6,7,0,1,2], target = 0
 * 输出：4
 * 示例 2：
 * 输入：nums = [4,5,6,7,0,1,2], target = 3
 * 输出：-1
 * 示例 3：
 * 输入：nums = [1], target = 0
 * 输出：-1
 * 提示：
 * 1 <= nums.length <= 5000
 * -104 <= nums[i] <= 104
 * nums 中的每个值都 独一无二
 * 题目数据保证 nums 在预先未知的某个下标上进行了旋转
 * -104 <= target <= 104
 */
public class LC33_search_in_rotated_sorted_array {

    public static void main(String[] args) {
        new LC33_search_in_rotated_sorted_array().search(new int[]{ 4, 5, 6, 7, 0, 1, 2 }, 3);
    }

    int[] nums;
    int target;

    public int search(int[] nums, int target) {
        if (nums.length == 1) {
            return nums[0] == target ? 0 : -1;
        }
        this.nums = nums;
        this.target = target;
        return handle(0, nums.length - 1);
    }

    private int handle(int begin, int end) {
        int beginVal = nums[begin];
        int endVal = nums[end];
        if (beginVal == target) {
            return begin;
        }
        if (endVal == target) {
            return end;
        }
        if (beginVal < endVal && (target < beginVal || target > endVal)) {
            return -1;
        }
        if (begin + 1 == end) {
            return -1;
        }
        int mid = (begin + end) / 2;
        int midVal = nums[mid];
        if (midVal == target) {
            return mid;
        }
        if (midVal < endVal) {
            if (midVal < target && target < endVal) {
                return handle(mid, end);
            } else {
                return handle(begin, mid);
            }
        } else {
            if (target > beginVal && target < midVal) {
                return handle(begin, mid);
            } else {
                return handle(mid, end);
            }
        }
    }

}
