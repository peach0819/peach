package com.peach.algo.LC351_400_toVip;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2024/10/16
 * 给定一个字符串 s ，找到 它的第一个不重复的字符，并返回它的索引 。如果不存在，则返回 -1 。
 * 示例 1：
 * 输入: s = "leetcode"
 * 输出: 0
 * 示例 2:
 * 输入: s = "loveleetcode"
 * 输出: 2
 * 示例 3:
 * 输入: s = "aabb"
 * 输出: -1
 * 提示:
 * 1 <= s.length <= 105
 * s 只包含小写字母
 */
public class LC387_first_unique_character_in_a_string {

    public int firstUniqChar(String s) {
        int[] array = new int[26];
        Arrays.fill(array, -1);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (array[c - 'a'] == -1) {
                array[c - 'a'] = i;
            } else if (array[c - 'a'] == -2) {
                continue;
            } else {
                array[c - 'a'] = -2;
            }
        }
        int result = Integer.MAX_VALUE;
        for (int i : array) {
            if (i >= 0) {
                result = Math.min(result, i);
            }
        }
        return result == Integer.MAX_VALUE ? -1 : result;
    }
}
