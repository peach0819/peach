package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/8
 * 给定一个不含重复数字的数组 nums ，返回其 所有可能的全排列 。你可以 按任意顺序 返回答案。
 * 示例 1：
 * 输入：nums = [1,2,3]
 * 输出：[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]
 * 示例 2：
 * 输入：nums = [0,1]
 * 输出：[[0,1],[1,0]]
 * 示例 3：
 * 输入：nums = [1]
 * 输出：[[1]]
 * 提示：
 * 1 <= nums.length <= 6
 * -10 <= nums[i] <= 10
 * nums 中的所有整数 互不相同
 */
public class LC46_permutations {

    List<List<Integer>> result = new ArrayList<>();
    int[] nums;

    public List<List<Integer>> permute(int[] nums) {
        this.nums = nums;

        List<Integer> remainList = new ArrayList<>();
        for (int i = 0; i < nums.length; i++) {
            remainList.add(i);
        }

        handle(new ArrayList<>(), remainList);
        return result;
    }

    private void handle(List<Integer> list, List<Integer> remainList) {
        if (list.size() == nums.length) {
            result.add(new ArrayList<>(list));
        }
        for (Integer remain : remainList) {
            list.add(nums[remain]);
            List<Integer> curRemain = new ArrayList<>(remainList);
            curRemain.remove(remain);
            handle(list, curRemain);
            list.remove(list.size() - 1);
        }
    }
}
