package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/10/27
 * 有台奇怪的打印机有以下两个特殊要求：
 * 打印机每次只能打印由 同一个字符 组成的序列。
 * 每次可以在从起始到结束的任意位置打印新字符，并且会覆盖掉原来已有的字符。
 * 给你一个字符串 s ，你的任务是计算这个打印机打印它需要的最少打印次数。
 * 示例 1：
 * 输入：s = "aaabbb"
 * 输出：2
 * 解释：首先打印 "aaa" 然后打印 "bbb"。
 * 示例 2：
 * 输入：s = "aba"
 * 输出：2
 * 解释：首先打印 "aaa" 然后在第二个位置打印 "b" 覆盖掉原来的字符 'a'。
 * 提示：
 * 1 <= s.length <= 100
 * s 由小写英文字母组成
 */
public class LC664_strange_printer {

    /**
     * 我是傻逼
     */
    public int strangePrinter(String s) {
        int n = s.length();
        int[][] f = new int[n + 1][n + 1];
        for (int len = 1; len <= n; len++) {
            for (int l = 0; l + len - 1 < n; l++) {
                int r = l + len - 1;
                f[l][r] = f[l + 1][r] + 1;
                for (int k = l + 1; k <= r; k++) {
                    if (s.charAt(l) == s.charAt(k)) {
                        f[l][r] = Math.min(f[l][r], f[l][k - 1] + f[k + 1][r]);
                    }
                }
            }
        }
        return f[0][n - 1];
    }

    //char[] array;
    //
    //public int strangePrinter(String s) {
    //    array = s.toCharArray();
    //    int result1 = handle(0, array.length - 1);
    //    array = new StringBuilder(s).reverse().toString().toCharArray();
    //    int result2 =  handle(0, array.length - 1);
    //    return Math.min(result1, result2);
    //}
    //
    //private int handle(int beginIndex, int endIndex) {
    //    if (beginIndex > endIndex) {
    //        return 0;
    //    }
    //    if (beginIndex == endIndex) {
    //        return 1;
    //    }
    //    char cur = array[beginIndex];
    //    int lastIndex = endIndex;
    //    while (lastIndex >= beginIndex) {
    //        if (array[lastIndex] == cur) {
    //            break;
    //        }
    //        lastIndex--;
    //    }
    //    int beginIndex2 = beginIndex + 1;
    //    int lastIndex2 = lastIndex - 1;
    //    while (beginIndex2 <= lastIndex) {
    //        if (array[beginIndex2] != cur) {
    //            break;
    //        }
    //        beginIndex2++;
    //    }
    //    while (lastIndex2 >= beginIndex2) {
    //        if (array[lastIndex2] != cur) {
    //            break;
    //        }
    //        lastIndex2--;
    //    }
    //
    //    return 1 + handle(beginIndex2, lastIndex2) + handle(lastIndex + 1, endIndex);
    //}
}
