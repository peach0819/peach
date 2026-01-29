package com.peach.algo.LC651_700_toVip;

/**
 * @author feitao.zt
 * @date 2025/11/7
 * 给你一个只包含三种字符的字符串，支持的字符类型分别是 '('、')' 和 '*'。请你检验这个字符串是否为有效字符串，如果是 有效 字符串返回 true 。
 * 有效 字符串符合如下规则：
 * 任何左括号 '(' 必须有相应的右括号 ')'。
 * 任何右括号 ')' 必须有相应的左括号 '(' 。
 * 左括号 '(' 必须在对应的右括号之前 ')'。
 * '*' 可以被视为单个右括号 ')' ，或单个左括号 '(' ，或一个空字符串 ""。
 * 示例 1：
 * 输入：s = "()"
 * 输出：true
 * 示例 2：
 * 输入：s = "(*)"
 * 输出：true
 * 示例 3：
 * 输入：s = "(*))"
 * 输出：true
 * 提示：
 * 1 <= s.length <= 100
 * s[i] 为 '('、')' 或 '*'
 */
public class LC678_valid_parenthesis_string {

    /**
     * 正反都走一遍，结果都>=0, 则有效
     */
    public boolean checkValidString(String s) {
        char[] array = s.toCharArray();
        int num = 0;
        for (int i = 0; i < array.length; i++) {
            char c = array[i];
            if (c == '(' || c == '*') {
                num++;
            } else if (c == ')') {
                num--;
            }
            if (num < 0) {
                return false;
            }
        }
        num = 0;
        for (int i = array.length - 1; i >= 0; i--) {
            char c = array[i];
            if (c == ')' || c == '*') {
                num++;
            } else if (c == '(') {
                num--;
            }
            if (num < 0) {
                return false;
            }
        }
        return true;
    }
}
