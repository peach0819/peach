package com.peach.algo.LC551_600_toVip;

import java.util.HashSet;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2025/6/30
 * 给你两个字符串 s1 和 s2 ，写一个函数来判断 s2 是否包含 s1 的 排列。如果是，返回 true ；否则，返回 false 。
 * 换句话说，s1 的排列之一是 s2 的 子串 。
 * 示例 1：
 * 输入：s1 = "ab" s2 = "eidbaooo"
 * 输出：true
 * 解释：s2 包含 s1 的排列之一 ("ba").
 * 示例 2：
 * 输入：s1= "ab" s2 = "eidboaoo"
 * 输出：false
 * 提示：
 * 1 <= s1.length, s2.length <= 104
 * s1 和 s2 仅包含小写字母
 */
public class LC567_permutation_in_string {

    public static void main(String[] args) {
        System.out.println(new LC567_permutation_in_string().checkInclusion("ab", "eidbaooo"));
    }

    public boolean checkInclusion(String s1, String s2) {
        if (s2.length() < s1.length()) {
            return false;
        }
        int[] map = new int[26];
        Set<Integer> negList = new HashSet<>();

        //初始化
        for (int i = 0; i < s1.length(); i++) {
            char c1 = s2.charAt(i);
            char c2 = s1.charAt(i);
            map[c1 - 'a']++;
            map[c2 - 'a']--;
            if (map[c1 - 'a'] >= 0) {
                negList.remove(c1 - 'a');
            }
            if (map[c2 - 'a'] < 0) {
                negList.add(c2 - 'a');
            }
        }
        if (negList.isEmpty()) {
            return true;
        }
        for (int i = s1.length(); i < s2.length(); i++) {
            char c1 = s2.charAt(i);
            char c2 = s2.charAt(i - s1.length());
            map[c1 - 'a']++;
            map[c2 - 'a']--;
            if (map[c1 - 'a'] >= 0) {
                negList.remove(c1 - 'a');
            }
            if (map[c2 - 'a'] < 0) {
                negList.add(c2 - 'a');
            }
            if (negList.isEmpty()) {
                return true;
            }
        }
        return false;
    }
}
