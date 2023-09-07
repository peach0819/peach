package com.peach.algo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2023/9/6
 * 一条包含字母 A-Z 的消息通过以下映射进行了 编码 ：
 * 'A' -> "1"
 * 'B' -> "2"
 * ...
 * 'Z' -> "26"
 * 要 解码 已编码的消息，所有数字必须基于上述映射的方法，反向映射回字母（可能有多种方法）。例如，"11106" 可以映射为：
 * "AAJF" ，将消息分组为 (1 1 10 6)
 * "KJF" ，将消息分组为 (11 10 6)
 * 注意，消息不能分组为  (1 11 06) ，因为 "06" 不能映射为 "F" ，这是由于 "6" 和 "06" 在映射中并不等价。
 * 给你一个只含数字的 非空 字符串 s ，请计算并返回 解码 方法的 总数 。
 * 题目数据保证答案肯定是一个 32 位 的整数。
 * 示例 1：
 * 输入：s = "12"
 * 输出：2
 * 解释：它可以解码为 "AB"（1 2）或者 "L"（12）。
 * 示例 2：
 * 输入：s = "226"
 * 输出：3
 * 解释：它可以解码为 "BZ" (2 26), "VF" (22 6), 或者 "BBF" (2 2 6) 。
 * 示例 3：
 * 输入：s = "06"
 * 输出：0
 * 解释："06" 无法映射到 "F" ，因为存在前导零（"6" 和 "06" 并不等价）。
 */
public class LC91_decode_ways {

    List<List<Character>> result = new ArrayList<>();

    public int numDecodings1(String s) {
        if (s.equals("")) {
            return 0;
        }
        chars = s.toCharArray();
        operate(0, new ArrayList<>());
        return result.size();
    }

    private void operate(int begin, List<Character> list) {
        if (begin >= chars.length) {
            result.add(new ArrayList<>(list));
            return;
        }
        //吃一个
        String s1 = String.valueOf(chars[begin]);
        if (map.containsKey(s1)) {
            Character character = map.get(s1);
            list.add(character);
            operate(begin + 1, list);
            list.remove(list.size() - 1);
        }

        if (begin + 1 < chars.length) {
            char[] newChar = new char[]{ chars[begin], chars[begin + 1] };
            String s2 = String.valueOf(newChar);
            if (map.containsKey(s2)) {
                Character character = map.get(s2);
                list.add(character);
                operate(begin + 2, list);
                list.remove(list.size() - 1);
            }
        }
    }

    public static void main(String[] args) {
        int i = new LC91_decode_ways().numDecodings("226");
        int j = 1;
    }

    Map<String, Character> map = initMap();

    private Map<String, Character> initMap() {
        Map<String, Character> map = new HashMap<>();
        for (int i = 0; i < 26; i++) {
            map.put(String.valueOf(i + 1), (char) ('A' + i));
        }
        return map;
    }

    char[] chars;
    int[] intResult;
    boolean[] booleanResult;

    public int numDecodings(String s) {
        if (s.equals("")) {
            return 0;
        }
        chars = s.toCharArray();
        intResult = new int[chars.length];
        booleanResult = new boolean[chars.length];
        int i = get(chars.length - 1);
        return i;
    }

    private int get(int x) {
        if (booleanResult[x]) {
            return intResult[x];
        }

        int cur = 0;
        int cur1 = 0;
        String s1 = String.valueOf(chars[x]);
        if (map.containsKey(s1)) {
            cur1 = x == 0 ? 1 : get(x - 1);
            cur += cur1;
        }

        String s2;
        int cur2 = 0;
        if (x > 0) {
            char[] newChar = new char[]{ chars[x - 1], chars[x] };
            s2 = String.valueOf(newChar);
            if (map.containsKey(s2)) {
                cur2 = x == 1 ? 1 : get(x - 2);
                cur += cur2;
            }
        }
        booleanResult[x] = true;
        intResult[x] = cur;

        if (x > 0 && cur1 == 0 && cur2 == 0) {
            for (int i = x + 1; i < chars.length; i++) {
                booleanResult[i] = true;
            }
        }
        return cur;
    }

}
