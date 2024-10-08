package com.peach.algo.LC301_350_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/23
 * 给你一个字符串 s ，请你去除字符串中重复的字母，使得每个字母只出现一次。需保证 返回结果的
 * 字典序
 * 最小（要求不能打乱其他字符的相对位置）。
 * 示例 1：
 * 输入：s = "bcabc"
 * 输出："abc"
 * 示例 2：
 * 输入：s = "cbacdcbc"
 * 输出："acdb"
 * 提示：
 * 1 <= s.length <= 104
 * s 由小写英文字母组成
 */
public class LC316_remove_duplicate_letters {

    public String removeDuplicateLetters(String s) {
        int[] count = new int[26];
        char[] chars = s.toCharArray();
        for (char c : chars) {
            count[c - 'a']++;
        }
        boolean[] has = new boolean[26];

        StringBuilder result = new StringBuilder();
        for (int i = 0; i < chars.length; i++) {
            char c = chars[i];
            count[c - 'a']--;
            if (has[c - 'a']) {
                continue;
            }

            while (true) {
                if (result.length() == 0) {
                    break;
                }
                char last = result.charAt(result.length() - 1);
                if (c > last) {
                    break;
                }
                if (count[last - 'a'] == 0) {
                    break;
                }
                result.deleteCharAt(result.length() - 1);
                has[last - 'a'] = false;
            }
            result.append(c);
            has[c - 'a'] = true;
        }
        return result.toString();
    }
}
