package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/10/30
 * 给你一个字符串 s ，其中包含字母顺序打乱的用英文单词表示的若干数字（0-9）。按 升序 返回原始的数字。
 * 示例 1：
 * 输入：s = "owoztneoer"
 * 输出："012"
 * 示例 2：
 * 输入：s = "fviefuro"
 * 输出："45"
 * 提示：
 * 1 <= s.length <= 105
 * s[i] 为 ["e","g","f","i","h","o","n","s","r","u","t","w","v","x","z"] 这些字符之一
 * s 保证是一个符合题目要求的字符串
 */
public class LC423_reconstruct_original_digits_from_english {

    public String originalDigits(String s) {
        int[] array = new int[26];
        for (int i = 0; i < s.length(); ++i) {
            char c = s.charAt(i);
            array[c - 'a']++;
        }

        int[] cnt = new int[10];
        cnt[0] = array['z' - 'a'];
        cnt[2] = array['w' - 'a'];
        cnt[4] = array['u' - 'a'];
        cnt[6] = array['x' - 'a'];
        cnt[8] = array['g' - 'a'];
        cnt[3] = array['h' - 'a'] - cnt[8];
        cnt[5] = array['f' - 'a'] - cnt[4];
        cnt[7] = array['s' - 'a'] - cnt[6];
        cnt[1] = array['o' - 'a'] - cnt[0] - cnt[2] - cnt[4];
        cnt[9] = array['i' - 'a'] - cnt[5] - cnt[6] - cnt[8];
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 10; ++i) {
            for (int j = 0; j < cnt[i]; ++j) {
                sb.append((char) (i + '0'));
            }
        }
        return sb.toString();
    }

}
