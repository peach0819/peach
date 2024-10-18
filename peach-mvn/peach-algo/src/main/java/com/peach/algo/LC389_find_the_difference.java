package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/10/18
 * 给定两个字符串 s 和 t ，它们只包含小写字母。
 * 字符串 t 由字符串 s 随机重排，然后在随机位置添加一个字母。
 * 请找出在 t 中被添加的字母。
 * 示例 1：
 * 输入：s = "abcd", t = "abcde"
 * 输出："e"
 * 解释：'e' 是那个被添加的字母。
 * 示例 2：
 * 输入：s = "", t = "y"
 * 输出："y"
 * 提示：
 * 0 <= s.length <= 1000
 * t.length == s.length + 1
 * s 和 t 只包含小写字母
 */
public class LC389_find_the_difference {

    /**
     * 异或
     */
    public char findTheDifference(String s, String t) {
        int[] array = new int[26];
        for (int i = 0; i < t.length(); i++) {
            array[t.charAt(i) - 'a']++;
            if (i < t.length() - 1) {
                array[s.charAt(i) - 'a']--;
            }
        }
        for (int i = 0; i < array.length; i++) {
            if (array[i] == 1) {
                return (char) (i + 'a');
            }
        }
        return 'a';
    }
}
