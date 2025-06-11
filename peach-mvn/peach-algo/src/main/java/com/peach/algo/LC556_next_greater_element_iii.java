package com.peach.algo;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2025/6/6
 * 给你一个正整数 n ，请你找出符合条件的最小整数，其由重新排列 n 中存在的每位数字组成，并且其值大于 n 。如果不存在这样的正整数，则返回 -1 。
 * 注意 ，返回的整数应当是一个 32 位整数 ，如果存在满足题意的答案，但不是 32 位整数 ，同样返回 -1 。
 * 示例 1：
 * 输入：n = 12
 * 输出：21
 * 示例 2：
 * 输入：n = 21
 * 输出：-1
 * 提示：
 * 1 <= n <= 231 - 1
 */
public class LC556_next_greater_element_iii {

    public int nextGreaterElement(int n) {
        String s = String.valueOf(n);
        char[] chars = s.toCharArray();
        int[] array = new int[10];
        Arrays.fill(array, -1);
        for (int i = chars.length - 1; i >= 0; i--) {
            int num = chars[i] - '0';
            for (int j = num + 1; j < 10; j++) {
                if (array[j] != -1) {
                    return build(chars, i, array[j]);
                }
            }
            if (array[num] == -1) {
                array[num] = i;
            }
        }
        return -1;
    }

    //交换了之后，交换后的位置再升序
    private int build(char[] chars, int i, int j) {
        char c = chars[i];
        chars[i] = chars[j];
        chars[j] = c;
        Arrays.sort(chars, i + 1, chars.length);
        long l = Long.parseLong(new String(chars));
        if (l > Integer.MAX_VALUE) {
            return -1;
        }
        return (int) l;
    }

}