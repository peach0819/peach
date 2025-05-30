package com.peach.algo.LC501_550_toVip;

/**
 * @author feitao.zt
 * @date 2025/2/27
 * 给定一个整数 num，将其转化为 7 进制，并以字符串形式输出。
 * 示例 1:
 * 输入: num = 100
 * 输出: "202"
 * 示例 2:
 * 输入: num = -7
 * 输出: "-10"
 */
public class LC504_base_7 {

    public String convertToBase7(int num) {
        if (num == 0) {
            return "0";
        }
        if (num < 0) {
            return "-" + convertToBase7(-num);
        }
        StringBuilder sb = new StringBuilder();
        while (num > 0) {
            sb.append(num % 7);
            num = num / 7;
        }
        return sb.reverse().toString();
    }
}
