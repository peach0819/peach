package com.peach.algo.LC351_400_toVip;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/10/16
 * 给你一个整数 n ，按字典序返回范围 [1, n] 内所有整数。
 * 你必须设计一个时间复杂度为 O(n) 且使用 O(1) 额外空间的算法。
 * 示例 1：
 * 输入：n = 13
 * 输出：[1,10,11,12,13,2,3,4,5,6,7,8,9]
 * 示例 2：
 * 输入：n = 2
 * 输出：[1,2]
 * 提示：
 * 1 <= n <= 5 * 104
 */
public class LC386_lexicographical_numbers {

    List<Integer> result = new ArrayList<>();
    int n;

    public List<Integer> lexicalOrder(int n) {
        this.n = n;
        for (int i = 1; i <= 9; i++) {
            if (!handle(i)) {
                break;
            }
        }
        return result;
    }

    private boolean handle(int start) {
        if (start > n) {
            return false;
        }
        result.add(start);
        start *= 10;
        for (int i = 0; i <= 9; i++) {
            if (!handle(start + i)) {
                break;
            }
        }
        return true;
    }

}
