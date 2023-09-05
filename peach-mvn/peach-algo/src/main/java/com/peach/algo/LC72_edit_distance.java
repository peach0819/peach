package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2023/9/5
 * 给你两个单词 word1 和 word2， 请返回将 word1 转换成 word2 所使用的最少操作数  。
 * 你可以对一个单词进行如下三种操作：
 * 插入一个字符
 * 删除一个字符
 * 替换一个字符
 * 示例 1：
 * 输入：word1 = "horse", word2 = "ros"
 * 输出：3
 * 解释：
 * horse -> rorse (将 'h' 替换为 'r')
 * rorse -> rose (删除 'r')
 * rose -> ros (删除 'e')
 * 示例 2：
 * 输入：word1 = "intention", word2 = "execution"
 * 输出：5
 * 解释：
 * intention -> inention (删除 't')
 * inention -> enention (将 'i' 替换为 'e')
 * enention -> exention (将 'n' 替换为 'x')
 * exention -> exection (将 'n' 替换为 'c')
 * exection -> execution (插入 'u')
 * 提示：
 * 0 <= word1.length, word2.length <= 500
 * word1 和 word2 由小写英文字母组成
 */
public class LC72_edit_distance {

    int[][] result;
    boolean[][] bResult;

    char[] chars1;
    char[] chars2;

    public int minDistance(String word1, String word2) {
        chars1 = word1.toCharArray();
        chars2 = word2.toCharArray();

        int m = word1.length();
        int n = word2.length();
        result = new int[m + 1][n + 1];
        bResult = new boolean[m + 1][n + 1];
        return result(m, n);
    }

    private int result(int m, int n) {
        if (m == 0) {
            return n;
        }
        if (n == 0) {
            return m;
        }
        if (bResult[m][n]) {
            return result[m][n];
        }
        if (chars1[m - 1] == chars2[n - 1]) {
            return result(m - 1, n - 1);
        }
        int cur = Math.min(Math.min(result(m - 1, n - 1), result(m, n - 1)), result(m - 1, n)) + 1;
        bResult[m][n] = true;
        result[m][n] = cur;
        return cur;
    }

}
