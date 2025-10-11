package com.peach.algo.LC601_650_toVip;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2025/9/10
 * 这里有 n 门不同的在线课程，按从 1 到 n 编号。给你一个数组 courses ，其中 courses[i] = [durationi, lastDayi] 表示第 i 门课将会 持续 上 durationi 天课，并且必须在不晚于 lastDayi 的时候完成。
 * 你的学期从第 1 天开始。且不能同时修读两门及两门以上的课程。
 * 返回你最多可以修读的课程数目。
 * 示例 1：
 * 输入：courses = [[100, 200], [200, 1300], [1000, 1250], [2000, 3200]]
 * 输出：3
 * 解释：
 * 这里一共有 4 门课程，但是你最多可以修 3 门：
 * 首先，修第 1 门课，耗费 100 天，在第 100 天完成，在第 101 天开始下门课。
 * 第二，修第 3 门课，耗费 1000 天，在第 1100 天完成，在第 1101 天开始下门课程。
 * 第三，修第 2 门课，耗时 200 天，在第 1300 天完成。
 * 第 4 门课现在不能修，因为将会在第 3300 天完成它，这已经超出了关闭日期。
 * 示例 2：
 * 输入：courses = [[1,2]]
 * 输出：1
 * 示例 3：
 * 输入：courses = [[3,2],[4,3]]
 * 输出：0
 * 提示:
 * 1 <= courses.length <= 104
 * 1 <= durationi, lastDayi <= 104
 */
public class LC630_course_schedule_iii {

    public static void main(String[] args) {
        LC630_course_schedule_iii lc630_course_schedule_iii = new LC630_course_schedule_iii();
        //[[3,2],[4,3]]
        //int[][] courses = {{3, 2}, {4, 3}};
        //[[5,5],[4,6],[2,6]]
        int[][] courses = { { 5, 5 }, { 4, 6 }, { 2, 6 } };
        //int[][] courses = { { 100, 200 }, { 200, 1300 }, { 1000, 1250 }, { 2000, 3200 } };

        int i = lc630_course_schedule_iii.scheduleCourse(courses);
        System.out.println(i);
    }

    public int scheduleCourse(int[][] courses) {
        Arrays.sort(courses, (a, b) -> a[1] - b[1]);
        // i 上了几门课了  xxxx表示上到第几门课的时候，最长的天数
        // dp[i] = xxxx
        int[] dp = new int[courses.length + 1];
        Arrays.fill(dp, 100000);
        dp[0] = 0;
        int max = 0;
        for (int[] course : courses) {
            //这门课上的情况
            int curMax = max;
            for (int j = curMax; j >= 0; j--) {
                int last = dp[j];
                if (last + course[0] > course[1]) {
                    continue;
                }
                dp[j + 1] = Math.min(dp[j + 1], last + course[0]);
                max = Math.max(max, j + 1);
            }
        }
        return max;
    }
}
