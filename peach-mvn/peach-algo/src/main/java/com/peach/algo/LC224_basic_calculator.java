package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/9/3
 * 给你一个字符串表达式 s ，请你实现一个基本计算器来计算并返回它的值。
 * 注意:不允许使用任何将字符串作为数学表达式计算的内置函数，比如 eval() 。
 * 示例 1：
 * 输入：s = "1 + 1"
 * 输出：2
 * 示例 2：
 * 输入：s = " 2-1 + 2 "
 * 输出：3
 * 示例 3：
 * 输入：s = "(1+(4+5+2)-3)+(6+8)"
 * 输出：23
 * 提示：
 * 1 <= s.length <= 3 * 105
 * s 由数字、'+'、'-'、'('、')'、和 ' ' 组成
 * s 表示一个有效的表达式
 * '+' 不能用作一元运算(例如， "+1" 和 "+(2 + 3)" 无效)
 * '-' 可以用作一元运算(即 "-1" 和 "-(2 + 3)" 是有效的)
 * 输入中不存在两个连续的操作符
 * 每个数字和运行的计算将适合于一个有符号的 32位 整数
 */
public class LC224_basic_calculator {

    public static void main(String[] args) {
        int i = new LC224_basic_calculator().calculate("(1+(4+5+2)-3)");
        int j = new LC224_basic_calculator().calculate("(1+11-3)");
        int k = new LC224_basic_calculator().calculate("(4+5+2)");
        int l = new LC224_basic_calculator().calculate("1 + 1");
        int o = 1;
    }

    public int calculate(String s) {
        String s1 = s.replaceAll(" ", "");
        return handle(s1.toCharArray(), 0, s1.length() - 1);
    }

    private int handle(char[] array, int begin, int end) {
        int result = 0;
        boolean positive = true;
        int i = begin;
        int num = 0;
        while (i <= end) {
            char c = array[i];
            if (c == '+') {
                positive = true;
                i++;
            } else if (c == '-') {
                positive = false;
                i++;
            } else if (c == '(') {
                int last = i + 1;
                int temp = 1;
                while (true) {
                    if (array[last] == '(') {
                        temp++;
                    } else if (array[last] == ')') {
                        temp--;
                        if (temp == 0) {
                            break;
                        }
                    }
                    last++;
                }
                int cur = handle(array, i + 1, last - 1);
                if (positive) {
                    result += cur;
                } else {
                    result -= cur;
                }
                i = last + 1;
            } else {
                int cur = c - '0';
                num *= 10;
                num += cur;
                if (i + 1 > end || !isNum(array[i + 1])) {
                    if (positive) {
                        result += num;
                    } else {
                        result -= num;
                    }
                    num = 0;
                }
                i++;
            }
        }
        return result;
    }

    private boolean isNum(char c) {
        return c >= '0' && c <= '9';
    }
}
