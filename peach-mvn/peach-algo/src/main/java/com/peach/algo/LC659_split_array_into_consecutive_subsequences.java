package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/10/24
 * 给你一个按 非递减顺序 排列的整数数组 nums 。
 * 请你判断是否能在将 nums 分割成 一个或多个子序列 的同时满足下述 两个 条件：
 * 每个子序列都是一个 连续递增序列（即，每个整数 恰好 比前一个整数大 1 ）。
 * 所有子序列的长度 至少 为 3 。
 * 如果可以分割 nums 并满足上述条件，则返回 true ；否则，返回 false 。
 * 示例 1：
 * 输入：nums = [1,2,3,3,4,5]
 * 输出：true
 * 解释：nums 可以分割成以下子序列：
 * [1,2,3,3,4,5] --> 1, 2, 3
 * [1,2,3,3,4,5] --> 3, 4, 5
 * 示例 2：
 * 输入：nums = [1,2,3,3,4,4,5,5]
 * 输出：true
 * 解释：nums 可以分割成以下子序列：
 * [1,2,3,3,4,4,5,5] --> 1, 2, 3, 4, 5
 * [1,2,3,3,4,4,5,5] --> 3, 4, 5
 * 示例 3：
 * 输入：nums = [1,2,3,4,4,5]
 * 输出：false
 * 解释：无法将 nums 分割成长度至少为 3 的连续递增子序列。
 * 提示：
 * 1 <= nums.length <= 104
 * -1000 <= nums[i] <= 1000
 * nums 按非递减顺序排列
 */
public class LC659_split_array_into_consecutive_subsequences {

    public static void main(String[] args) {
        System.out.println(
                new LC659_split_array_into_consecutive_subsequences().isPossible(new int[]{ 1, 2, 3, 4, 4, 5 }));
    }

    public boolean isPossible(int[] nums) {
        int[] array = new int[nums[nums.length - 1] - nums[0] + 1];
        for (int num : nums) {
            array[num - nums[0]]++;
        }
        int cnt = 0;
        int minIndex = 0;
        while (true) {
            while (minIndex < array.length && array[minIndex] == 0) {
                minIndex++;
            }
            if (minIndex == array.length) {
                return cnt >= 3;
            }
            cnt = 0;
            for (int i = minIndex; i < array.length; i++) {
                if (array[i] == 0) {
                    if (cnt < 3) {
                        return false;
                    } else {
                        break;
                    }
                }
                if (array[i] == 1 && i > 0 && array[i - 1] > 0 && cnt >= 3) {
                    break;
                }
                array[i]--;
                cnt++;
            }
        }
    }
}
