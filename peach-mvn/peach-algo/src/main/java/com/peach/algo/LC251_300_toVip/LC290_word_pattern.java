package com.peach.algo.LC251_300_toVip;

import java.util.HashSet;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/9/12
 * 给定一种规律 pattern 和一个字符串 s ，判断 s 是否遵循相同的规律。
 * 这里的 遵循 指完全匹配，例如， pattern 里的每个字母和字符串 s 中的每个非空单词之间存在着双向连接的对应规律。
 * 示例1:
 * 输入: pattern = "abba", s = "dog cat cat dog"
 * 输出: true
 * 示例 2:
 * 输入:pattern = "abba", s = "dog cat cat fish"
 * 输出: false
 * 示例 3:
 * 输入: pattern = "aaaa", s = "dog cat cat dog"
 * 输出: false
 * 提示:
 * 1 <= pattern.length <= 300
 * pattern 只包含小写英文字母
 * 1 <= s.length <= 3000
 * s 只包含小写英文字母和 ' '
 * s 不包含 任何前导或尾随对空格
 * s 中每个单词都被 单个空格 分隔
 */
public class LC290_word_pattern {

    public boolean wordPattern(String pattern, String s) {
        String[] ss = s.split(" ");
        char[] p = pattern.toCharArray();
        if (ss.length != p.length) {
            return false;
        }
        String[] map = new String[26];
        Set<String> set = new HashSet<>();
        for (int i = 0; i < p.length; i++) {
            int index = p[i] - 'a';
            String curS = ss[i];
            String cache = map[index];
            if (cache != null) {
                if (!curS.equals(cache)) {
                    return false;
                }
            } else {
                if (set.contains(curS)) {
                    return false;
                }
                map[index] = curS;
                set.add(curS);
            }
        }
        return true;
    }
}
