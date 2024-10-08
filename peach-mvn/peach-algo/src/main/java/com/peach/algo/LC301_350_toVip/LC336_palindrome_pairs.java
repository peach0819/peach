package com.peach.algo.LC301_350_toVip;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/9/30
 * 给定一个由唯一字符串构成的 0 索引 数组 words 。
 * 回文对 是一对整数 (i, j) ，满足以下条件：
 * 0 <= i, j < words.length，
 * i != j ，并且
 * words[i] + words[j]（两个字符串的连接）是一个
 * 回文串
 * 。
 * 返回一个数组，它包含 words 中所有满足 回文对 条件的字符串。
 * 你必须设计一个时间复杂度为 O(sum of words[i].length) 的算法。
 * 示例 1：
 * 输入：words = ["abcd","dcba","lls","s","sssll"]
 * 输出：[[0,1],[1,0],[3,2],[2,4]]
 * 解释：可拼接成的回文串为 ["dcbaabcd","abcddcba","slls","llssssll"]
 * 示例 2：
 * 输入：words = ["bat","tab","cat"]
 * 输出：[[0,1],[1,0]]
 * 解释：可拼接成的回文串为 ["battab","tabbat"]
 * 示例 3：
 * 输入：words = ["a",""]
 * 输出：[[0,1],[1,0]]
 * 提示：
 * 1 <= words.length <= 5000
 * 0 <= words[i].length <= 300
 * words[i] 由小写英文字母组成
 */
public class LC336_palindrome_pairs {

    /**
     * 我是傻逼
     * 这个路人思路牛逼啊，判断每个单词除去自身回文部分，其余内容map里面有没有
     */
    public List<List<Integer>> palindromePairs(String[] words) {
        List<List<Integer>> result = new ArrayList<>();
        if (words == null || words.length < 2) {
            return result;
        }
        Map<String, Integer> map = new HashMap<>();
        for (int i = 0; i < words.length; i++) {
            map.put(words[i], i);
        }
        for (int i = 0; i < words.length; i++) {
            String w = words[i];
            for (int j = 0; j <= w.length(); j++) {
                String left = w.substring(0, j);
                String right = w.substring(j);
                if (isPalindrome(left)) {
                    String rightRev = new StringBuilder(right).reverse().toString();
                    if (map.containsKey(rightRev) && map.get(rightRev) != i) { // gocha, avoid concat with self
                        List<Integer> al = new ArrayList<>();
                        al.add(map.get(rightRev));
                        al.add(i);
                        result.add(al);
                    }
                }
                if (isPalindrome(right)) {
                    String leftRev = new StringBuilder(left).reverse().toString();
                    if (map.containsKey(leftRev) && map.get(leftRev) != i && right.length() != 0) {
                        List<Integer> al = new ArrayList<>();
                        al.add(i);
                        al.add(map.get(leftRev));
                        result.add(al);
                    }
                }
            }
        }
        return result;
    }

    private boolean isPalindrome(String w) {
        int i = 0;
        int j = w.length() - 1;
        while (i < j) {
            if (w.charAt(i++) != w.charAt(j--)) {
                return false;
            }
        }
        return true;
    }
}
