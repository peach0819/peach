package com.peach.algo.LC151_200_toVip;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/8/9
 * DNA序列 由一系列核苷酸组成，缩写为 'A', 'C', 'G' 和 'T'.。
 * 例如，"ACGAATTCCG" 是一个 DNA序列 。
 * 在研究 DNA 时，识别 DNA 中的重复序列非常有用。
 * 给定一个表示 DNA序列 的字符串 s ，返回所有在 DNA 分子中出现不止一次的 长度为 10 的序列(子字符串)。你可以按 任意顺序 返回答案。
 * 示例 1：
 * 输入：s = "AAAAACCCCCAAAAACCCCCCAAAAAGGGTTT"
 * 输出：["AAAAACCCCC","CCCCCAAAAA"]
 * 示例 2：
 * 输入：s = "AAAAAAAAAAAAA"
 * 输出：["AAAAAAAAAA"]
 * 提示：
 * 0 <= s.length <= 105
 * s[i]=='A'、'C'、'G' or 'T'
 */
public class LC187_repeated_dna_sequences {

    public List<String> findRepeatedDnaSequences(String s) {
        if (s.length() < 10) {
            return new ArrayList<>();
        }
        Set<String> temp = new HashSet<>();
        Set<String> result = new HashSet<>();
        for (int i = 9; i < s.length(); i++) {
            String cur = s.substring(i - 9, i + 1);
            if (temp.contains(cur)) {
                result.add(cur);
            } else {
                temp.add(cur);
            }
        }
        return new ArrayList<>(result);
    }

    public static void main(String[] args) {
        new LC187_repeated_dna_sequences().findRepeatedDnaSequences("AAAAAAAAAAA");
    }

    public List<String> findRepeatedDnaSequences1(String s) {
        if (s.length() <= 10) {
            return new ArrayList<>();
        }
        boolean[] haveArray = new boolean[s.length() - 9];
        List<String> result = new ArrayList<>();
        for (int i = 0; i < s.length() - 10; i++) {
            if (haveArray[i]) {
                continue;
            }
            boolean isSame = false;
            for (int j = i + 1; j <= s.length() - 10; j++) {
                if (isSame(s, i, j)) {
                    isSame = true;
                    haveArray[j] = true;
                }
            }
            if (isSame) {
                result.add(s.substring(i, i + 10));
            }
        }
        return result;
    }

    private boolean isSame(String s, int begin1, int begin2) {
        for (int i = 0; i < 10; i++) {
            if (s.charAt(begin1 + i) != s.charAt(begin2 + i)) {
                return false;
            }
        }
        return true;
    }
}
