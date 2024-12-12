package com.peach.algo.LC401_450_toVip;

/**
 * @author feitao.zt
 * @date 2024/10/29
 * 给定两个字符串形式的非负整数 num1 和num2 ，计算它们的和并同样以字符串形式返回。
 * 你不能使用任何內建的用于处理大整数的库（比如 BigInteger）， 也不能直接将输入的字符串转换为整数形式。
 * 示例 1：
 * 输入：num1 = "11", num2 = "123"
 * 输出："134"
 * 示例 2：
 * 输入：num1 = "456", num2 = "77"
 * 输出："533"
 * 示例 3：
 * 输入：num1 = "0", num2 = "0"
 * 输出："0"
 * 提示：
 * 1 <= num1.length, num2.length <= 104
 * num1 和num2 都只包含数字 0-9
 * num1 和num2 都不包含任何前导零
 */
public class LC415_add_strings {

    public static void main(String[] args) {
        new LC415_add_strings().addStrings("11", "123");
    }

    public String addStrings(String num1, String num2) {
        int index = 0;
        StringBuilder sb = new StringBuilder();
        int addition = 0;

        int cur1;
        int cur2;

        int cur;
        while (index < num1.length() || index < num2.length()) {
            if (index >= num1.length()) {
                cur1 = 0;
            } else {
                cur1 = num1.charAt(num1.length() - 1 - index) - '0';
            }
            if (index >= num2.length()) {
                cur2 = 0;
            } else {
                cur2 = num2.charAt(num2.length() - 1 - index) - '0';
            }
            cur = addition + cur1 + cur2;
            sb.append(cur % 10);
            addition = cur / 10;
            index++;
        }
        if (addition != 0) {
            sb.append(1);
        }
        return sb.reverse().toString();
    }
}
