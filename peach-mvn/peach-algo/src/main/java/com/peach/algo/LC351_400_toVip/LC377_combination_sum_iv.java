package com.peach.algo.LC351_400_toVip;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/10/12
 * 给你一个由 不同 整数组成的数组 nums ，和一个目标整数 target 。请你从 nums 中找出并返回总和为 target 的元素组合的个数。
 * 题目数据保证答案符合 32 位整数范围。
 * 示例 1：
 * 输入：nums = [1,2,3], target = 4
 * 输出：7
 * 解释：
 * 所有可能的组合为：
 * (1, 1, 1, 1)
 * (1, 1, 2)
 * (1, 2, 1)
 * (1, 3)
 * (2, 1, 1)
 * (2, 2)
 * (3, 1)
 * 请注意，顺序不同的序列被视作不同的组合。
 * 示例 2：
 * 输入：nums = [9], target = 3
 * 输出：0
 * 提示：
 * 1 <= nums.length <= 200
 * 1 <= nums[i] <= 1000
 * nums 中的所有元素 互不相同
 * 1 <= target <= 1000
 * 进阶：如果给定的数组中含有负数会发生什么？问题会产生何种变化？如果允许负数出现，需要向题目中添加哪些限制条件？
 */
public class LC377_combination_sum_iv {

    public static void main(String[] args) {
        new LC377_combination_sum_iv().combinationSum4(new int[]{ 1, 2, 3 }, 4);
    }

    /**
     * 我是傻逼
     * 进阶版爬楼梯
     */
    public int combinationSum4(int[] nums, int target) {
        int[] dp = new int[target + 1];
        dp[0] = 1;
        for (int i = 1; i <= target; i++) {
            int cur = 0;
            for (int num : nums) {
                if (i < num) {
                    continue;
                }
                cur += dp[i - num];
            }
            dp[i] = cur;
        }
        return dp[target];
    }

    //***************************   概率论大法，好像有点问题，但是又不知道哪里有问题 ******************************/
    int[] nums;

    List<List<int[]>> result = new ArrayList<>();

    public int combinationSum41(int[] nums, int target) {
        this.nums = nums;
        handle(new ArrayList<>(), 0, target);
        int a = 0;
        for (List<int[]> ints : result) {
            a += cal(ints);
        }
        return a;
    }

    private void handle(List<int[]> list, int index, int target) {
        if (target == 0) {
            result.add(new ArrayList<>(list));
            return;
        }
        if (index >= nums.length) {
            return;
        }
        //不用当前位
        handle(list, index + 1, target);

        //用当前位
        int cur = nums[index];
        for (int i = 1; i <= target / cur; i++) {
            list.add(new int[]{ cur, i });
            handle(list, index + 1, target - i * cur);
            list.remove(list.size() - 1);
        }
    }

    private int cal(List<int[]> list) {
        int total = 0;
        int divide = 1;
        for (int[] ints : list) {
            total += ints[1];
            divide *= jiecheng(ints[1]);
        }
        return jiecheng(total) * jiecheng(list.size()) / divide;
    }

    private int jiecheng(int n) {
        if (n == 1) {
            return 1;
        }
        int result = 1;
        for (int i = n; i >= 2; i--) {
            result *= n;
            n--;
        }
        return result;
    }
}
