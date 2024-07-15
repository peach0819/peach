package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/15
 * 给你一个 无重叠的 ，按照区间起始端点排序的区间列表 intervals，其中 intervals[i] = [starti, endi] 表示第 i 个区间的开始和结束，并且 intervals 按照 starti 升序排列。同样给定一个区间 newInterval = [start, end] 表示另一个区间的开始和结束。
 * 在 intervals 中插入区间 newInterval，使得 intervals 依然按照 starti 升序排列，且区间之间不重叠（如果有必要的话，可以合并区间）。
 * 返回插入之后的 intervals。
 * 注意 你不需要原地修改 intervals。你可以创建一个新数组然后返回它。
 * 示例 1：
 * 输入：intervals = [[1,3],[6,9]], newInterval = [2,5]
 * 输出：[[1,5],[6,9]]
 * 示例 2：
 * 输入：intervals = [[1,2],[3,5],[6,7],[8,10],[12,16]], newInterval = [4,8]
 * 输出：[[1,2],[3,10],[12,16]]
 * 解释：这是因为新的区间 [4,8] 与 [3,5],[6,7],[8,10] 重叠。
 * 提示：
 * 0 <= intervals.length <= 104
 * intervals[i].length == 2
 * 0 <= starti <= endi <= 105
 * intervals 根据 starti 按 升序 排列
 * newInterval.length == 2
 * 0 <= start <= end <= 105
 */
public class LC57_insert_interval {

    public int[][] insert(int[][] intervals, int[] newInterval) {
        if (intervals.length == 0) {
            return new int[][]{ { newInterval[0], newInterval[1] } };
        }

        int begin = 0;
        while (begin < intervals.length) {
            int[] interval = intervals[begin];
            if (interval[1] >= newInterval[0]) {
                break;
            }
            begin++;
        }

        int end = intervals.length - 1;
        while (end >= 0) {
            int[] interval = intervals[end];
            if (interval[0] <= newInterval[1]) {
                break;
            }
            end--;
        }
        List<int[]> list = handle(intervals, newInterval, begin, end);

        int[][] result = new int[begin + intervals.length - 1 - end + list.size()][2];
        for (int i = 0; i < begin; i++) {
            result[i] = intervals[i];
        }
        for (int i = 0; i < list.size(); i++) {
            result[begin + i] = list.get(i);
        }
        for (int i = 1; i < intervals.length - end; i++) {
            result[begin - 1 + list.size() + i] = intervals[end + i];
        }
        return result;
    }

    private List<int[]> handle(int[][] intervals, int[] newInterval, int begin, int end) {
        List<int[]> result = new ArrayList<>();
        if (begin > end) {
            result.add(newInterval);
            return result;
        }
        boolean cross = false;
        int[] re = new int[2];
        re[0] = Math.min(intervals[begin][0], newInterval[0]);
        re[1] = Math.max(intervals[end][1], newInterval[1]);
        result.add(re);
        return result;
    }
}
