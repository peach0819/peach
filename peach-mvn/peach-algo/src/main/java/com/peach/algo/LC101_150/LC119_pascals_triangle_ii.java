package com.peach.algo.LC101_150;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/5
 * 给定一个非负索引 rowIndex，返回「杨辉三角」的第 rowIndex 行。
 * 在「杨辉三角」中，每个数是它左上方和右上方的数的和。
 * 示例 1:
 * 输入: rowIndex = 3
 * 输出: [1,3,3,1]
 * 示例 2:
 * 输入: rowIndex = 0
 * 输出: [1]
 * 示例 3:
 * 输入: rowIndex = 1
 * 输出: [1,1]
 */
public class LC119_pascals_triangle_ii {

    public List<Integer> getRow(int rowIndex) {
        List<Integer> temp = null;
        for (int i = 0; i <= rowIndex; i++) {
            List<Integer> cur = new ArrayList<>();
            for (int j = 0; j <= i; j++) {
                if (j == 0 || j == i) {
                    cur.add(1);
                } else {
                    cur.add(temp.get(j - 1) + temp.get(j));
                }
            }
            temp = cur;
        }
        return temp;
    }
}
