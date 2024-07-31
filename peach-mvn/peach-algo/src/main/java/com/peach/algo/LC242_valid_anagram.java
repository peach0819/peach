package com.peach.algo;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2023/7/11
 */
public class LC242_valid_anagram {

    public boolean isAnagram(String s, String t) {
        if (s.length() != t.length()) {
            return false;
        }
        Map<Character, Integer> sMap = new HashMap<>();
        for (char c : s.toCharArray()) {
            sMap.put(c, sMap.getOrDefault(c, 0) + 1);
        }
        for (char c : t.toCharArray()) {
            sMap.put(c, sMap.getOrDefault(c, 0) - 1);
            if (sMap.get(c) < 0) {
                return false;
            }
        }
        return true;
    }
}
