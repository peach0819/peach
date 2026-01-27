package com.peach.algo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2026/1/27
 * 给定一个单词列表 words 和一个整数 k ，返回前 k 个出现次数最多的单词。
 * 返回的答案应该按单词出现频率由高到低排序。如果不同的单词有相同出现频率， 按字典顺序 排序。
 * 示例 1：
 * 输入: words = ["i", "love", "leetcode", "i", "love", "coding"], k = 2
 * 输出: ["i", "love"]
 * 解析: "i" 和 "love" 为出现次数最多的两个单词，均为2次。
 * 注意，按字母顺序 "i" 在 "love" 之前。
 * 示例 2：
 * 输入: ["the", "day", "is", "sunny", "the", "the", "the", "sunny", "is", "is"], k = 4
 * 输出: ["the", "is", "sunny", "day"]
 * 解析: "the", "is", "sunny" 和 "day" 是出现次数最多的四个单词，
 * 出现次数依次为 4, 3, 2 和 1 次。
 * 注意：
 * 1 <= words.length <= 500
 * 1 <= words[i].length <= 10
 * words[i] 由小写英文字母组成。
 * k 的取值范围是 [1, 不同 words[i] 的数量]
 * 进阶：尝试以 O(n log k) 时间复杂度和 O(n) 空间复杂度解决。
 */
public class LC692_top_k_frequent_words {

    public List<String> topKFrequent(String[] words, int k) {
        Map<String, Integer> map = new HashMap<>();
        for (String word : words) {
            map.put(word, map.getOrDefault(word, 0) + 1);
        }
        Map<Integer, List<String>> numMap = new HashMap<>();
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            numMap.computeIfAbsent(entry.getValue(), a -> new ArrayList<>())
                    .add(entry.getKey());
        }
        List<Integer> keyList = new ArrayList<>(numMap.keySet());
        keyList.sort((a, b) -> b - a);
        List<String> result = new ArrayList<>();
        for (Integer key : keyList) {
            List<String> list = numMap.get(key);
            list.sort(String::compareTo);
            if (k - result.size() > list.size()) {
                result.addAll(list);
            } else {
                result.addAll(list.subList(0, k - result.size()));
            }
        }
        return result;
    }
}
