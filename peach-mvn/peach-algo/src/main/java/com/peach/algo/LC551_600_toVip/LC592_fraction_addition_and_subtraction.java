package com.peach.algo.LC551_600_toVip;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2025/7/23
 * 给定一个表示分数加减运算的字符串 expression ，你需要返回一个字符串形式的计算结果。
 * 这个结果应该是不可约分的分数，即 最简分数。 如果最终结果是一个整数，例如 2，你需要将它转换成分数形式，其分母为 1。所以在上述例子中, 2 应该被转换为 2/1。
 * 示例 1:
 * 输入: expression = "-1/2+1/2"
 * 输出: "0/1"
 * 示例 2:
 * 输入: expression = "-1/2+1/2+1/3"
 * 输出: "1/3"
 * 示例 3:
 * 输入: expression = "1/3-1/2"
 * 输出: "-1/6"
 * 提示:
 * 输入和输出字符串只包含 '0' 到 '9' 的数字，以及 '/', '+' 和 '-'。
 * 输入和输出分数格式均为 ±分子/分母。如果输入的第一个分数或者输出的分数是正数，则 '+' 会被省略掉。
 * 输入只包含合法的 最简分数，每个分数的分子与分母的范围是 [1,10]。 如果分母是 1，意味着这个分数实际上是一个整数。
 * 输入的分数个数范围是 [1,10]。
 * 最终结果 的分子与分母保证是 32 位整数范围内的有效整数。
 */
public class LC592_fraction_addition_and_subtraction {

    public static void main(String[] args) {
        String s = "1/3-1/2";
        String s1 = new LC592_fraction_addition_and_subtraction().fractionAddition(s);
    }

    public String fractionAddition(String expression) {
        List<int[]> list = build(expression);
        long up = 0;
        long down = 1;
        for (int[] ints : list) {
            if (down % ints[1] != 0) {
                down *= ints[1];
            }
        }
        for (int[] ints : list) {
            up += ints[0] * down / ints[1];
        }
        if (up % down == 0) {
            return up / down + "/1";
        }
        long gcd = gcd(Math.abs(up), Math.abs(down));
        return up / gcd + "/" + down / gcd;
    }

    //辗转相除法取最大公约数
    public long gcd(long a, long b) {
        long remainder = a % b;
        while (remainder != 0) {
            a = b;
            b = remainder;
            remainder = a % b;
        }
        return b;
    }

    private List<int[]> build(String expression) {
        List<int[]> list = new ArrayList<>();
        boolean positive = true;
        boolean start = false;
        int first = 0;
        int second = 0;
        int num = 0;
        for (int i = 0; i < expression.length(); i++) {
            char c = expression.charAt(i);
            if (c == '+' || c == '-') {
                second = num;
                if (start) {
                    list.add(new int[]{ positive ? first : -first, second });
                    num = 0;
                }
                start = false;
                positive = c == '+';
            } else if (c == '/') {
                first = num;
                num = 0;
            } else {
                start = true;
                num = num * 10 + c - '0';
            }
        }
        if (start) {
            second = num;
            list.add(new int[]{ positive ? first : -first, second });
        }
        return list;
    }
}
