package com.peach.algo.LC51_100;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2023/8/30
 * 以数组 intervals 表示若干个区间的集合，其中单个区间为 intervals[i] = [starti, endi] 。请你合并所有重叠的区间，并返回 一个不重叠的区间数组，该数组需恰好覆盖输入中的所有区间 。
 * 示例 1：
 * 输入：intervals = [[1,3],[2,6],[8,10],[15,18]]
 * 输出：[[1,6],[8,10],[15,18]]
 * 解释：区间 [1,3] 和 [2,6] 重叠, 将它们合并为 [1,6].
 * 示例 2：
 * 输入：intervals = [[1,4],[4,5]]
 * 输出：[[1,5]]
 * 解释：区间 [1,4] 和 [4,5] 可被视为重叠区间。
 */
public class LC56_merge_intervals {

    public int[][] merge1(int[][] intervals) {
        List<int[]> list = new ArrayList<>();
        Arrays.sort(intervals, Comparator.comparing(i -> i[0]));
        int index = 0;
        for (int i = 0; i < intervals.length; i++) {
            if (index >= intervals.length) {
                break;
            }
            int[] cur = intervals[index];
            index++;
            int left = cur[0];
            int right = cur[1];

            int[] next;
            while (index < intervals.length) {
                next = intervals[index];
                if (next[0] > right) {
                    break;
                }
                right = Math.max(right, next[1]);
                index++;
            }
            list.add(new int[]{ left, right });
        }
        return list.toArray(new int[list.size()][]);
    }

    public int[][] merge(int[][] intervals) {
        if (intervals.length == 0) {
            return new int[0][];
        }
        Arrays.sort(intervals, Comparator.comparingInt(interval -> interval[0]));

        List<int[]> list = new ArrayList<>();
        int[] cur = intervals[0];
        for (int i = 0; i < intervals.length; i++) {
            int[] val = intervals[i];
            if (list.isEmpty()) {
                list.add(cur);
                continue;
            }
            if (val[0] <= cur[1]) {
                cur[1] = Math.max(cur[1], val[1]);
            } else {
                cur = val;
                list.add(cur);
            }
        }
        return list.toArray(new int[list.size()][]);
    }

}
