package com.peach.algo.LC51_100;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/7/15
 * 按照国际象棋的规则，皇后可以攻击与之处在同一行或同一列或同一斜线上的棋子。
 * n 皇后问题 研究的是如何将 n 个皇后放置在 n×n 的棋盘上，并且使皇后彼此之间不能相互攻击。
 * 给你一个整数 n ，返回所有不同的 n 皇后问题 的解决方案。
 * 每一种解法包含一个不同的 n 皇后问题 的棋子放置方案，该方案中 'Q' 和 '.' 分别代表了皇后和空位。
 * 示例 1：
 * 输入：n = 4
 * 输出：[[".Q..","...Q","Q...","..Q."],["..Q.","Q...","...Q",".Q.."]]
 * 解释：如上图所示，4 皇后问题存在两个不同的解法。
 * 示例 2：
 * 输入：n = 1
 * 输出：[["Q"]]
 * 提示：
 * 1 <= n <= 9
 */
public class LC51_n_queens {

    public static void main(String[] args) {
        List<List<String>> lists = new LC51_n_queens().solveNQueens(4);
        int i = 1;
    }

    Set<Integer> shuList = new HashSet<>();
    Set<Integer> pieList = new HashSet<>();
    Set<Integer> naList = new HashSet<>();
    List<List<String>> result = new ArrayList<>();
    int length;

    public List<List<String>> solveNQueens(int n) {
        this.length = n;
        handle(0, new ArrayList<>());
        return result;
    }

    private void handle(int num, List<String> curList) {
        if (num == length) {
            result.add(new ArrayList<>(curList));
            return;
        }
        for (int i = 0; i < length; i++) {
            if (canPut(num, i)) {
                shuList.add(i);
                int pie = num + i;
                pieList.add(pie);
                int na = num - i;
                naList.add(na);
                curList.add(build(i));
                handle(num + 1, curList);
                shuList.remove(i);
                pieList.remove(pie);
                naList.remove(na);
                curList.remove(curList.size() - 1);
            }
        }
    }

    private String build(int i) {
        StringBuilder s = new StringBuilder();
        for (int j = 0; j < i; j++) {
            s.append('.');
        }
        s.append('Q');
        for (int j = i + 1; j < length; j++) {
            s.append('.');
        }
        return s.toString();
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
