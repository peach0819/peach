package com.peach.algo.LC0_50;

/**
 * @author feitao.zt
 * @date 2023/7/10
 * 给定一个只包括 '('，')'，'{'，'}'，'['，']' 的字符串 s ，判断字符串是否有效。
 * 有效字符串需满足：
 * 左括号必须用相同类型的右括号闭合。
 * 左括号必须以正确的顺序闭合。
 * 每个右括号都有一个对应的相同类型的左括号。
 *  
 * 示例 1：
 * 输入：s = "()"
 * 输出：true
 * 示例 2：
 * 输入：s = "()[]{}"
 * 输出：true
 * 示例 3：
 * 输入：s = "(]"
 * 输出：false
 *  
 * 提示：
 * 1 <= s.length <= 104
 * s 仅由括号 '()[]{}' 组成
 * 来源：力扣（LeetCode）
 * 链接：https://leetcode.cn/problems/valid-parentheses
 * 著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
 */
public class LC20_valid_parentheses {

    public boolean isValid(String s) {
        char[] chars = new char[s.length()];
        int index = 0;
        for (char c : s.toCharArray()) {
            if (isLeft(c)) {
                chars[index++] = c;
            } else if (index == 0 || chars[--index] != getLeft(c)) {
                return false;
            }
        }
        return index == 0;
    }

    private boolean isLeft(char c) {
        return c == '{' || c == '(' || c == '[';
    }

    private char getLeft(char c) {
        if (c == '}') {
            return '{';
        }
        if (c == ')') {
            return '(';
        }
        if (c == ']') {
            return '[';
        }
        throw new IllegalArgumentException();
    }

}
