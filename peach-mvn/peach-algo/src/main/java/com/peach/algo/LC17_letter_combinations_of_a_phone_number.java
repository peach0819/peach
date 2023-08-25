package com.peach.algo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2023/8/25
 * 给定一个仅包含数字 2-9 的字符串，返回所有它能表示的字母组合。答案可以按 任意顺序 返回。
 * 给出数字到字母的映射如下（与电话按键相同）。注意 1 不对应任何字母。
 * 示例 1：
 * 输入：digits = "23"
 * 输出：["ad","ae","af","bd","be","bf","cd","ce","cf"]
 * 示例 2：
 * 输入：digits = ""
 * 输出：[]
 * 示例 3：
 * 输入：digits = "2"
 * 输出：["a","b","c"]
 */
public class LC17_letter_combinations_of_a_phone_number {

    Map<Character, List<Character>> map = letterMap();

    List<String> result = new ArrayList<>();

    public List<String> letterCombinations(String digits) {
        if (digits != null && digits.length() > 0) {
            operate(digits.toCharArray(), 0, new char[digits.length()]);
        }
        return result;
    }

    private void operate(char[] charArr, int index, char[] cur) {
        if (index == charArr.length) {
            result.add(new String(cur));
            return;
        }
        char c = charArr[index];
        List<Character> charList = map.get(c);
        for (Character curChar : charList) {
            cur[index] = curChar;
            operate(charArr, index + 1, cur);
        }
    }

    private Map<Character, List<Character>> letterMap() {
        Map<Character, List<Character>> map = new HashMap<>();
        map.put('2', Arrays.asList('a', 'b', 'c'));
        map.put('3', Arrays.asList('d', 'e', 'f'));
        map.put('4', Arrays.asList('g', 'h', 'i'));
        map.put('5', Arrays.asList('j', 'k', 'l'));
        map.put('6', Arrays.asList('m', 'n', 'o'));
        map.put('7', Arrays.asList('p', 'q', 'r', 's'));
        map.put('8', Arrays.asList('t', 'u', 'v'));
        map.put('9', Arrays.asList('w', 'x', 'y', 'z'));
        return map;
    }

}
