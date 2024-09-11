package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/9/11
 * 将非负整数 num 转换为其对应的英文表示。
 * 示例 1：
 * 输入：num = 123
 * 输出："One Hundred Twenty Three"
 * 示例 2：
 * 输入：num = 12345
 * 输出："Twelve Thousand Three Hundred Forty Five"
 * 示例 3：
 * 输入：num = 1234567
 * 输出："One Million Two Hundred Thirty Four Thousand Five Hundred Sixty Seven"
 * 提示：
 * 0 <= num <= 231 - 1
 */
public class LC273_integer_to_english_words {

    public static void main(String[] args) {
        new LC273_integer_to_english_words().numberToWords(20);
    }

    public String numberToWords(int num) {
        if (num == 0) {
            return "Zero";
        }
        List<String> result = new ArrayList<>();
        int billion = num / 1000000000;
        if (billion != 0) {
            result.addAll(handle(billion));
            result.add("Billion");
        }
        num = num % 1000000000;

        int million = num / 1000000;
        if (million != 0) {
            result.addAll(handle(million));
            result.add("Million");
        }
        num = num % 1000000;

        int thousand = num / 1000;
        if (thousand != 0) {
            result.addAll(handle(thousand));
            result.add("Thousand");
        }
        num = num % 1000;
        result.addAll(handle(num));
        return String.join(" ", result);
    }

    private List<String> handle(int num) {
        List<String> result = new ArrayList<>();
        int hundred = num / 100;
        if (hundred != 0) {
            result.add(last(hundred));
            result.add("Hundred");
        }
        num = num % 100;
        int tenAdd = num / 10;
        if (tenAdd == 1) {
            result.add(tenAdd(num % 10));
        } else {
            if (tenAdd != 0) {
                result.add(mid(tenAdd));
            }
            int i = num % 10;
            if (i != 0) {
                result.add(last(num % 10));
            }
        }
        return result;
    }

    private String last(int num) {
        switch (num) {
            case 1:
                return "One";
            case 2:
                return "Two";
            case 3:
                return "Three";
            case 4:
                return "Four";
            case 5:
                return "Five";
            case 6:
                return "Six";
            case 7:
                return "Seven";
            case 8:
                return "Eight";
            case 9:
                return "Nine";
            default:
                return null;
        }
    }

    private String mid(int num) {
        switch (num) {
            case 2:
                return "Twenty";
            case 3:
                return "Thirty";
            case 4:
                return "Forty";
            case 5:
                return "Fifty";
            case 6:
                return "Sixty";
            case 7:
                return "Seventy";
            case 8:
                return "Eighty";
            case 9:
                return "Ninety";
            default:
                return null;
        }
    }

    private String tenAdd(int num) {
        switch (num) {
            case 0:
                return "Ten";
            case 1:
                return "Eleven";
            case 2:
                return "Twelve";
            case 3:
                return "Thirteen";
            case 4:
                return "Fourteen";
            case 5:
                return "Fifteen";
            case 6:
                return "Sixteen";
            case 7:
                return "Seventeen";
            case 8:
                return "Eighteen";
            case 9:
                return "Nineteen";
            default:
                return null;
        }
    }
}
