package com.peach.algo;

import java.util.Arrays;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2025/5/6
 * 给定一个 24 小时制（小时:分钟 "HH:MM"）的时间列表，找出列表中任意两个时间的最小时间差并以分钟数表示。
 * 示例 1：
 * 输入：timePoints = ["23:59","00:00"]
 * 输出：1
 * 示例 2：
 * 输入：timePoints = ["00:00","23:59","00:00"]
 * 输出：0
 * 提示：
 * 2 <= timePoints.length <= 2 * 104
 * timePoints[i] 格式为 "HH:MM"
 */
public class LC539_minimum_time_difference {

    public int findMinDifference(List<String> timePoints) {
        //抽屉原理，大于1440时一定有两个重复
        if (timePoints.size() > 1440) {
            return 0;
        }
        int[] array = new int[timePoints.size()];
        for (int i = 0; i < timePoints.size(); i++) {
            String timePoint = timePoints.get(i);
            int cur = (timePoint.charAt(0) - '0') * 600 + (timePoint.charAt(1) - '0') * 60
                    + (timePoint.charAt(3) - '0') * 10 + (timePoint.charAt(4) - '0');
            array[i] = cur;
        }
        Arrays.sort(array);
        int min = Integer.MAX_VALUE;
        for (int i = 0; i < array.length; i++) {
            if (i == 0) {
                min = 1440 + array[0] - array[array.length - 1];
                continue;
            }
            min = Math.min(min, array[i] - array[i - 1]);
        }
        return min;
    }
}
