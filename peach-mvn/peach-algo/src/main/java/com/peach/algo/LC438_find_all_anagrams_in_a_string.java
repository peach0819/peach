package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/12/10
 * 给定两个字符串 s 和 p，找到 s 中所有 p 的
 * 异位词
 * 的子串，返回这些子串的起始索引。不考虑答案输出的顺序。
 * 示例 1:
 * 输入: s = "cbaebabacd", p = "abc"
 * 输出: [0,6]
 * 解释:
 * 起始索引等于 0 的子串是 "cba", 它是 "abc" 的异位词。
 * 起始索引等于 6 的子串是 "bac", 它是 "abc" 的异位词。
 * 示例 2:
 * 输入: s = "abab", p = "ab"
 * 输出: [0,1,2]
 * 解释:
 * 起始索引等于 0 的子串是 "ab", 它是 "ab" 的异位词。
 * 起始索引等于 1 的子串是 "ba", 它是 "ab" 的异位词。
 * 起始索引等于 2 的子串是 "ab", 它是 "ab" 的异位词。
 * 提示:
 * 1 <= s.length, p.length <= 3 * 104
 * s 和 p 仅包含小写字母
 */
public class LC438_find_all_anagrams_in_a_string {

    public static void main(String[] args) {
        new LC438_find_all_anagrams_in_a_string().findAnagrams("cbaebabacd", "abc");
    }

    public List<Integer> findAnagrams(String s, String p) {
        if (s.length() < p.length()) {
            return new ArrayList<>();
        }
        int[] array = new int[26];
        int begin = 0;

        for (int i = 0; i < p.length(); i++) {
            //处理p
            array[p.charAt(i) - 'a']++;
            begin++;
        }

        for (int i = 0; i < p.length(); i++) {
            //初始化s
            int cur = array[s.charAt(i) - 'a'];
            if (cur > 0) {
                begin--;
            } else {
                begin++;
            }
            array[s.charAt(i) - 'a']--;
        }
        List<Integer> result = new ArrayList<>();
        if (begin == 0) {
            result.add(0);
        }
        for (int i = 1; i <= s.length() - p.length(); i++) {
            int last = array[s.charAt(i - 1) - 'a'];
            if (last >= 0) {
                begin++;
            } else {
                begin--;
            }
            array[s.charAt(i - 1) - 'a']++;

            int next = array[s.charAt(i + p.length() - 1) - 'a'];
            if (next > 0) {
                begin--;
            } else {
                begin++;
            }
            array[s.charAt(i + p.length() - 1) - 'a']--;

            if (begin == 0) {
                result.add(i);
            }
        }
        return result;
    }
}
