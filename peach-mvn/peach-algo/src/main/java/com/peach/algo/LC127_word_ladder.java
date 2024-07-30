package com.peach.algo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/26
 * 字典 wordList 中从单词 beginWord 到 endWord 的 转换序列 是一个按下述规格形成的序列 beginWord -> s1 -> s2 -> ... -> sk：
 * 每一对相邻的单词只差一个字母。
 * 对于 1 <= i <= k 时，每个 si 都在 wordList 中。注意， beginWord 不需要在 wordList 中。
 * sk == endWord
 * 给你两个单词 beginWord 和 endWord 和一个字典 wordList ，返回 从 beginWord 到 endWord 的 最短转换序列 中的 单词数目 。如果不存在这样的转换序列，返回 0 。
 * 示例 1：
 * 输入：beginWord = "hit", endWord = "cog", wordList = ["hot","dot","dog","lot","log","cog"]
 * 输出：5
 * 解释：一个最短转换序列是 "hit" -> "hot" -> "dot" -> "dog" -> "cog", 返回它的长度 5。
 * 示例 2：
 * 输入：beginWord = "hit", endWord = "cog", wordList = ["hot","dot","dog","lot","log"]
 * 输出：0
 * 解释：endWord "cog" 不在字典中，所以无法进行转换。
 * 提示：
 * 1 <= beginWord.length <= 10
 * endWord.length == beginWord.length
 * 1 <= wordList.length <= 5000
 * wordList[i].length == beginWord.length
 * beginWord、endWord 和 wordList[i] 由小写英文字母组成
 * beginWord != endWord
 * wordList 中的所有字符串 互不相同
 */
public class LC127_word_ladder {

    public static void main(String[] args) {
        List<String> wordList = Arrays.asList("hot", "dot", "dog", "lot", "log", "cog");
        new LC127_word_ladder().ladderLength("hit", "cog", wordList);
    }

    public int ladderLength(String beginWord, String endWord, List<String> wordList) {
        if (beginWord.length() != endWord.length() || !wordList.contains(endWord)) {
            return 0;
        }
        List<String> lastList = new ArrayList<>();
        lastList.add(beginWord);

        List<String> curList = wordList;
        List<String> nextList = new ArrayList<>();
        List<String> stillList = new ArrayList<>();
        int index = 2;
        while (true) {
            for (String cur : curList) {
                if (listOne(cur, lastList)) {
                    if (cur.equals(endWord)) {
                        return index;
                    } else {
                        nextList.add(cur);
                    }
                } else {
                    stillList.add(cur);
                }
            }
            if (nextList.isEmpty()) {
                return 0;
            }
            curList = stillList;
            lastList = nextList;
            nextList = new ArrayList<>();
            stillList = new ArrayList<>();
            index++;
        }
    }

    private boolean listOne(String beginWord, List<String> list) {
        for (String s : list) {
            if (isOne(beginWord, s)) {
                return true;
            }
        }
        return false;
    }

    private boolean isOne(String beginWord, String endWord) {
        char[] cb = beginWord.toCharArray();
        char[] ce = endWord.toCharArray();
        int diff = 0;
        for (int i = 0; i < cb.length; i++) {
            if (cb[i] != ce[i]) {
                diff++;
            }
            if (diff > 1) {
                return false;
            }
        }
        return true;
    }
}
