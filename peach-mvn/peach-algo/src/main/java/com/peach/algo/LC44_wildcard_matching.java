package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/7/11
 * 给你一个输入字符串 (s) 和一个字符模式 (p) ，请你实现一个支持 '?' 和 '*' 匹配规则的通配符匹配：
 * '?' 可以匹配任何单个字符。
 * '*' 可以匹配任意字符序列（包括空字符序列）。
 * 判定匹配成功的充要条件是：字符模式必须能够 完全匹配 输入字符串（而不是部分匹配）。
 * 示例 1：
 * 输入：s = "aa", p = "a"
 * 输出：false
 * 解释："a" 无法匹配 "aa" 整个字符串。
 * 示例 2：
 * 输入：s = "aa", p = "*"
 * 输出：true
 * 解释：'*' 可以匹配任意字符串。
 * 示例 3：
 * 输入：s = "cb", p = "?a"
 * 输出：false
 * 解释：'?' 可以匹配 'c', 但第二个 'a' 无法匹配 'b'。
 * 提示：
 * 0 <= s.length, p.length <= 2000
 * s 仅由小写英文字母组成
 * p 仅由小写英文字母、'?' 或 '*' 组成
 */
public class LC44_wildcard_matching {

    public static void main(String[] args) {
        new LC44_wildcard_matching().isMatch("aa", "*");
    }

    char[] chars;
    char[] charp;

    Boolean[][] a;

    public boolean isMatch(String s, String p) {
        if (s.isEmpty() && p.isEmpty()) {
            return true;
        }
        while (p.contains("**")) {
            p = p.replaceAll("\\*\\*", "*");
        }
        chars = s.toCharArray();
        charp = p.toCharArray();
        a = new Boolean[s.length() + 1][p.length() + 1];
        return handle(0, 0);
    }

    private boolean doHandle(int s, int p) {
        Boolean aa = a[s][p];
        if (aa != null) {
            return aa;
        }
        boolean result = handle(s, p);
        a[s][p] = result;
        return result;
    }

    private boolean handle(int s, int p) {
        if (p == charp.length) {
            return s == chars.length;
        }
        char cp = charp[p];
        if (s == chars.length) {
            if (cp == '*') {
                return doHandle(s, p + 1);
            } else {
                return false;
            }
        }
        char cs = chars[s];
        if ('*' == cp) {
            return doHandle(s + 1, p + 1) || doHandle(s + 1, p) || doHandle(s, p + 1);
        }

        if (cp != '?' && cp != cs) {
            return false;
        }
        return doHandle(s + 1, p + 1);
    }
}
