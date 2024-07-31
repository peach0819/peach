package com.peach.algo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/31
 * 给你一个字符串 s，请你将 s 分割成一些子串，使每个子串都是
 * 回文串
 * 。返回 s 所有可能的分割方案。
 * 示例 1：
 * 输入：s = "aab"
 * 输出：[["a","a","b"],["aa","b"]]
 * 示例 2：
 * 输入：s = "a"
 * 输出：[["a"]]
 * 提示：
 * 1 <= s.length <= 16
 * s 仅由小写英文字母组成
 */
public class LC131_palindrome_partitioning {

    List<List<String>> result = new ArrayList<>();
    char[] chars;

    public List<List<String>> partition(String s) {
        this.chars = s.toCharArray();
        handle(0, 0, new ArrayList<>());
        return result;
    }

    private void handle(int curIndex, int beginIndex, List<String> list) {
        if (curIndex == chars.length) {
            if (beginIndex == chars.length) {
                result.add(new ArrayList<>(list));
            }
            return;
        }
        if (isReturnWord(curIndex, beginIndex)) {
            list.add(new String(Arrays.copyOfRange(chars, beginIndex, curIndex + 1)));
            handle(curIndex + 1, curIndex + 1, list);
            list.remove(list.size() - 1);
        }
        handle(curIndex + 1, beginIndex, list);
    }

    private boolean isReturnWord(int curIndex, int beginIndex) {
        while (beginIndex < curIndex) {
            if (chars[beginIndex] != chars[curIndex]) {
                return false;
            }
            beginIndex++;
            curIndex--;
        }
        return true;
    }
}
