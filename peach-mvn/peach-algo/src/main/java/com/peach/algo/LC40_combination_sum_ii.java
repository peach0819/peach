package com.peach.algo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * @author feitao.zt
 * @date 2024/7/9
 * 给定一个候选人编号的集合 candidates 和一个目标数 target ，找出 candidates 中所有可以使数字和为 target 的组合。
 * candidates 中的每个数字在每个组合中只能使用 一次 。
 * 注意：解集不能包含重复的组合。
 * 示例 1:
 * 输入: candidates = [10,1,2,7,6,1,5], target = 8,
 * 输出:
 * [
 * [1,1,6],
 * [1,2,5],
 * [1,7],
 * [2,6]
 * ]
 * 示例 2:
 * 输入: candidates = [2,5,2,1,2], target = 5,
 * 输出:
 * [
 * [1,2,2],
 * [5]
 * ]
 * 提示:
 * 1 <= candidates.length <= 100
 * 1 <= candidates[i] <= 50
 * 1 <= target <= 30
 */
public class LC40_combination_sum_ii {

    List<List<Integer>> result1 = new ArrayList<>();
    Set<String> resultSet = new HashSet<>();

    public List<List<Integer>> combinationSum3(int[] candidates, int target) {
        Arrays.sort(candidates);
        handle1(candidates, candidates.length - 1, target, new ArrayList<>());
        return result1;
    }

    private void handle1(int[] candidates, int lastIndex, int target, List<Integer> list) {
        if (target == 0) {
            String key = build(list);
            if (!resultSet.contains(key)) {
                resultSet.add(key);
                result1.add(new ArrayList<>(list));
            }
            return;
        }
        for (int i = lastIndex; i >= 0; i--) {
            int cur = candidates[i];
            if (cur <= target) {
                list.add(cur);
                handle1(candidates, i - 1, target - cur, list);
                list.remove(list.size() - 1);
            }
        }
    }

    private String build(List<Integer> list) {
        StringBuilder s = new StringBuilder();
        for (Integer integer : list) {
            s.append(integer);
        }
        return s.toString();
    }

    public static void main(String[] args) {
        new LC40_combination_sum_ii().combinationSum2(new int[]{ 10, 1, 2, 7, 6, 1, 5 }, 8);
    }

    private Map<Integer, Integer> map = new HashMap<>();
    List<List<Integer>> result = new ArrayList<>();

    public List<List<Integer>> combinationSum2(int[] candidates, int target) {
        for (int candidate : candidates) {
            map.put(candidate, map.getOrDefault(candidate, 0) + 1);
        }
        List<Integer> list = map.keySet().stream().sorted(Comparator.comparing(Integer::intValue).reversed())
                .collect(Collectors.toList());
        handle(list, 0, target, new ArrayList<>());
        return result;
    }

    private void handle(List<Integer> list, int begin, int target, List<Integer> rrr) {
        if (target == 0) {
            result.add(new ArrayList<>(rrr));
            return;
        }

        for (int i = begin; i < list.size(); i++) {
            Integer cur = list.get(i);
            Integer retain = map.get(cur);
            if (cur <= target && retain != 0) {
                rrr.add(cur);
                map.put(cur, retain - 1);
                handle(list, i, target - cur, rrr);
                rrr.remove(rrr.size() - 1);
                map.put(cur, retain);
            }
        }
    }

}
