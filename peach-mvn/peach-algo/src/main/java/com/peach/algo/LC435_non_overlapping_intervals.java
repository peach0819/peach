package com.peach.algo;

import java.util.Arrays;
import java.util.Comparator;

/**
 * @author feitao.zt
 * @date 2024/12/9
 * 给定一个区间的集合 intervals ，其中 intervals[i] = [starti, endi] 。返回 需要移除区间的最小数量，使剩余区间互不重叠 。
 * 注意 只在一点上接触的区间是 不重叠的。例如 [1, 2] 和 [2, 3] 是不重叠的。
 * 示例 1:
 * 输入: intervals = [[1,2],[2,3],[3,4],[1,3]]
 * 输出: 1
 * 解释: 移除 [1,3] 后，剩下的区间没有重叠。
 * 示例 2:
 * 输入: intervals = [ [1,2], [1,2], [1,2] ]
 * 输出: 2
 * 解释: 你需要移除两个 [1,2] 来使剩下的区间没有重叠。
 * 示例 3:
 * 输入: intervals = [ [1,2], [2,3] ]
 * 输出: 0
 * 解释: 你不需要移除任何区间，因为它们已经是无重叠的了。
 * 提示:
 * 1 <= intervals.length <= 105
 * intervals[i].length == 2
 * -5 * 104 <= starti < endi <= 5 * 104
 */
public class LC435_non_overlapping_intervals {

    public static void main(String[] args) {
        //int[][] i1 = { { 0, 2 }, { 1, 3 }, { 1, 3 }, { 2, 4 }, { 3, 5 }, { 3, 5 }, { 4, 6 } };
        int[][] i1 = { { 1, 2 }, { 1, 2 }, { 1, 2 } };
        new LC435_non_overlapping_intervals().eraseOverlapIntervals(i1);
    }

    //Map<Integer, Set<Integer>> map = new HashMap<>();
    //
    //public int eraseOverlapIntervals(int[][] intervals) {
    //    Set<Integer> equalsToDelete = new HashSet<>();
    //    for (int i = 1; i < intervals.length; i++) {
    //        int[] curI = intervals[i];
    //        for (int j = 0; j < i; j++) {
    //            int[] curJ = intervals[j];
    //            if (isCross(curI, curJ)) {
    //                if (curI[0] == curJ[0] && curI[1] == curJ[1]) {
    //                    equalsToDelete.add(j);
    //                }
    //                map.putIfAbsent(i, new HashSet<>());
    //                map.putIfAbsent(j, new HashSet<>());
    //                map.get(i).add(j);
    //                map.get(j).add(i);
    //            }
    //        }
    //    }
    //    int result = 0;
    //    for (Integer i : equalsToDelete) {
    //        Set<Integer> curMaxSet = map.get(i);
    //        for (Integer curi : curMaxSet) {
    //            if (map.get(curi).size() == 1) {
    //                map.remove(curi);
    //            } else {
    //                map.get(curi).remove(i);
    //            }
    //        }
    //        map.remove(i);
    //        result++;
    //    }
    //    while (!map.isEmpty()) {
    //        int maxValue = -1;
    //        int maxi = 0;
    //        for (Map.Entry<Integer, Set<Integer>> entry : map.entrySet()) {
    //            if (entry.getValue().size() > maxValue) {
    //                maxi = entry.getKey();
    //                maxValue = entry.getValue().size();
    //            }
    //        }
    //        Set<Integer> curMaxSet = map.get(maxi);
    //        for (Integer i : curMaxSet) {
    //            if (map.get(i).size() == 1) {
    //                map.remove(i);
    //            } else {
    //                map.get(i).remove(maxi);
    //            }
    //        }
    //        map.remove(maxi);
    //        result++;
    //    }
    //    return result;
    //}
    //
    //private boolean isCross(int[] i1, int[] i2) {
    //    return i2[0] < i1[1] && i2[1] > i1[0];
    //}

    /**
     * 我是傻逼
     * 贪心算法，贪最右点
     */
    public int eraseOverlapIntervals(int[][] intervals) {
        if (intervals.length == 0) {
            return 0;
        }

        Arrays.sort(intervals, Comparator.comparingInt(interval -> interval[1]));

        int n = intervals.length;
        int right = intervals[0][1];
        int ans = 1;
        for (int i = 1; i < n; ++i) {
            if (intervals[i][0] >= right) {
                ++ans;
                right = intervals[i][1];
            }
        }
        return n - ans;
    }

}
