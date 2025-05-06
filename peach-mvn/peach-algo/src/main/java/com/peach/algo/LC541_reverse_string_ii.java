package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/5/6
 * 给定一个字符串 s 和一个整数 k，从字符串开头算起，每计数至 2k 个字符，就反转这 2k 字符中的前 k 个字符。
 * 如果剩余字符少于 k 个，则将剩余字符全部反转。
 * 如果剩余字符小于 2k 但大于或等于 k 个，则反转前 k 个字符，其余字符保持原样。
 * 示例 1：
 * 输入：s = "abcdefg", k = 2
 * 输出："bacdfeg"
 * 示例 2：
 * 输入：s = "abcd", k = 2
 * 输出："bacd"
 * 提示：
 * 1 <= s.length <= 104
 * s 仅由小写英文组成
 * 1 <= k <= 104
 */
public class LC541_reverse_string_ii {

    public String reverseStr(String s, int k) {
        int length = s.length() / k + 1;
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < length; i++) {
            if (i % 2 == 0) {
                sb.append(new StringBuilder(s.substring(i * k, Math.min(i * k + k, s.length()))).reverse());
            } else {
                sb.append(s, i * k, Math.min(i * k + k, s.length()));
            }
        }
        return sb.toString();
    }
}
