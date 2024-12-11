package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/12/11
 * 给你一个长度为 n 的整数数组 nums ，其中 nums 的所有整数都在范围 [1, n] 内，且每个整数出现 最多两次 。请你找出所有出现 两次 的整数，并以数组形式返回。
 * 你必须设计并实现一个时间复杂度为 O(n) 且仅使用常量额外空间（不包括存储输出所需的空间）的算法解决此问题。
 * 示例 1：
 * 输入：nums = [4,3,2,7,8,2,3,1]
 * 输出：[2,3]
 * 示例 2：
 * 输入：nums = [1,1,2]
 * 输出：[1]
 * 示例 3：
 * 输入：nums = [1]
 * 输出：[]
 * 提示：
 * n == nums.length
 * 1 <= n <= 105
 * 1 <= nums[i] <= n
 * nums 中的每个元素出现 一次 或 两次
 */
public class LC442_find_all_duplicates_in_an_array {

    public static void main(String[] args) {
        new LC442_find_all_duplicates_in_an_array().findDuplicates(new int[]{ 4, 3, 2, 7, 8, 2, 3, 1 });
    }

    /**
     * 我是傻逼
     */
    public List<Integer> findDuplicates(int[] nums) {
        List<Integer> ans = new ArrayList<>();
        int n = nums.length;
        for (int i = 0; i < n; i++) {
            int t = nums[i];
            if (t < 0 || t - 1 == i) {
                continue;
            }
            if (nums[t - 1] == t) {
                ans.add(t);
                nums[i] = -1;
            } else {
                int c = nums[t - 1];
                nums[t - 1] = t;
                nums[i--] = c;
            }
        }
        return ans;
    }
}
