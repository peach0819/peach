package com.peach.algo.LC501_550_toVip;

import java.util.List;

/**
 * @author feitao.zt
 * @date 2025/3/10
 * 给你一个字符串 s 和一个字符串数组 dictionary ，找出并返回 dictionary 中最长的字符串，该字符串可以通过删除 s 中的某些字符得到。
 * 如果答案不止一个，返回长度最长且字母序最小的字符串。如果答案不存在，则返回空字符串。
 * 示例 1：
 * 输入：s = "abpcplea", dictionary = ["ale","apple","monkey","plea"]
 * 输出："apple"
 * 示例 2：
 * 输入：s = "abpcplea", dictionary = ["a","b","c"]
 * 输出："a"
 * 提示：
 * 1 <= s.length <= 1000
 * 1 <= dictionary.length <= 1000
 * 1 <= dictionary[i].length <= 1000
 * s 和 dictionary[i] 仅由小写英文字母组成
 */
public class LC524_longest_word_in_dictionary_through_deleting {

    public String findLongestWord(String s, List<String> dictionary) {
        dictionary.sort((a, b) -> {
            if (a.length() != b.length()) {
                return b.length() - a.length();
            } else {
                return a.compareTo(b);
            }
        });
        for (String str : dictionary) {
            if (contains(s, str)) {
                return str;
            }
        }
        return "";
    }

    private boolean contains(String bigger, String smaller) {
        int index = 0;
        for (int i = 0; i < smaller.length(); i++) {
            char c = smaller.charAt(i);
            boolean match = false;
            while (index < bigger.length()) {
                if (bigger.charAt(index) == c) {
                    index++;
                    match = true;
                    break;
                }
                index++;
            }
            if (!match) {
                return false;
            }
        }
        return true;
    }

}
