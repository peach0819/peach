package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/9/10
 * 给你一个由数字和运算符组成的字符串 expression ，按不同优先级组合数字和运算符，计算并返回所有可能组合的结果。你可以 按任意顺序 返回答案。
 * 生成的测试用例满足其对应输出值符合 32 位整数范围，不同结果的数量不超过 104 。
 * 示例 1：
 * 输入：expression = "2-1-1"
 * 输出：[0,2]
 * 解释：
 * ((2-1)-1) = 0
 * (2-(1-1)) = 2
 * 示例 2：
 * 输入：expression = "2*3-4*5"
 * 输出：[-34,-14,-10,-10,10]
 * 解释：
 * (2*(3-(4*5))) = -34
 * ((2*3)-(4*5)) = -14
 * ((2*(3-4))*5) = -10
 * (2*((3-4)*5)) = -10
 * (((2*3)-4)*5) = 10
 * 提示：
 * 1 <= expression.length <= 20
 * expression 由数字和算符 '+'、'-' 和 '*' 组成。
 * 输入表达式中的所有整数值在范围 [0, 99]
 */
public class LC241_different_ways_to_add_parentheses {

    List<Integer> result = new ArrayList<>();

    public List<Integer> diffWaysToCompute(String expression) {
        List<Integer> numList = new ArrayList<>();
        List<Character> operateList = new ArrayList<>();
        int num = 0;
        for (char c : expression.toCharArray()) {
            if (isNum(c)) {
                num = num * 10 + (c - '0');
            } else {
                numList.add(num);
                num = 0;

                operateList.add(c);
            }
        }
        numList.add(num);
        handle(numList, operateList);
        return result;
    }

    private boolean isNum(char c) {
        return c >= '0' && c <= '9';
    }

    private void handle(List<Integer> numList, List<Character> operateList) {
        if (operateList.size() == 1) {
            result.add(cal(numList.get(0), numList.get(1), operateList.get(0)));
            return;
        }
        int i = 0;
        while (i < operateList.size()) {
            Character c = operateList.get(i);
            Integer num1 = numList.get(i);
            Integer num2 = numList.get(i + 1);
            numList.remove(i + 1);
            numList.remove(i);
            operateList.remove(i);
            numList.add(i, cal(num1, num2, c));
            handle(numList, operateList);
            numList.remove(i);
            operateList.add(i, c);
            numList.add(i, num1);
            numList.add(i + 1, num2);
            i++;
        }
    }

    private int cal(Integer num1, Integer num2, Character c) {
        if (c == '+') {
            return num1 + num2;
        } else if (c == '-') {
            return num1 - num2;
        }
        return num1 * num2;
    }
}
