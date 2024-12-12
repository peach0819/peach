package com.peach.algo.LC401_450_toVip;

/**
 * @author feitao.zt
 * @date 2024/10/30
 * 给你一个字符串 s 和一个整数 k 。你可以选择字符串中的任一字符，并将其更改为任何其他大写英文字符。该操作最多可执行 k 次。
 * 在执行上述操作后，返回 包含相同字母的最长子字符串的长度。
 * 示例 1：
 * 输入：s = "ABAB", k = 2
 * 输出：4
 * 解释：用两个'A'替换为两个'B',反之亦然。
 * 示例 2：
 * 输入：s = "AABABBA", k = 1
 * 输出：4
 * 解释：
 * 将中间的一个'A'替换为'B',字符串变为 "AABBBBA"。
 * 子串 "BBBB" 有最长重复字母, 答案为 4。
 * 可能存在其他的方法来得到同样的结果。
 * 提示：
 * 1 <= s.length <= 105
 * s 仅由大写英文字母组成
 * 0 <= k <= s.length
 */
public class LC424_longest_repeating_character_replacement {

    public static void main(String[] args) {
        new LC424_longest_repeating_character_replacement().characterReplacement("ABCDDD", 3);
    }

    public int characterReplacement(String s, int k) {
        int index = 0;
        int next = 0;
        int max = 0;

        int curK;
        char curC;
        int tempIndex;
        boolean nextInit;
        while (true) {
            nextInit = false;
            curK = k;
            curC = s.charAt(index);
            tempIndex = index + 1;
            while (true) {
                if (tempIndex == s.length()) {
                    int curMax = tempIndex - index;
                    if (curK > 0) {
                        curMax += Math.min(curK, index);
                    }
                    max = Math.max(max, curMax);
                    break;
                }
                if (s.charAt(tempIndex) != curC) {
                    if (!nextInit) {
                        nextInit = true;
                        next = tempIndex;
                    }
                    if (curK > 0) {
                        curK--;
                    } else {
                        max = Math.max(max, tempIndex - index);
                        break;
                    }
                }
                tempIndex++;
            }
            if (!nextInit) {
                return max;
            }
            index = next;
        }
    }
}
