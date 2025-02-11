package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2025/2/11
 * 给你一个字符串数组 words ，只返回可以使用在 美式键盘 同一行的字母打印出来的单词。键盘如下图所示。
 * 请注意，字符串 不区分大小写，相同字母的大小写形式都被视为在同一行。
 * 美式键盘 中：
 * 第一行由字符 "qwertyuiop" 组成。
 * 第二行由字符 "asdfghjkl" 组成。
 * 第三行由字符 "zxcvbnm" 组成。
 * American keyboard
 * 示例 1：
 * 输入：words = ["Hello","Alaska","Dad","Peace"]
 * 输出：["Alaska","Dad"]
 * 解释：
 * 由于不区分大小写，"a" 和 "A" 都在美式键盘的第二行。
 * 示例 2：
 * 输入：words = ["omk"]
 * 输出：[]
 * 示例 3：
 * 输入：words = ["adsdf","sfd"]
 * 输出：["adsdf","sfd"]
 * 提示：
 * 1 <= words.length <= 20
 * 1 <= words[i].length <= 100
 * words[i] 由英文字母（小写和大写字母）组成
 */
public class LC500_keyboard_row {

    char[] c1 = { 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P' };
    char[] c2 = { 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L' };
    char[] c3 = { 'z', 'x', 'c', 'v', 'b', 'n', 'm', 'Z', 'X', 'C', 'V', 'B', 'N', 'M' };

    public String[] findWords(String[] words) {
        int[] index = new int[128];
        for (char c : c1) {
            index[c] = 1;
        }
        for (char c : c2) {
            index[c] = 2;
        }
        for (char c : c3) {
            index[c] = 3;
        }
        List<String> result = new ArrayList<>();
        for (String word : words) {
            int cur = index[word.charAt(0)];
            boolean success = true;
            for (int i = 1; i < word.length(); i++) {
                if (index[word.charAt(i)] != cur) {
                    success = false;
                    break;
                }
            }
            if (success) {
                result.add(word);
            }
        }
        return result.toArray(new String[0]);
    }

}
