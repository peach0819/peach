package com.peach.algo;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2026/2/5
 * 给出一个字符串数组 words 组成的一本英语词典。返回能够通过 words 中其它单词逐步添加一个字母来构造得到的 words 中最长的单词。
 * 若其中有多个可行的答案，则返回答案中字典序最小的单词。若无答案，则返回空字符串。
 * 请注意，单词应该从左到右构建，每个额外的字符都添加到前一个单词的结尾。
 * 示例 1：
 * 输入：words = ["w","wo","wor","worl", "world"]
 * 输出："world"
 * 解释： 单词"world"可由"w", "wo", "wor", 和 "worl"逐步添加一个字母组成。
 * 示例 2：
 * 输入：words = ["a", "banana", "app", "appl", "ap", "apply", "apple"]
 * 输出："apple"
 * 解释："apply" 和 "apple" 都能由词典中的单词组成。但是 "apple" 的字典序小于 "apply"
 * 提示：
 * 1 <= words.length <= 1000
 * 1 <= words[i].length <= 30
 * 所有输入的字符串 words[i] 都只包含小写字母。
 */
public class LC720_longest_word_in_dictionary {

    static class Node {

        boolean isEnd;
        Node[] children = new Node[26];
    }

    public String longestWord(String[] words) {
        Arrays.sort(words, (a, b) -> {
            if (a.length() == b.length()) {
                return b.compareTo(a);
            }
            return a.length() - b.length();
        });

        Node[] root = new Node[26];
        String result = "";
        for (String word : words) {
            Node[] cur = root;
            boolean isEnd = true;
            if (word.length() == 1) {
                result = word;
            }
            for (int i = 0; i < word.length(); i++) {
                char c = word.charAt(i);
                if (cur[c - 'a'] != null) {
                    if (!cur[c - 'a'].isEnd) {
                        isEnd = false;
                    }
                    if (isEnd && i == word.length() - 2) {
                        result = word;
                    }
                } else {
                    cur[c - 'a'] = new Node();
                    if (i == word.length() - 1) {
                        cur[c - 'a'].isEnd = true;
                    }
                }
                cur = cur[c - 'a'].children;
            }
        }
        return result;
    }
}
