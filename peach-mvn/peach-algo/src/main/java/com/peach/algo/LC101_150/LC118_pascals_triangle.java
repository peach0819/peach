package com.peach.algo.LC101_150;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/5
 * 给定一个非负整数 numRows，生成「杨辉三角」的前 numRows 行。
 * 在「杨辉三角」中，每个数是它左上方和右上方的数的和。
 * 示例 1:
 * 输入: numRows = 5
 * 输出: [[1],[1,1],[1,2,1],[1,3,3,1],[1,4,6,4,1]]
 * 示例 2:
 * 输入: numRows = 1
 * 输出: [[1]]
 * 提示:
 * 1 <= numRows <= 30
 */
public class LC118_pascals_triangle {

    public List<List<Integer>> generate(int numRows) {
        List<List<Integer>> result = new ArrayList<>();
        List<Integer> list1 = new ArrayList<>();
        list1.add(1);
        result.add(list1);

        List<Integer> temp = list1;
        for (int i = 1; i < numRows; i++) {
            List<Integer> listi = new ArrayList<>();
            for (int j = 0; j <= i; j++) {
                if (j == 0 || j == i) {
                    listi.add(1);
                } else {
                    listi.add(temp.get(j - 1) + temp.get(j));
                }
            }
            result.add(listi);
            temp = listi;
        }
        return result;
    }
}
