package com.peach.algo;

import java.util.Stack;

/**
 * @author feitao.zt
 * @date 2024/10/21
 * 给定一个经过编码的字符串，返回它解码后的字符串。
 * 编码规则为: k[encoded_string]，表示其中方括号内部的 encoded_string 正好重复 k 次。注意 k 保证为正整数。
 * 你可以认为输入字符串总是有效的；输入字符串中没有额外的空格，且输入的方括号总是符合格式要求的。
 * 此外，你可以认为原始数据不包含数字，所有的数字只表示重复的次数 k ，例如不会出现像 3a 或 2[4] 的输入。
 * 示例 1：
 * 输入：s = "3[a]2[bc]"
 * 输出："aaabcbc"
 * 示例 2：
 * 输入：s = "3[a2[c]]"
 * 输出："accaccacc"
 * 示例 3：
 * 输入：s = "2[abc]3[cd]ef"
 * 输出："abcabccdcdcdef"
 * 示例 4：
 * 输入：s = "abc3[cd]xyz"
 * 输出："abccdcdcdxyz"
 * 提示：
 * 1 <= s.length <= 30
 * s 由小写英文字母、数字和方括号 '[]' 组成
 * s 保证是一个 有效 的输入。
 * s 中所有整数的取值范围为 [1, 300]
 */
public class LC394_decode_string {

    public static void main(String[] args) {
        String s = new LC394_decode_string().decodeString("3[a2[c]]");
        int i = 1;
    }

    int[] indexMap;

    public String decodeString(String s) {
        indexMap = new int[s.length()];
        Stack<Integer> stack = new Stack<>();
        for (int i = 0; i < s.length(); i++) {
            if (s.charAt(i) == '[') {
                stack.push(i);
            } else if (s.charAt(i) == ']') {
                indexMap[stack.pop()] = i;
            }
        }
        return handle(s, 0, s.length() - 1);
    }

    private String handle(String s, int begin, int end) {
        StringBuilder sb = new StringBuilder();
        int num = 0;

        int index = begin;
        while (index <= end) {
            char c = s.charAt(index);
            if (isNum(c)) {
                num *= 10;
                num += c - '0';
                index++;
            } else if (c == '[') {
                String inner = handle(s, index + 1, indexMap[index] - 1);
                for (int i = 0; i < num; i++) {
                    sb.append(inner);
                }
                num = 0;
                index = indexMap[index] + 1;
            } else {
                sb.append(c);
                index++;
            }
        }
        return sb.toString();
    }

    private boolean isNum(char c) {
        return c >= '0' && c <= '9';
    }

}
