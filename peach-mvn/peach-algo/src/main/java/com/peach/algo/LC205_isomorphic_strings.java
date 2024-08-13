package com.peach.algo;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/8/13
 * 给定两个字符串 s 和 t ，判断它们是否是同构的。
 * 如果 s 中的字符可以按某种映射关系替换得到 t ，那么这两个字符串是同构的。
 * 每个出现的字符都应当映射到另一个字符，同时不改变字符的顺序。不同字符不能映射到同一个字符上，相同字符只能映射到同一个字符上，字符可以映射到自己本身。
 * 示例 1:
 * 输入：s = "egg", t = "add"
 * 输出：true
 * 示例 2：
 * 输入：s = "foo", t = "bar"
 * 输出：false
 * 示例 3：
 * 输入：s = "paper", t = "title"
 * 输出：true
 * 提示：
 * 1 <= s.length <= 5 * 104
 * t.length == s.length
 * s 和 t 由任意有效的 ASCII 字符组成
 */
public class LC205_isomorphic_strings {

    public boolean isIsomorphic(String s, String t) {
        if (s.length() == 1) {
            return true;
        }
        char[] ss = s.toCharArray();
        char[] tt = t.toCharArray();
        boolean[] has = new boolean[128];
        boolean[] route = new boolean[ss.length];

        for (int i = 0; i < ss.length; i++) {
            if (route[i]) {
                continue;
            }
            char s1 = ss[i];
            char t1 = tt[i];
            if (has[(int) t1]) {
                return false;
            }
            has[(int) t1] = true;
            for (int j = i + 1; j < ss.length; j++) {
                if (route[i]) {
                    continue;
                }
                if (ss[j] == s1) {
                    if (tt[j] != t1) {
                        return false;
                    } else {
                        route[j] = true;
                    }
                }
            }
        }
        return true;
    }

    public boolean isIsomorphic1(String s, String t) {
        if (s.length() == 1) {
            return true;
        }
        char[] ss = s.toCharArray();
        char[] tt = t.toCharArray();

        Map<Character, Character> maps = new HashMap<>();
        Map<Character, Character> mapt = new HashMap<>();
        for (int i = 0; i < ss.length; i++) {
            char s1 = ss[i];
            char t1 = tt[i];

            Character t2 = maps.get(s1);
            Character s2 = mapt.get(t1);
            if (t2 != null && t2 != t1) {
                return false;
            }
            if (s2 != null && s2 != s1) {
                return false;
            }
            if (t2 == null) {
                maps.put(s1, t1);
            }
            if (s2 == null) {
                mapt.put(t1, s1);
            }
        }
        return true;
    }
}
