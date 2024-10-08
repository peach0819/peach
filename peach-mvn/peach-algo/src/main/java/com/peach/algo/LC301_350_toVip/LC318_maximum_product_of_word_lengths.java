package com.peach.algo.LC301_350_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/23
 * 给你一个字符串数组 words ，找出并返回 length(words[i]) * length(words[j]) 的最大值，并且这两个单词不含有公共字母。如果不存在这样的两个单词，返回 0 。
 * 示例 1：
 * 输入：words = ["abcw","baz","foo","bar","xtfn","abcdef"]
 * 输出：16
 * 解释：这两个单词为 "abcw", "xtfn"。
 * 示例 2：
 * 输入：words = ["a","ab","abc","d","cd","bcd","abcd"]
 * 输出：4
 * 解释：这两个单词为 "ab", "cd"。
 * 示例 3：
 * 输入：words = ["a","aa","aaa","aaaa"]
 * 输出：0
 * 解释：不存在这样的两个单词。
 * 提示：
 * 2 <= words.length <= 1000
 * 1 <= words[i].length <= 1000
 * words[i] 仅包含小写字母
 */
public class LC318_maximum_product_of_word_lengths {

    public static void main(String[] args) {
        int i = new LC318_maximum_product_of_word_lengths()
                .maxProduct(new String[]{ "abcw", "baz", "foo", "bar", "xtfn", "abcdef" });
        i = 1;
    }

    public int maxProduct1(String[] words) {
        int maxLength = 0;
        for (String word : words) {
            maxLength = Math.max(maxLength, word.length());
        }
        int max = 0;
        for (int i = 0; i < words.length - 1; i++) {
            String curi = words[i];
            if (curi.length() < max / maxLength) {
                continue;
            }
            int curMaxLength = 0;
            for (int j = i + 1; j < words.length; j++) {
                String curj = words[j];
                if (curj.length() < curMaxLength) {
                    continue;
                }
                if (isCross(curi, curj)) {
                    curMaxLength = Math.max(curMaxLength, curj.length());
                    max = Math.max(max, curi.length() * curj.length());
                }
            }
        }
        return max;
    }

    private boolean isCross(String s1, String s2) {
        int[] array = new int[26];
        for (char c : s1.toCharArray()) {
            array[c - 'a']++;
        }
        for (char c : s2.toCharArray()) {
            if (array[c - 'a'] != 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * 官方解法，位掩码
     */
    public int maxProduct(String[] words) {
        int[] mask = new int[words.length];
        int maxLength = 0;
        for (int i = 0; i < words.length; i++) {
            String cur = words[i];
            maxLength = Math.max(maxLength, cur.length());
            int m = 0;
            for (char c : cur.toCharArray()) {
                m = m | (1 << (c - 'a'));
            }
            mask[i] = m;
        }
        int max = 0;
        for (int i = 0; i < words.length - 1; i++) {
            String curi = words[i];
            if (curi.length() < max / maxLength) {
                continue;
            }
            int curMaxLength = 0;
            for (int j = i + 1; j < words.length; j++) {
                String curj = words[j];
                if (curj.length() < curMaxLength) {
                    continue;
                }
                if ((mask[i] & mask[j]) == 0) {
                    curMaxLength = Math.max(curMaxLength, curj.length());
                    max = Math.max(max, curi.length() * curj.length());
                }
            }
        }
        return max;
    }

}
