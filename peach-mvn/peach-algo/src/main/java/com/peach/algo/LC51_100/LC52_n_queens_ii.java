package com.peach.algo.LC51_100;

import java.util.HashSet;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/7/15
 * n 皇后问题 研究的是如何将 n 个皇后放置在 n × n 的棋盘上，并且使皇后彼此之间不能相互攻击。
 * 给你一个整数 n ，返回 n 皇后问题 不同的解决方案的数量。
 * 示例 1：
 * 输入：n = 4
 * 输出：2
 * 解释：如上图所示，4 皇后问题存在两个不同的解法。
 * 示例 2：
 * 输入：n = 1
 * 输出：1
 * 提示：
 * 1 <= n <= 9
 */
public class LC52_n_queens_ii {

    Set<Integer> shuList = new HashSet<>();
    Set<Integer> pieList = new HashSet<>();
    Set<Integer> naList = new HashSet<>();
    int result = 0;
    int length;

    public int totalNQueens(int n) {
        this.length = n;
        handle(0);
        return result;
    }

    private void handle(int num) {
        if (num == length) {
            result++;
            return;
        }
        for (int i = 0; i < length; i++) {
            if (canPut(num, i)) {
                shuList.add(i);
                int pie = num + i;
                pieList.add(pie);
                int na = num - i;
                naList.add(na);
                handle(num + 1);
                shuList.remove(i);
                pieList.remove(pie);
                naList.remove(na);
            }
        }
    }

    private boolean canPut(int heng, int shu) {
        if (shuList.contains(shu)) {
            return false;
        }
        int pie = heng + shu;
        if (pieList.contains(pie)) {
            return false;
        }
        int na = heng - shu;
        if (naList.contains(na)) {
            return false;
        }
        return true;
    }
}
