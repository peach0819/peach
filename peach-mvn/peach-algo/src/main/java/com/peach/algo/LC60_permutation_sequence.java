package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/15
 * 给出集合 [1,2,3,...,n]，其所有元素共有 n! 种排列。
 * 按大小顺序列出所有排列情况，并一一标记，当 n = 3 时, 所有排列如下：
 * "123"
 * "132"
 * "213"
 * "231"
 * "312"
 * "321"
 * 给定 n 和 k，返回第 k 个排列。
 * 示例 1：
 * 输入：n = 3, k = 3
 * 输出："213"
 * 示例 2：
 * 输入：n = 4, k = 9
 * 输出："2314"
 * 示例 3：
 * 输入：n = 3, k = 1
 * 输出："123"
 * 提示：
 * 1 <= n <= 9
 * 1 <= k <= n!
 */
public class LC60_permutation_sequence {

    public static void main(String[] args) {
        String permutation = new LC60_permutation_sequence().getPermutation(2, 2);
        int i = 1;
    }

    public String getPermutation(int n, int k) {
        int num = 1;
        List<Integer> list = new ArrayList<>();
        for (int i = 1; i < n; i++) {
            num *= i;
            list.add(i);
        }
        list.add(n);

        StringBuilder result = new StringBuilder();
        int cur;
        Integer val;
        int mode;
        while (list.size() > 1) {
            mode = k % num;
            cur = k / num;
            if (mode == 0) {
                cur--;
            }
            val = list.get(cur);
            result.append(val);
            k = k - cur * num;
            list.remove(val);
            num /= list.size();
        }
        result.append(list.get(0));
        return result.toString();
    }
}
