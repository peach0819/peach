package com.peach.algo.LC351_400_toVip;

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

    /**
     * 位运算很骚
     * 对于偶数（二进制最低位为 0）而言，我们只能进行一种操作，其作用是将当前值 x 其进行一个单位的右移；
     * 对于奇数（二进制最低位为 1）而言，我们能够进行 +1 或 -1 操作，分析两种操作为 x 产生的影响：
     * 对于 +1 操作而言：最低位必然为 1，此时如果次低位为 0 的话， +1 相当于将最低位和次低位交换；如果次低位为 1 的话，+1 操作将将「从最低位开始，连续一段的 1」进行消除（置零），并在连续一段的高一位添加一个 1；
     * 对于 -1 操作而言：最低位必然为 1，其作用是将最低位的 1 进行消除。
     * 因此，对于 x 为奇数所能执行的两种操作，+1 能够消除连续一段的 1，只要次低位为 1（存在连续段），应当优先使用 +1 操作，但需要注意边界 x=3 时的情况（此时选择 -1 操作）。
     * 作者：宫水三叶
     * 链接：https://leetcode.cn/problems/integer-replacement/solutions/1109785/gong-shui-san-xie-yi-ti-san-jie-dfsbfs-t-373h/
     * 来源：力扣（LeetCode）
     * 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
     */
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
