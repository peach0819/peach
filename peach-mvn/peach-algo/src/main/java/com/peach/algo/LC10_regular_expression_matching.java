package com.peach.algo;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/6/27
 * 给你一个字符串 s 和一个字符规律 p，请你来实现一个支持 '.' 和 '*' 的正则表达式匹配。
 * '.' 匹配任意单个字符
 * '*' 匹配零个或多个前面的那一个元素
 * 所谓匹配，是要涵盖 整个 字符串 s的，而不是部分字符串。
 * 示例 1：
 * 输入：s = "aa", p = "a"
 * 输出：false
 * 解释："a" 无法匹配 "aa" 整个字符串。
 * 示例 2:
 * 输入：s = "aa", p = "a*"
 * 输出：true
 * 解释：因为 '*' 代表可以匹配零个或多个前面的那一个元素, 在这里前面的元素就是 'a'。因此，字符串 "aa" 可被视为 'a' 重复了一次。
 * 示例 3：
 * 输入：s = "ab", p = ".*"
 * 输出：true
 * 解释：".*" 表示可匹配零个或多个（'*'）任意字符（'.'）。
 * 提示：
 * 1 <= s.length <= 20
 * 1 <= p.length <= 20
 * s 只包含从 a-z 的小写字母。
 * p 只包含从 a-z 的小写字母，以及字符 . 和 *。
 * 保证每次出现字符 * 时，前面都匹配到有效的字符
 */
public class LC10_regular_expression_matching {

    public static void main(String[] args) {
        boolean match = new LC10_regular_expression_matching().isMatch("a", ".*");
    }

    private char[] ss;
    private char[] pp;
    private Map<String, Boolean> resultMap = new HashMap<>();

    public boolean isMatch(String s, String p) {
        if (s.equals(p)) {
            return true;
        }
        ss = s.toCharArray();
        pp = p.toCharArray();
        return match(0, 0, '[', false);
    }

    private boolean match(int sbegin, int pbegin, char last, boolean stay) {
        String key = sbegin + "_" + pbegin;
        if (resultMap.containsKey(key)) {
            return resultMap.get(key);
        }
        boolean result;
        if (sbegin == ss.length) {
            if (canStep(pp, pbegin)) {
                return match(sbegin, pbegin + 2, last, false);
            }
            if (pbegin < pp.length && pp[pbegin] == '*') {
                return match(sbegin, pbegin + 1, last, false);
            }
            result = pbegin == pp.length;
            resultMap.put(key, result);
            return result;
        }
        if (pbegin == pp.length) {
            result = false;
            resultMap.put(key, result);
            return result;
        }
        char s = ss[sbegin];
        boolean canStay = stay || pp[pbegin] == '*';
        char p = canStay ? last : pp[pbegin];
        if (!match(s, p)) {
            if (canStep(pp, pbegin)) {
                return match(sbegin, pbegin + 2, last, false);
            }
            if (pp[pbegin] == '*') {
                return match(sbegin, pbegin + 1, last, false);
            }
            return false;
        }
        boolean a = match(sbegin + 1, pbegin + 1, p, false);
        boolean b = false;
        if (canStay) {
            b = match(sbegin + 1, pbegin, p, true);
        }
        boolean c = false;
        if (canStep(pp, pbegin)) {
            c = match(sbegin, pbegin + 2, last, false);
        }
        boolean d = false;
        if (pp[pbegin] == '*') {
            d = match(sbegin, pbegin + 1, p, false);
        }
        result = a || b || c || d;
        resultMap.put(key, result);
        return result;
    }

    private boolean canStep(char[] pp, int pbegin) {
        return (pbegin + 1 < pp.length) && pp[pbegin + 1] == '*';
    }

    private boolean match(char s, char p) {
        if (p == '.') {
            return true;
        }
        return s == p;
    }
}
