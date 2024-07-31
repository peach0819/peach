package com.peach.algo.LC0_50;

import java.util.HashSet;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/6/11
 */
public class LC3_longest_substring_without_repeating_characters {

    public int lengthOfLongestSubstring(String s) {
        int length = s.length();
        int max = 0;
        for (int i = 0; i < length; i++) {
            String currentStr = s.substring(i, length);
            int currentLongestLength = lengthOfLongestLeftSubstring(currentStr);
            if (currentLongestLength > max) {
                max = currentLongestLength;
            }
        }
        return max;
    }

    private int lengthOfLongestLeftSubstring(String s) {
        Set<Character> set = new HashSet<>();
        int length = s.length();
        for (int i = 0; i < length; i++) {
            Character currentChar = s.charAt(i);
            if (set.contains(currentChar)) {
                return i;
            }
            set.add(currentChar);
        }
        return length;
    }
}
