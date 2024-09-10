package com.peach.algo.LC201_250_toVip;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/9/5
 * 给你一个字符串表达式 s ，请你实现一个基本计算器来计算并返回它的值。
 * 整数除法仅保留整数部分。
 * 你可以假设给定的表达式总是有效的。所有中间结果将在 [-231, 231 - 1] 的范围内。
 * 注意：不允许使用任何将字符串作为数学表达式计算的内置函数，比如 eval() 。
 * 示例 1：
 * 输入：s = "3+2*2"
 * 输出：7
 * 示例 2：
 * 输入：s = " 3/2 "
 * 输出：1
 * 示例 3：
 * 输入：s = " 3+5 / 2 "
 * 输出：5
 * 提示：
 * 1 <= s.length <= 3 * 105
 * s 由整数和算符 ('+', '-', '*', '/') 组成，中间由一些空格隔开
 * s 表示一个 有效表达式
 * 表达式中的所有整数都是非负整数，且在范围 [0, 231 - 1] 内
 * 题目数据保证答案是一个 32-bit 整数
 */
public class LC227_basic_calculator_ii {

    public static void main(String[] args) {
        new LC227_basic_calculator_ii().calculate("3+2*2");
    }

    public int calculate(String s) {
        char[] chars = s.toCharArray();
        List<Character> operatorList = new ArrayList<>();
        List<Integer> numList = new ArrayList<>();
        int num = 0;
        for (int i = 0; i < chars.length; i++) {
            char c = chars[i];
            if (c == ' ') {
                continue;
            }
            if (isOperator(c)) {
                numList.add(num);
                operatorList.add(c);
                num = 0;
            } else {
                num *= 10;
                num += c - '0';
            }
        }
        numList.add(num);
        int i = 0;
        while (i < operatorList.size()) {
            if (operatorList.get(i) == '*') {
                Integer num2 = numList.remove(i + 1);
                Integer num1 = numList.remove(i);
                Integer newNum = num1 * num2;
                operatorList.remove(i);
                numList.add(i, newNum);
            } else if (operatorList.get(i) == '/') {
                Integer num2 = numList.remove(i + 1);
                Integer num1 = numList.remove(i);
                Integer newNum = num1 / num2;
                operatorList.remove(i);
                numList.add(i, newNum);
            } else {
                i++;
            }
        }
        int result = numList.get(0);
        for (int i1 = 0; i1 < operatorList.size(); i1++) {
            Character c = operatorList.get(i1);
            if (c == '+') {
                result += numList.get(i1 + 1);
            } else {
                result -= numList.get(i1 + 1);
            }
        }
        return result;
    }

    private boolean isOperator(char c) {
        return c == '+' || c == '-' || c == '*' || c == '/';
    }
}
