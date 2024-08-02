package com.peach.algo.LC101_150;

import java.util.ArrayList;
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
    String s;

    public List<List<String>> partition(String s) {
        this.s = s;
        handle(0, 0, new ArrayList<>());
        return result;
    }

    private void handle(int curIndex, int beginIndex, List<String> list) {
        if (curIndex == s.length()) {
            if (beginIndex == s.length()) {
                result.add(new ArrayList<>(list));
            }
            return;
        }
        if (isReturnWord(curIndex, beginIndex)) {
            list.add(s.substring(beginIndex, curIndex + 1));
            handle(curIndex + 1, curIndex + 1, list);
            list.remove(list.size() - 1);
        }
        handle(curIndex + 1, beginIndex, list);
    }

    private boolean isReturnWord(int curIndex, int beginIndex) {
        while (beginIndex < curIndex) {
            if (s.charAt(beginIndex) != s.charAt(curIndex)) {
                return false;
            }
            beginIndex++;
            curIndex--;
        }
        return true;
    }
}
