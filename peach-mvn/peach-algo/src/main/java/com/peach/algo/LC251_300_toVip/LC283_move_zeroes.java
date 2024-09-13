package com.peach.algo.LC251_300_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/12
 * 给定一个数组 nums，编写一个函数将所有 0 移动到数组的末尾，同时保持非零元素的相对顺序。
 * 请注意 ，必须在不复制数组的情况下原地对数组进行操作。
 * 示例 1:
 * 输入: nums = [0,1,0,3,12]
 * 输出: [1,3,12,0,0]
 * 示例 2:
 * 输入: nums = [0]
 * 输出: [0]
 * 提示:
 * 1 <= nums.length <= 104
 * -231 <= nums[i] <= 231 - 1
 * 进阶：你能尽量减少完成的操作次数吗？
 */
public class LC283_move_zeroes {

    public void moveZeroes(int[] nums) {
        int cur = 0;
        for (int i = 0; i < nums.length; i++) {
            if (nums[i] == 0) {
                continue;
            }
            nums[cur] = nums[i];
            cur++;
        }
        for (int i = cur; i < nums.length; i++) {
            nums[i] = 0;
        }
    }
}
