package com.peach.algo.LC301_350_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/30
 * 给你一个字符串 s ，仅反转字符串中的所有元音字母，并返回结果字符串。
 * 元音字母包括 'a'、'e'、'i'、'o'、'u'，且可能以大小写两种形式出现不止一次。
 * 示例 1：
 * 输入：s = "IceCreAm"
 * 输出："AceCreIm"
 * 解释：
 * s 中的元音是 ['I', 'e', 'e', 'A']。反转这些元音，s 变为 "AceCreIm".
 * 示例 2：
 * 输入：s = "leetcode"
 * 输出："leotcede"
 * 提示：
 * 1 <= s.length <= 3 * 105
 * s 由 可打印的 ASCII 字符组成
 */
public class LC345_reverse_vowels_of_a_string {

    boolean[] base = new boolean[128];

    public String reverseVowels(String s) {
        if (s.length() == 1) {
            return s;
        }
        base['a'] = true;
        base['e'] = true;
        base['i'] = true;
        base['o'] = true;
        base['u'] = true;
        base['A'] = true;
        base['E'] = true;
        base['I'] = true;
        base['O'] = true;
        base['U'] = true;

        char[] chars = s.toCharArray();
        int i = 0;
        int j = chars.length - 1;
        char temp;
        while (i < j) {
            while (!isBase(chars[i]) && i < j) {
                i++;
            }
            while (!isBase(chars[j]) && i < j) {
                j--;
            }
            if (i >= j) {
                break;
            }
            temp = chars[i];
            chars[i] = chars[j];
            chars[j] = temp;
            i++;
            j--;
        }
        return new String(chars);
    }

    private boolean isBase(char c) {
        return base[c];
    }
}
