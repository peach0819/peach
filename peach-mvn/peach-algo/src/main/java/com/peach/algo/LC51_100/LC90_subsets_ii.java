package com.peach.algo.LC51_100;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/23
 * 给你一个整数数组 nums ，其中可能包含重复元素，请你返回该数组所有可能的
 * 子集
 * （幂集）。
 * 解集 不能 包含重复的子集。返回的解集中，子集可以按 任意顺序 排列。
 * 示例 1：
 * 输入：nums = [1,2,2]
 * 输出：[[],[1],[1,2],[1,2,2],[2],[2,2]]
 * 示例 2：
 * 输入：nums = [0]
 * 输出：[[],[0]]
 * 提示：
 * 1 <= nums.length <= 10
 * -10 <= nums[i] <= 10
 */
public class LC90_subsets_ii {

    List<List<Integer>> result = new ArrayList<>();
    int[] nums;

    public List<List<Integer>> subsetsWithDup(int[] nums) {
        this.nums = nums;
        Arrays.sort(nums);
        handle(new ArrayList<>(), 0, -11, true);
        return result;
    }

    private void handle(List<Integer> cur, int begin, int last, boolean withLast) {
        if (withLast) {
            result.add(new ArrayList<>(cur));
        }
        if (begin == nums.length) {
            return;
        }
        int num = nums[begin];
        if (!withLast && num == last) {
            handle(cur, begin + 1, last, false);
            return;
        }
        cur.add(num);
        handle(cur, begin + 1, num, true);
        cur.remove(cur.size() - 1);

        handle(cur, begin + 1, num, false);
    }
}
