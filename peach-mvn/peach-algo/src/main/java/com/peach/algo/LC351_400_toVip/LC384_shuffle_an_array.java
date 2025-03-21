package com.peach.algo.LC351_400_toVip;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * @author feitao.zt
 * @date 2024/10/15
 * 给你一个整数数组 nums ，设计算法来打乱一个没有重复元素的数组。打乱后，数组的所有排列应该是 等可能 的。
 * 实现 Solution class:
 * Solution(int[] nums) 使用整数数组 nums 初始化对象
 * int[] reset() 重设数组到它的初始状态并返回
 * int[] shuffle() 返回数组随机打乱后的结果
 * 示例 1：
 * 输入
 * ["Solution", "shuffle", "reset", "shuffle"]
 * [[[1, 2, 3]], [], [], []]
 * 输出
 * [null, [3, 1, 2], [1, 2, 3], [1, 3, 2]]
 * 解释
 * Solution solution = new Solution([1, 2, 3]);
 * solution.shuffle();    // 打乱数组 [1,2,3] 并返回结果。任何 [1,2,3]的排列返回的概率应该相同。例如，返回 [3, 1, 2]
 * solution.reset();      // 重设数组到它的初始状态 [1, 2, 3] 。返回 [1, 2, 3]
 * solution.shuffle();    // 随机返回数组 [1, 2, 3] 打乱后的结果。例如，返回 [1, 3, 2]
 * 提示：
 * 1 <= nums.length <= 50
 * -106 <= nums[i] <= 106
 * nums 中的所有元素都是 唯一的
 * 最多可以调用 104 次 reset 和 shuffle
 */
public class LC384_shuffle_an_array {

    /**
     * Your Solution object will be instantiated and called as such:
     * Solution obj = new Solution(nums);
     * int[] param_1 = obj.reset();
     * int[] param_2 = obj.shuffle();
     */
    class Solution {

        int[] base;
        int[] shuffle;
        Random random = new Random();

        public Solution(int[] nums) {
            base = nums;
            shuffle = new int[nums.length];
        }

        public int[] reset() {
            return base;
        }

        public int[] shuffle() {
            List<Integer> list = new ArrayList<>();
            for (int i : base) {
                list.add(i);
            }
            for (int i = 0; i < base.length; i++) {
                int cur = random.nextInt(list.size());
                shuffle[i] = list.remove(cur);
            }
            return shuffle;
        }
    }

}
