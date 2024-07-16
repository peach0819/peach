package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/7/16
 * 给定一个字符串 s ，返回 s 是否是一个 有效数字。
 * 例如，下面的都是有效数字："2", "0089", "-0.1", "+3.14", "4.", "-.9", "2e10", "-90E3", "3e+7", "+6e-1", "53.5e93", "-123.456e789"，而接下来的不是："abc", "1a", "1e", "e3", "99e2.5", "--6", "-+3", "95a54e53"。
 * 一般的，一个 有效数字 可以用以下的规则之一定义：
 * 一个 整数 后面跟着一个 可选指数。
 * 一个 十进制数 后面跟着一个 可选指数。
 * 一个 整数 定义为一个 可选符号 '-' 或 '+' 后面跟着 数字。
 * 一个 十进制数 定义为一个 可选符号 '-' 或 '+' 后面跟着下述规则：
 * 数字 后跟着一个 小数点 .。
 * 数字 后跟着一个 小数点 . 再跟着 数位。
 * 一个 小数点 . 后跟着 数位。
 * 指数 定义为指数符号 'e' 或 'E'，后面跟着一个 整数。
 * 数字 定义为一个或多个数位。
 * 示例 1：
 * 输入：s = "0"
 * 输出：true
 * 示例 2：
 * 输入：s = "e"
 * 输出：false
 * 示例 3：
 * 输入：s = "."
 * 输出：false
 * 提示：
 * 1 <= s.length <= 20
 * s 仅含英文字母（大写和小写），数字（0-9），加号 '+' ，减号 '-' ，或者点 '.' 。
 */
public class LC65_valid_number {

    public boolean isNumber(String s) {
        //能否出现e, 开局不行，出现数字后可以, 出现e后不行
        boolean canE = false;

        //能否出现小数点, 开局可以，出现数字后可以， 出现e后不行
        boolean canPoint = true;

        //能否出现 + - 符号，开局可以，出现过之后或者出现数字后不行
        boolean canAddition = true;

        //是否已经出现过e
        boolean hasE = false;

        char[] chars = s.toCharArray();
        for (int i = 0; i < chars.length; i++) {
            char c = chars[i];
            if (c == '-' || c == '+') {
                if (!canAddition) {
                    return false;
                } else if (i == chars.length - 1) {
                    return false;
                } else {
                    canAddition = false;
                }
            } else if (c == '.') {
                if (!canPoint) {
                    return false;
                } else {
                    if ((i == chars.length - 1 || !isNum(chars[i + 1])) && (i == 0 || !isNum(chars[i - 1]))) {
                        return false;
                    }
                    canPoint = false;
                }
            } else if (c == 'e' || c == 'E') {
                if (!canE) {
                    return false;
                } else if (i == chars.length - 1) {
                    return false;
                } else {
                    hasE = true;
                    canPoint = false;
                    canAddition = true;
                    canE = false;
                }
            } else if (isNum(c)) {
                if (!hasE) {
                    canE = true;
                }
                canAddition = false;
            } else {
                return false;
            }
        }
        return true;
    }

    private boolean isNum(char c) {
        return c >= '0' && c <= '9';
    }
}
