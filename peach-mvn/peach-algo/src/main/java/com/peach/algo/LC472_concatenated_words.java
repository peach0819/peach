package com.peach.algo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/12/19
 * 给你一个 不含重复 单词的字符串数组 words ，请你找出并返回 words 中的所有 连接词 。
 * 连接词 定义为：一个完全由给定数组中的至少两个较短单词（不一定是不同的两个单词）组成的字符串。
 * 示例 1：
 * 输入：words = ["cat","cats","catsdogcats","dog","dogcatsdog","hippopotamuses","rat","ratcatdogcat"]
 * 输出：["catsdogcats","dogcatsdog","ratcatdogcat"]
 * 解释："catsdogcats" 由 "cats", "dog" 和 "cats" 组成;
 * "dogcatsdog" 由 "dog", "cats" 和 "dog" 组成;
 * "ratcatdogcat" 由 "rat", "cat", "dog" 和 "cat" 组成。
 * 示例 2：
 * 输入：words = ["cat","dog","catdog"]
 * 输出：["catdog"]
 * 提示：
 * 1 <= words.length <= 104
 * 1 <= words[i].length <= 30
 * words[i] 仅由小写英文字母组成。
 * words 中的所有字符串都是 唯一 的。
 * 1 <= sum(words[i].length) <= 105
 */
public class LC472_concatenated_words {

    /**
     * 我是傻逼
     * 用26个字母做字典树
     */
    Trie trie = new Trie();

    public List<String> findAllConcatenatedWordsInADict(String[] words) {
        List<String> ans = new ArrayList<>();
        Arrays.sort(words, (a, b) -> a.length() - b.length());
        for (String word : words) {
            if (dfs(word, 0)) {
                ans.add(word);
            } else {
                insert(word);
            }
        }
        return ans;
    }

    public boolean dfs(String word, int start) {
        if (word.length() == start) {
            return true;
        }
        Trie node = trie;
        for (int i = start; i < word.length(); i++) {
            char ch = word.charAt(i);
            int index = ch - 'a';
            node = node.children[index];
            if (node == null) {
                return false;
            }
            if (node.isEnd) {
                if (dfs(word, i + 1)) {
                    return true;
                }
            }
        }
        return false;
    }

    public void insert(String word) {
        Trie node = trie;
        for (int i = 0; i < word.length(); i++) {
            char ch = word.charAt(i);
            int index = ch - 'a';
            if (node.children[index] == null) {
                node.children[index] = new Trie();
            }
            node = node.children[index];
        }
        node.isEnd = true;
    }

    public static class Trie {

        Trie[] children;
        boolean isEnd;

        public Trie() {
            children = new Trie[26];
            isEnd = false;
        }
    }

    //***********************************   没用的  ****************************************/

    Set<String> cache = new HashSet<>();
    Set<String> set1;

    public List<String> findAllConcatenatedWordsInADict1(String[] words) {
        set1 = new HashSet<>(Arrays.asList(words));
        List<String> result = new ArrayList<>();
        for (String word : words) {
            if (dfs(word, true)) {
                result.add(word);
            }
        }
        return result;
    }

    private boolean dfs(String word, boolean first) {
        if (!first && cache.contains(word)) {
            return true;
        }
        for (String s : set1) {
            if (word.startsWith(s)) {
                if (s.length() == word.length()) {
                    if (first) {
                        continue;
                    } else {
                        cache.add(word);
                        return true;
                    }
                }
                if (dfs(word.substring(s.length()), false)) {
                    cache.add(word);
                    return true;
                }
            }
        }
        return false;
    }
}
