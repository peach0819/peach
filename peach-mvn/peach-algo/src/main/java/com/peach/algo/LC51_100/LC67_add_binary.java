package com.peach.algo.LC51_100;

/**
 * @author feitao.zt
 * @date 2024/7/16
 * 给你两个二进制字符串 a 和 b ，以二进制字符串的形式返回它们的和。
 * 示例 1：
 * 输入:a = "11", b = "1"
 * 输出："100"
 * 示例 2：
 * 输入：a = "1010", b = "1011"
 * 输出："10101"
 * 提示：
 * 1 <= a.length, b.length <= 104
 * a 和 b 仅由字符 '0' 或 '1' 组成
 * 字符串如果不是 "0" ，就不含前导零
 */
public class LC67_add_binary {

    public static void main(String[] args) {
        new LC67_add_binary().addBinary("11", "1");
    }

    public String addBinary(String a, String b) {
        StringBuilder s = new StringBuilder();
        char[] ca = a.toCharArray();
        char[] cb = b.toCharArray();
        int ia = a.length() - 1;
        int ib = b.length() - 1;
        int aa;
        int bb;
        int cur;
        int last = 0;
        while (ia >= 0 || ib >= 0) {
            aa = ia < 0 ? 0 : ca[ia] - '0';
            bb = ib < 0 ? 0 : cb[ib] - '0';
            cur = aa + bb + last;
            s.append(cur % 2);
            ia--;
            ib--;
            last = cur / 2;
        }
        if (last != 0) {
            s.append(1);
        }
        return s.reverse().toString();
    }
}
