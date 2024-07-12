package com.peach.algo.LC0_50;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/6/28
 * 数字 n 代表生成括号的对数，请你设计一个函数，用于能够生成所有可能的并且 有效的 括号组合。
 * 示例 1：
 * 输入：n = 3
 * 输出：["((()))","(()())","(())()","()(())","()()()"]
 * 示例 2：
 * 输入：n = 1
 * 输出：["()"]
 * 提示：
 * 1 <= n <= 8
 */
public class LC22_generate_parentheses {

    private List<String> result;

    public List<String> generateParenthesis(int n) {
        result = new ArrayList<>();
        char[] chars = new char[n * 2];
        build(chars, 0, n, n);
        return result;
    }

    private void build(char[] chars, int index, int begin, int end) {
        if (begin < 0 || end < 0) {
            return;
        }
        if (begin == 0 && end == 0) {
            result.add(new String(chars));
            return;
        }
        if (begin < end) {
            chars[index] = ')';
            build(chars, index + 1, begin, end - 1);
        }
        chars[index] = '(';
        build(chars, index + 1, begin - 1, end);
    }
}
