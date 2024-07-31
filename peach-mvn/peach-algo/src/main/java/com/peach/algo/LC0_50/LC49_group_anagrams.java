package com.peach.algo.LC0_50;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2023/7/12
 * 给你一个字符串数组，请你将 字母异位词 组合在一起。可以按任意顺序返回结果列表。
 * 字母异位词 是由重新排列源单词的所有字母得到的一个新单词。
 *  
 * 示例 1:
 * 输入: strs = ["eat", "tea", "tan", "ate", "nat", "bat"]
 * 输出: [["bat"],["nat","tan"],["ate","eat","tea"]]
 * 示例 2:
 * 输入: strs = [""]
 * 输出: [[""]]
 * 示例 3:
 * 输入: strs = ["a"]
 * 输出: [["a"]]
 *  
 * 提示：
 * 1 <= strs.length <= 104
 * 0 <= strs[i].length <= 100
 * strs[i] 仅包含小写字母
 * 来源：力扣（LeetCode）
 * 链接：https://leetcode.cn/problems/group-anagrams
 * 著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
 */
public class LC49_group_anagrams {

    public static void main(String[] args) {
        List<List<String>> lists = groupAnagrams(new String[]{ "eat", "tea", "tan", "ate", "nat", "bat" });
        int i = 1;
    }

    public static List<List<String>> groupAnagrams(String[] strs) {
        Map<String, List<String>> map = new HashMap<>();
        for (String str : strs) {
            char[] chars = str.toCharArray();
            Arrays.sort(chars);
            String s = new String(chars);
            map.putIfAbsent(s, new ArrayList<>());
            map.get(s).add(str);
        }
        return new ArrayList<>(map.values());
    }
}
