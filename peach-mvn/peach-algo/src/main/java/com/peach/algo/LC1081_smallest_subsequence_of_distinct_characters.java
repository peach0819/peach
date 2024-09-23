package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/9/23
 * 返回 s 字典序最小的
 * 子序列
 * ，该子序列包含 s 的所有不同字符，且只包含一次。
 * 示例 1：
 * 输入：s = "bcabc"
 * 输出："abc"
 * 示例 2：
 * 输入：s = "cbacdcbc"
 * 输出："acdb"
 * 提示：
 * 1 <= s.length <= 1000
 * s 由小写英文字母组成
 */
public class LC1081_smallest_subsequence_of_distinct_characters {

    public String smallestSubsequence(String s) {
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
