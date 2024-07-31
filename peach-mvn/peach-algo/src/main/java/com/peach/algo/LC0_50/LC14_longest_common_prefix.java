package com.peach.algo.LC0_50;

/**
 * @author feitao.zt
 * @date 2024/7/2
 * 编写一个函数来查找字符串数组中的最长公共前缀。
 * 如果不存在公共前缀，返回空字符串 ""。
 * 示例 1：
 * 输入：strs = ["flower","flow","flight"]
 * 输出："fl"
 * 示例 2：
 * 输入：strs = ["dog","racecar","car"]
 * 输出：""
 * 解释：输入不存在公共前缀。
 * 提示：
 * 1 <= strs.length <= 200
 * 0 <= strs[i].length <= 200
 * strs[i] 仅由小写英文字母组成
 */
public class LC14_longest_common_prefix {

    public String longestCommonPrefix(String[] strs) {
        int maxLength = 0;
        for (String str : strs) {
            maxLength = Math.max(maxLength, str.length());
        }
        StringBuilder stringBuilder = new StringBuilder();
        int index = 0;
        while (true) {
            if (handle(strs, index, stringBuilder)) {
                index++;
            } else {
                break;
            }
        }
        return stringBuilder.toString();
    }

    private boolean handle(String[] strs, int index, StringBuilder stringBuilder) {
        char c = ' ';
        for (int i = 0; i < strs.length; i++) {
            String str = strs[i];
            if (index == str.length()) {
                return false;
            }
            if (i == 0) {
                c = str.charAt(index);
            } else if (c != str.charAt(index)) {
                return false;
            }
        }
        stringBuilder.append(c);
        return true;
    }
}
