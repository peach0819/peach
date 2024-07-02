package com.peach.algo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/7/2
 * 给你一个由 n 个整数组成的数组 nums ，和一个目标值 target 。请你找出并返回满足下述全部条件且不重复的四元组 [nums[a], nums[b], nums[c], nums[d]] （若两个四元组元素一一对应，则认为两个四元组重复）：
 * 0 <= a, b, c, d < n
 * a、b、c 和 d 互不相同
 * nums[a] + nums[b] + nums[c] + nums[d] == target
 * 你可以按 任意顺序 返回答案 。
 * 示例 1：
 * 输入：nums = [1,0,-1,0,-2,2], target = 0
 * 输出：[[-2,-1,1,2],[-2,0,0,2],[-1,0,0,1]]
 * 示例 2：
 * 输入：nums = [2,2,2,2,2], target = 8
 * 输出：[[2,2,2,2]]
 * 提示：
 * 1 <= nums.length <= 200
 * -109 <= nums[i] <= 109
 * -109 <= target <= 109
 */
public class LC18_4sum {

    public static void main(String[] args) {
        new LC18_4sum().fourSum(new int[]{ -1000000000, -1000000000, 1000000000, -1000000000, -1000000000 }, 294967296);
    }

    public List<List<Integer>> fourSum(int[] nums, int target) {
        Arrays.sort(nums);
        Map<Integer, Map<Integer, Map<Integer, Integer>>> map = new HashMap<>();
        for (int i = 0; i < nums.length; i++) {
            int num = nums[i];
            if (map.containsKey(num)) {
                continue;
            }
            if (num >= 0 && num > target) {
                break;
            }
            if (!isValid(num, target)) {
                continue;
            }
            Map<Integer, Map<Integer, Integer>> threeMap = doThreeSum(nums, i + 1, target - num);
            map.put(num, threeMap);
        }
        List<List<Integer>> result = new ArrayList<>();
        for (Map.Entry<Integer, Map<Integer, Map<Integer, Integer>>> entry4 : map.entrySet()) {
            if (entry4.getValue() == null || entry4.getValue().isEmpty()) {
                continue;
            }
            for (Map.Entry<Integer, Map<Integer, Integer>> entry3 : entry4.getValue().entrySet()) {
                if (entry3.getValue() == null || entry3.getValue().isEmpty()) {
                    continue;
                }
                for (Map.Entry<Integer, Integer> entry2 : entry3.getValue().entrySet()) {
                    if (entry2 == null) {
                        continue;
                    }
                    List<Integer> list = new ArrayList<>();
                    list.add(entry4.getKey());
                    list.add(entry3.getKey());
                    list.add(entry2.getKey());
                    list.add(entry2.getValue());
                    result.add(list);
                }
            }
        }
        return result;
    }

    private Map<Integer, Map<Integer, Integer>> doThreeSum(int[] nums, int beginIndex, int target) {
        if (beginIndex >= nums.length) {
            return Collections.emptyMap();
        }
        Map<Integer, Map<Integer, Integer>> map = new HashMap<>();
        for (int i = beginIndex; i < nums.length; i++) {
            int num = nums[i];
            if (map.containsKey(num)) {
                continue;
            }
            if (num >= 0 && num > target) {
                break;
            }
            if (!isValid(num, target)) {
                continue;
            }
            Map<Integer, Integer> twoMap = doTwoSum(nums, i + 1, target - num);
            map.put(num, twoMap);
        }
        return map;
    }

    private Map<Integer, Integer> doTwoSum(int[] nums, int beginIndex, int target) {
        if (beginIndex >= nums.length) {
            return Collections.emptyMap();
        }
        Map<Integer, Integer> map = new HashMap<>();
        Map<Integer, Integer> tempMap = new HashMap<>();
        for (int i = beginIndex; i < nums.length; i++) {
            int num = nums[i];
            if (map.containsKey(num)) {
                continue;
            }
            if (!isValid(num, target)) {
                continue;
            }
            if (tempMap.containsKey(num)) {
                map.put(target - num, num);
            }
            tempMap.put(target - num, num);
        }
        return map;
    }

    private boolean isValid(int num, int target) {
        if (target > 0 && num < target - Integer.MAX_VALUE
                || target < 0 && num > target + Integer.MIN_VALUE) {
            return false;
        }
        return true;
    }
}
