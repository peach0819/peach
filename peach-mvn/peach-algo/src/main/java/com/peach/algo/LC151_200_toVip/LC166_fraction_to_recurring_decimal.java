package com.peach.algo.LC151_200_toVip;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/8/7
 * 给定两个整数，分别表示分数的分子 numerator 和分母 denominator，以 字符串形式返回小数 。
 * 如果小数部分为循环小数，则将循环的部分括在括号内。
 * 如果存在多个答案，只需返回 任意一个 。
 * 对于所有给定的输入，保证 答案字符串的长度小于 104 。
 * 示例 1：
 * 输入：numerator = 1, denominator = 2
 * 输出："0.5"
 * 示例 2：
 * 输入：numerator = 2, denominator = 1
 * 输出："2"
 * 示例 3：
 * 输入：numerator = 4, denominator = 333
 * 输出："0.(012)"
 * 提示：
 * -231 <= numerator, denominator <= 231 - 1
 * denominator != 0
 */
public class LC166_fraction_to_recurring_decimal {

    public static void main(String[] args) {
        new LC166_fraction_to_recurring_decimal().fractionToDecimal(7, 12);
    }

    public String fractionToDecimal(int numerator, int denominator) {
        if (numerator == 0) {
            return "0";
        }
        return handle(numerator, denominator);
    }

    private String handle(long numerator, long denominator) {
        if ((numerator > 0 && denominator < 0) || (numerator < 0 && denominator > 0)) {
            return "-" + handle(Math.abs(numerator), Math.abs(denominator));
        }
        long num = numerator / denominator;
        long next = numerator % denominator;
        if (next == 0) {
            return String.valueOf(num);
        }
        StringBuilder ddd = new StringBuilder();
        Map<Long, Integer> map = new HashMap<>();
        map.put(next, -1);
        int index = 0;
        long devide = next;
        boolean limited = false;
        while (true) {
            devide *= 10;
            ddd.append(devide / denominator);
            devide = devide % denominator;
            if (devide == 0) {
                limited = true;
                break;
            }
            if (map.containsKey(devide)) {
                break;
            }
            map.put(devide, index);
            index++;
        }

        if (limited) {
            return num + "." + ddd;
        }
        StringBuilder result = new StringBuilder();
        result.append(num);
        result.append('.');
        Integer firstIndex = map.get(devide);
        String dddd = String.valueOf(ddd);
        for (int i = 0; i < firstIndex + 1; i++) {
            result.append(dddd.charAt(i));
        }
        result.append('(');
        result.append(dddd.substring(firstIndex + 1));
        result.append(')');
        return result.toString();
    }
}
