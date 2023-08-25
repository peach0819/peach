package com.peach.algo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2023/8/25
 * 给定一个可包含重复数字的序列 nums ，按任意顺序 返回所有不重复的全排列。
 * 示例 1：
 * 输入：nums = [1,1,2]
 * 输出：
 * [[1,1,2],
 * [1,2,1],
 * [2,1,1]]
 * 示例 2：
 * 输入：nums = [1,2,3]
 * 输出：[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]
 */
public class LC47_permutations_ii {

    List<List<Integer>> result = new ArrayList<>();

    boolean[] status;

    public List<List<Integer>> permuteUnique(int[] nums) {
        status = new boolean[nums.length];
        Arrays.sort(nums);
        operate(nums, new ArrayList<>());
        return result;
    }

    private void operate(int[] nums, List<Integer> cur) {
        if (cur.size() == nums.length) {
            result.add(new ArrayList<>(cur));
            return;
        }
        for (int i = 0; i < nums.length; i++) {
            if (status[i]) {
                continue;
            }
            if (i > 0 && nums[i] == nums[i - 1] && !status[i - 1]) {
                continue;
            }
            status[i] = true;
            cur.add(nums[i]);
            operate(nums, cur);
            status[i] = false;
            cur.remove(cur.size() - 1);
        }
    }

    public static void main(String[] args) {
        List<List<Integer>> lists = new LC47_permutations_ii().permuteUnique(new int[]{ 1, 1, 2 });
        int i = 1;
    }

}
