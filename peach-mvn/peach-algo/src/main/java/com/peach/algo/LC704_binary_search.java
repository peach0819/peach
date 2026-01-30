package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2026/1/30
 * 给定一个 n 个元素有序的（升序）整型数组 nums 和一个目标值 target  ，写一个函数搜索 nums 中的 target，如果 target 存在返回下标，否则返回 -1。
 * 你必须编写一个具有 O(log n) 时间复杂度的算法。
 * 示例 1:
 * 输入: nums = [-1,0,3,5,9,12], target = 9
 * 输出: 4
 * 解释: 9 出现在 nums 中并且下标为 4
 * 示例 2:
 * 输入: nums = [-1,0,3,5,9,12], target = 2
 * 输出: -1
 * 解释: 2 不存在 nums 中因此返回 -1
 * 提示：
 * 你可以假设 nums 中的所有元素是不重复的。
 * n 将在 [1, 10000]之间。
 * nums 的每个元素都将在 [-9999, 9999]之间。
 */
public class LC704_binary_search {

    int[] nums;
    int target;

    public int search(int[] nums, int target) {
        this.nums = nums;
        this.target = target;
        return search(0, nums.length - 1);
    }

    private int search(int begin, int end) {
        if (nums[begin] == target) {
            return begin;
        }
        if (nums[end] == target) {
            return end;
        }
        //二分法，因为mid是向下取整，所以左边搜索用Mid, 右边搜索用mid+1
        if (begin == end) {
            return -1;
        }
        int mid = (begin + end) / 2;
        if (nums[mid] == target) {
            return mid;
        } else if (nums[mid] > target) {
            return search(begin, mid - 1);
        } else {
            return search(mid + 1, end);
        }
    }

}
