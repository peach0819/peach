package com.peach.algo.LC501_550_toVip;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2025/3/7
 * 给定字符串列表 strs ，返回其中 最长的特殊序列 的长度。如果最长特殊序列不存在，返回 -1 。
 * 特殊序列 定义如下：该序列为某字符串 独有的子序列（即不能是其他字符串的子序列）。
 * s 的 子序列可以通过删去字符串 s 中的某些字符实现。
 * 例如，"abc" 是 "aebdc" 的子序列，因为您可以删除"aebdc"中的下划线字符来得到 "abc" 。"aebdc"的子序列还包括"aebdc"、 "aeb" 和 "" (空字符串)。
 * 示例 1：
 * 输入: strs = ["aba","cdc","eae"]
 * 输出: 3
 * 示例 2:
 * 输入: strs = ["aaa","aaa","aa"]
 * 输出: -1
 * 提示:
 * 2 <= strs.length <= 50
 * 1 <= strs[i].length <= 10
 * strs[i] 只包含小写英文字母
 */
public class LC522_longest_uncommon_subsequence_ii {

    public static void main(String[] args) {
        int i = new LC522_longest_uncommon_subsequence_ii().findLUSlength(
                new String[]{ "aaaaa", "aaaaa", "aaa", "aaa", "aaaaa" });
        i = 1;
    }

    public int findLUSlength(String[] strs) {
        Arrays.sort(strs, (a, b) -> b.length() - a.length());
        int index = 0;
        Set<String> set;
        Set<String> cur;
        Set<String> history = new HashSet<>();
        while (index < strs.length) {
            int curLength = strs[index].length();
            set = new HashSet<>();
            cur = new HashSet<>();
            while (index < strs.length) {
                String str = strs[index];
                if (str.length() != curLength) {
                    break;
                }
                if (cur.contains(str)) {
                    set.remove(str);
                } else {
                    cur.add(str);
                    set.add(str);
                }
                index++;
            }
            if (!set.isEmpty()) {
                for (String s : set) {
                    if (!contains(history, s)) {
                        return curLength;
                    }
                }
            } else {
                history.add(strs[index - 1]);
            }
        }
        return -1;
    }

    private boolean contains(Set<String> history, String str) {
        for (String s : history) {
            if (contains(s, str)) {
                return true;
            }
        }
        return false;
    }

    private boolean contains(String longStr, String shortStr) {
        int index = 0;
        for (int i = 0; i < shortStr.length(); i++) {
            char c = shortStr.charAt(i);
            boolean match = false;
            while (index < longStr.length()) {
                if (longStr.charAt(index) == c) {
                    match = true;
                    index++;
                    break;
                }
                index++;
            }
            if (!match) {
                return false;
            }
        }
        return true;
    }

}
