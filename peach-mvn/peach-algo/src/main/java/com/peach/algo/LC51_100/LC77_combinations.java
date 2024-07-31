package com.peach.algo.LC51_100;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2023/8/25
 * 给定两个整数 n 和 k，返回范围 [1, n] 中所有可能的 k 个数的组合。
 * 你可以按 任何顺序 返回答案。
 * 示例 1：
 * 输入：n = 4, k = 2
 * 输出：
 * [
 * [2,4],
 * [3,4],
 * [2,3],
 * [1,2],
 * [1,3],
 * [1,4],
 * ]
 * 示例 2：
 * 输入：n = 1, k = 1
 * 输出：[[1]]
 */
public class LC77_combinations {

    List<List<Integer>> result = new ArrayList<>();

    public List<List<Integer>> combine(int n, int k) {
        doCombine(n, k, 1, new ArrayList<>());
        return result;
    }

    private void doCombine(int n, int k, int from, List<Integer> cur) {
        if (k == 0) {
            result.add(new ArrayList<>(cur));
            return;
        } else if (from > n || (n - from + 1) < k) {
            return;
        }
        doCombine(n, k, from + 1, cur);

        cur.add(from);
        doCombine(n, k - 1, from + 1, cur);
        cur.remove(cur.size() - 1);
    }

    public static void main(String[] args) {
        List<List<Integer>> combine = new LC77_combinations().combine(4, 2);
        int i = 1;
    }
}
