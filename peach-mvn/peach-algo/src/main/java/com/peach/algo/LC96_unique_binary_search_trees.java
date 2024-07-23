package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/7/23
 * 给你一个整数 n ，求恰由 n 个节点组成且节点值从 1 到 n 互不相同的 二叉搜索树 有多少种？返回满足题意的二叉搜索树的种数。
 * 示例 1：
 * 输入：n = 3
 * 输出：5
 * 示例 2：
 * 输入：n = 1
 * 输出：1
 * 提示：
 * 1 <= n <= 19
 */
public class LC96_unique_binary_search_trees {

    public int numTrees(int n) {
        int[] array = new int[n + 1];
        return getNum(n, array);
    }

    public int getNum(int n, int[] array) {
        if (n == 0 || n == 1) {
            return 1;
        }
        if (array[n] != 0) {
            return array[n];
        }
        int num = 0;
        for (int i = 0; i < n; i++) {
            num += getNum(i, array) * getNum(n - 1 - i, array);
        }
        array[n] = num;
        return num;
    }
}
