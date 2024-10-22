package com.peach.algo;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/10/21
 * 给定一个正整数 n ，你可以做如下操作：
 * 如果 n 是偶数，则用 n / 2替换 n 。
 * 如果 n 是奇数，则可以用 n + 1或n - 1替换 n 。
 * 返回 n 变为 1 所需的 最小替换次数 。
 * 示例 1：
 * 输入：n = 8
 * 输出：3
 * 解释：8 -> 4 -> 2 -> 1
 * 示例 2：
 * 输入：n = 7
 * 输出：4
 * 解释：7 -> 8 -> 4 -> 2 -> 1
 * 或 7 -> 6 -> 3 -> 2 -> 1
 * 示例 3：
 * 输入：n = 4
 * 输出：2
 * 提示：
 * 1 <= n <= 231 - 1
 */
public class LC397_integer_replacement {

    public static void main(String[] args) {
        int i = new LC397_integer_replacement().integerReplacement(100000000);
        i = 1;
    }

    Map<Integer, Integer> dp = new HashMap<>();

    public int integerReplacement(int n) {
        if (n == 1) {
            return 0;
        }
        if (n == Integer.MAX_VALUE) {
            return 32;
        }
        int i = 2;
        int index = 1;
        while (i <= n + 1 && i < Integer.MAX_VALUE / 2 + 1) {
            dp.put(i, index);
            i *= 2;
            index++;
        }
        return handle(n);
    }

    private int handle(int n) {
        if (dp.containsKey(n)) {
            return dp.get(n);
        }
        int handle;
        if (n % 2 == 0) {
            handle = handle(n / 2) + 1;
        } else {
            handle = Math.min(handle(n - 1), handle(n + 1)) + 1;
        }
        dp.put(n, handle);
        return handle;
    }
}
