package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/7/18
 * 已知存在一个按非降序排列的整数数组 nums ，数组中的值不必互不相同。
 * 在传递给函数之前，nums 在预先未知的某个下标 k（0 <= k < nums.length）上进行了 旋转 ，使数组变为 [nums[k], nums[k+1], ..., nums[n-1], nums[0], nums[1], ..., nums[k-1]]（下标 从 0 开始 计数）。例如， [0,1,2,4,4,4,5,6,6,7] 在下标 5 处经旋转后可能变为 [4,5,6,6,7,0,1,2,4,4] 。
 * 给你 旋转后 的数组 nums 和一个整数 target ，请你编写一个函数来判断给定的目标值是否存在于数组中。如果 nums 中存在这个目标值 target ，则返回 true ，否则返回 false 。
 * 你必须尽可能减少整个操作步骤。
 * 示例 1：
 * 输入：nums = [2,5,6,0,0,1,2], target = 0
 * 输出：true
 * 示例 2：
 * 输入：nums = [2,5,6,0,0,1,2], target = 3
 * 输出：false
 * 提示：
 * 1 <= nums.length <= 5000
 * -104 <= nums[i] <= 104
 * 题目数据保证 nums 在预先未知的某个下标上进行了旋转
 * -104 <= target <= 104
 * 进阶：
 * 此题与 搜索旋转排序数组 相似，但本题中的 nums  可能包含 重复 元素。这会影响到程序的时间复杂度吗？会有怎样的影响，为什么？
 */
public class LC81_search_in_rotated_sorted_array_ii {

    public static void main(String[] args) {
        new LC81_search_in_rotated_sorted_array_ii().search(new int[]{ 3, 1, 2, 2, 2 }, 1);
    }

    int[] nums;
    int target;

    public boolean search(int[] nums, int target) {
        if (nums.length == 1) {
            return nums[0] == target;
        }
        this.nums = nums;
        this.target = target;
        return handle(0, nums.length - 1);
    }

    private boolean handle(int begin, int end) {
        int beginVal = nums[begin];
        int endVal = nums[end];
        if (beginVal == target || endVal == target) {
            return true;
        }
        if (beginVal < endVal && (target < beginVal || target > endVal)) {
            return false;
        }
        if (begin + 1 == end) {
            return false;
        }
        int mid = (begin + end) / 2;
        int midVal = nums[mid];
        if (midVal == target) {
            return true;
        }
        if (midVal < endVal) {
            if (midVal < target && target < endVal) {
                return handle(mid, end);
            } else {
                return handle(begin, mid);
            }
        } else if (midVal > endVal) {
            if (target > beginVal && target < midVal) {
                return handle(begin, mid);
            } else {
                return handle(mid, end);
            }
        } else {
            if (midVal > beginVal) {
                return handle(begin, mid);
            } else if (midVal < beginVal) {
                if (target > beginVal || target < midVal) {
                    return handle(begin, mid);
                } else {
                    return false;
                }
            }
            return handle(begin, mid) || handle(mid, end);
        }
    }
}
