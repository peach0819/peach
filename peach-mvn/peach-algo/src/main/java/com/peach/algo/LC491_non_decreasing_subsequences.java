package com.peach.algo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2025/1/23
 * 给你一个整数数组 nums ，找出并返回所有该数组中不同的递增子序列，递增子序列中 至少有两个元素 。你可以按 任意顺序 返回答案。
 * 数组中可能含有重复元素，如出现两个整数相等，也可以视作递增序列的一种特殊情况。
 * 示例 1：
 * 输入：nums = [4,6,7,7]
 * 输出：[[4,6],[4,6,7],[4,6,7,7],[4,7],[4,7,7],[6,7],[6,7,7],[7,7]]
 * 示例 2：
 * 输入：nums = [4,4,3,2,1]
 * 输出：[[4,4]]
 * 提示：
 * 1 <= nums.length <= 15
 * -100 <= nums[i] <= 100
 */
public class LC491_non_decreasing_subsequences {

    public static void main(String[] args) {
        LC491_non_decreasing_subsequences lc491_non_decreasing_subsequences = new LC491_non_decreasing_subsequences();
        int[] nums = { 1, 2, 1, 1, 1 };
        List<List<Integer>> subsequences = lc491_non_decreasing_subsequences.findSubsequences(nums);
        int i = 1;
    }

    int[] nums;

    List<List<Integer>> result = new ArrayList<>();

    public List<List<Integer>> findSubsequences(int[] nums) {
        this.nums = nums;
        Map<Integer, Node> map = new HashMap<>();
        handle(0, map);
        map.forEach((key, value) -> add(value, new ArrayList<>()));
        return result;
    }

    private void handle(int index, Map<Integer, Node> map) {
        for (int i = index; i < nums.length; i++) {
            if (map.containsKey(nums[i])) {
                continue;
            }
            Node newNode = new Node();
            newNode.val = nums[i];
            newNode.child = new HashMap<>();
            map.put(nums[i], newNode);
            handle(i + 1, newNode.child);
        }
    }

    private void add(Node node, List<Integer> list) {
        list.add(node.val);
        if (list.size() > 1) {
            result.add(new ArrayList<>(list));
        }
        if (!node.child.isEmpty()) {
            node.child.forEach((key, value) -> {
                if (value.val >= node.val) {
                    add(value, list);
                }
            });
        }
        list.remove(list.size() - 1);
    }

    static class Node {

        int val;
        Map<Integer, Node> child = new HashMap<>();

    }
}
