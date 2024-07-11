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

    char[] chars;
    char[] charp;

    Boolean[][] a;

    public boolean isMatch1(String s, String p) {
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

    public static void main(String[] args) {
        new LC44_wildcard_matching().isMatch("", "******");
    }

    public boolean isMatch(String s, String p) {
        if (s.isEmpty()) {
            return p.replaceAll("\\*", "").equals("");
        }
        if (p.isEmpty()) {
            return false;
        }

        boolean[][] array = new boolean[s.length() + 1][p.length() + 1];
        char[] ss = s.toCharArray();
        char[] pp = p.toCharArray();

        char s0 = ss[0];
        char p0 = pp[0];
        array[0][0] = s0 == p0 || p0 == '?' || p0 == '*';
        for (int i = 1; i < s.length(); i++) {
            array[i][0] = array[i - 1][0] && p0 == '*';
        }

        boolean match = p0 != '*';
        for (int i = 1; i < p.length(); i++) {
            if (!array[0][i - 1]) {
                break;
            }
            if (pp[i] == '*') {
                array[0][i] = true;
            } else if (!match) {
                if (pp[i] == s0 || pp[i] == '?') {
                    array[0][i] = true;
                    match = true;
                } else {
                    array[0][i] = false;
                }
            } else {
                break;
            }
        }

        for (int i = 1; i < s.length(); i++) {
            for (int j = 1; j < p.length(); j++) {
                char s1 = ss[i];
                char p1 = pp[j];
                if (p1 != '*') {
                    array[i][j] = array[i - 1][j - 1] && (p1 == '?' || s1 == p1);
                } else {
                    array[i][j] = array[i - 1][j] || array[i][j - 1] || array[i - 1][j - 1];
                }
            }
        }
        return array[s.length() - 1][p.length() - 1];
    }
}
