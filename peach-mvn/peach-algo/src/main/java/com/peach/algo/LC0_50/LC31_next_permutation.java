package com.peach.algo.LC0_50;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2024/7/4
 * 整数数组的一个 排列  就是将其所有成员以序列或线性顺序排列。
 * 例如，arr = [1,2,3] ，以下这些都可以视作 arr 的排列：[1,2,3]、[1,3,2]、[3,1,2]、[2,3,1] 。
 * 整数数组的 下一个排列 是指其整数的下一个字典序更大的排列。更正式地，如果数组的所有排列根据其字典顺序从小到大排列在一个容器中，那么数组的 下一个排列 就是在这个有序容器中排在它后面的那个排列。如果不存在下一个更大的排列，那么这个数组必须重排为字典序最小的排列（即，其元素按升序排列）。
 * 例如，arr = [1,2,3] 的下一个排列是 [1,3,2] 。
 * 类似地，arr = [2,3,1] 的下一个排列是 [3,1,2] 。
 * 而 arr = [3,2,1] 的下一个排列是 [1,2,3] ，因为 [3,2,1] 不存在一个字典序更大的排列。
 * 给你一个整数数组 nums ，找出 nums 的下一个排列。
 * 必须 原地 修改，只允许使用额外常数空间。
 * 示例 1：
 * 输入：nums = [1,2,3]
 * 输出：[1,3,2]
 * 示例 2：
 * 输入：nums = [3,2,1]
 * 输出：[1,2,3]
 * 示例 3：
 * 输入：nums = [1,1,5]
 * 输出：[1,5,1]
 * 提示：
 * 1 <= nums.length <= 100
 * 0 <= nums[i] <= 100
 */
public class LC31_next_permutation {

    int[] nums;

    boolean noResult = false;

    int finishIndex;

    public void nextPermutation1(int[] nums) {
        this.nums = nums;
        finishIndex = nums.length - 1;
        deal(nums.length - 1, true);
        if (noResult) {
            Arrays.sort(nums);
        }
    }

    private void deal(int begin, boolean finish) {
        if (finish && isFinish(begin)) {
            while (true) {
                if (begin > 0) {
                    if (nums[begin - 1] >= nums[begin]) {
                        begin--;
                    } else {
                        deal(begin - 1, false);
                        return;
                    }
                } else {
                    noResult = true;
                    return;
                }
            }
        } else {
            doDeal(begin);
        }
    }

    // 12  543
    private boolean isFinish(int begin) {
        for (int i = begin; i < finishIndex; i++) {
            if (nums[begin] < nums[begin + 1]) {
                return false;
            }
        }
        finishIndex = begin;
        return true;
    }

    private void doDeal(int begin) {
        int cur = nums[begin];
        int index = begin;
        int min = cur;
        for (int i = begin + 1; i < nums.length; i++) {
            if (nums[i] <= cur) {
                continue;
            }

            if (min == cur) {
                min = nums[i];
                index = i;
            } else if (nums[i] < min) {
                min = nums[i];
                index = i;
            }
        }
        int temp = nums[begin];
        nums[begin] = nums[index];
        nums[index] = temp;
        Arrays.sort(nums, begin + 1, nums.length);
    }

    /////////////////////////////////////////////////////////

    public void nextPermutation(int[] nums) {
        if (nums.length == 1) {
            return;
        }
        for (int i = nums.length - 2; i >= 0; i--) {
            if (nums[i] < nums[i + 1]) {
                doDeal(nums, i);
                return;
            }
        }
        Arrays.sort(nums);
    }

    private void doDeal(int[] nums, int begin) {
        int cur = nums[begin];
        int index = begin;
        int min = cur;
        for (int i = begin + 1; i < nums.length; i++) {
            if (nums[i] <= cur) {
                continue;
            }

            if (min == cur) {
                min = nums[i];
                index = i;
            } else if (nums[i] < min) {
                min = nums[i];
                index = i;
            }
        }
        int temp = nums[begin];
        nums[begin] = nums[index];
        nums[index] = temp;
        Arrays.sort(nums, begin + 1, nums.length);
    }
}
