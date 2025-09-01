package com.peach.algo.LC551_600_toVip;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2025/8/28
 * 给定两个字符串数组 list1 和 list2，找到 索引和最小的公共字符串。
 * 公共字符串 是同时出现在 list1 和 list2 中的字符串。
 * 具有 最小索引和的公共字符串 是指，如果它在 list1[i] 和 list2[j] 中出现，那么 i + j 应该是所有其他 公共字符串 中的最小值。
 * 返回所有 具有最小索引和的公共字符串。以 任何顺序 返回答案。
 * 示例 1:
 * 输入: list1 = ["Shogun", "Tapioca Express", "Burger King", "KFC"]，list2 = ["Piatti", "The Grill at Torrey Pines", "Hungry Hunter Steakhouse", "Shogun"]
 * 输出: ["Shogun"]
 * 解释: 唯一的公共字符串是 “Shogun”。
 * 示例 2:
 * 输入:list1 = ["Shogun", "Tapioca Express", "Burger King", "KFC"]，list2 = ["KFC", "Shogun", "Burger King"]
 * 输出: ["Shogun"]
 * 解释: 具有最小索引和的公共字符串是 “Shogun”，它有最小的索引和 = (0 + 1) = 1。
 * 示例 3：
 * 输入：list1 = ["happy","sad","good"], list2 = ["sad","happy","good"]
 * 输出：["sad","happy"]
 * 解释：有三个公共字符串：
 * "happy" 索引和 = (0 + 1) = 1.
 * "sad" 索引和 = (1 + 0) = 1.
 * "good" 索引和 = (2 + 2) = 4.
 * 最小索引和的字符串是 "sad" 和 "happy"。
 * 提示:
 * 1 <= list1.length, list2.length <= 1000
 * 1 <= list1[i].length, list2[i].length <= 30
 * list1[i] 和 list2[i] 由空格 ' ' 和英文字母组成。
 * list1 的所有字符串都是 唯一 的。
 * list2 中的所有字符串都是 唯一 的。
 */
public class LC599_minimum_index_sum_of_two_lists {

    public String[] findRestaurant(String[] list1, String[] list2) {
        Map<String, Integer> map = new HashMap<>();
        for (int i = 0; i < list1.length; i++) {
            map.put(list1[i], i);
        }
        Map<Integer, List<Integer>> resultMap = new HashMap<>();
        int min = Integer.MAX_VALUE;
        for (int i = 0; i < list2.length; i++) {
            if (!map.containsKey(list2[i])) {
                continue;
            }
            int sum = i + map.get(list2[i]);
            resultMap.putIfAbsent(sum, new ArrayList<>());
            resultMap.get(sum).add(i);
            min = Math.min(min, sum);
        }
        if (min == Integer.MAX_VALUE) {
            return new String[0];
        }
        List<Integer> list = resultMap.get(min);
        String[] result = new String[list.size()];
        for (int i = 0; i < list.size(); i++) {
            result[i] = list2[list.get(i)];
        }
        return result;
    }
}
