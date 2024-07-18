package com.peach.algo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/7/18
 * 给你一个字符串 s 、一个字符串 t 。返回 s 中涵盖 t 所有字符的最小子串。如果 s 中不存在涵盖 t 所有字符的子串，则返回空字符串 "" 。
 * 注意：
 * 对于 t 中重复字符，我们寻找的子字符串中该字符数量必须不少于 t 中该字符数量。
 * 如果 s 中存在这样的子串，我们保证它是唯一的答案。
 * 示例 1：
 * 输入：s = "ADOBECODEBANC", t = "ABC"
 * 输出："BANC"
 * 解释：最小覆盖子串 "BANC" 包含来自字符串 t 的 'A'、'B' 和 'C'。
 * 示例 2：
 * 输入：s = "a", t = "a"
 * 输出："a"
 * 解释：整个字符串 s 是最小覆盖子串。
 * 示例 3:
 * 输入: s = "a", t = "aa"
 * 输出: ""
 * 解释: t 中两个字符 'a' 均应包含在 s 的子串中，
 * 因此没有符合条件的子字符串，返回空字符串。
 * 提示：
 * m == s.length
 * n == t.length
 * 1 <= m, n <= 105
 * s 和 t 由英文字母组成
 * 进阶：你能设计一个在 o(m+n) 时间内解决此问题的算法吗？
 */
public class LC76_minimum_window_substring {

    public String minWindow1(String s, String t) {
        if (t.length() > s.length()) {
            return "";
        }
        if (s.contains(t)) {
            return t;
        }
        Map<Character, List<Integer>> map = new HashMap<>();
        char[] chars = s.toCharArray();
        for (int i = 0; i < chars.length; i++) {
            char c = chars[i];
            map.putIfAbsent(c, new ArrayList<>());
            map.get(c).add(i);
        }
        Map<Character, Integer> numMap = new HashMap<>();
        char[] charst = t.toCharArray();
        for (char c : charst) {
            numMap.put(c, numMap.getOrDefault(c, 0) + 1);
        }

        int max = Integer.MAX_VALUE;
        int maxBegin = 0;
        int maxEnd = 0;
        int curMax;
        int curMaxEnd;
        boolean finish = false;
        boolean hasResult = false;
        List<Integer> list;
        for (int i = 0; i < chars.length; i++) {
            char c = chars[i];
            if (!numMap.containsKey(c)) {
                continue;
            }
            curMaxEnd = i;
            for (Map.Entry<Character, Integer> entry : numMap.entrySet()) {
                Character needC = entry.getKey();
                Integer needValue = entry.getValue();
                if (!map.containsKey(needC)) {
                    finish = true;
                    break;
                }
                list = new ArrayList<>();
                for (Integer integer : map.get(needC)) {
                    if (integer >= i) {
                        list.add(integer);
                    }
                }
                if (list.size() < needValue) {
                    finish = true;
                    break;
                }
                curMaxEnd = Math.max(curMaxEnd, list.get(needValue - 1));
            }
            if (finish) {
                break;
            }
            curMax = curMaxEnd - i;
            if (curMax < max) {
                max = curMax;
                maxBegin = i;
                maxEnd = curMaxEnd;
                hasResult = true;
            }
        }
        if (hasResult) {
            return s.substring(maxBegin, maxEnd + 1);
        }
        return "";
    }

    /**
     * 官方题解，用滑动窗口+双指针解决
     */
    public String minWindow(String S, String t) {
        char[] s = S.toCharArray();
        int m = s.length;
        int ansLeft = -1;
        int ansRight = m;
        int left = 0;
        int less = 0;
        int[] cntS = new int[128]; // s 子串字母的出现次数
        int[] cntT = new int[128]; // t 中字母的出现次数
        for (char c : t.toCharArray()) {
            if (cntT[c]++ == 0) {
                less++; // 有 less 种字母的出现次数 < t 中的字母出现次数
            }
        }
        for (int right = 0; right < m; right++) { // 移动子串右端点
            char c = s[right]; // 右端点字母（移入子串）
            if (++cntS[c] == cntT[c]) {
                less--; // c 的出现次数从 < 变成 >=
            }
            while (less == 0) { // 涵盖：所有字母的出现次数都是 >=
                if (right - left < ansRight - ansLeft) { // 找到更短的子串
                    ansLeft = left; // 记录此时的左右端点
                    ansRight = right;
                }
                char x = s[left++]; // 左端点字母（移出子串）
                if (cntS[x]-- == cntT[x]) {
                    less++; // x 的出现次数从 >= 变成 <
                }
            }
        }
        return ansLeft < 0 ? "" : S.substring(ansLeft, ansRight + 1);
    }

}
