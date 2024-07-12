package com.peach.algo.LC0_50;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2023/7/11
 * 给定 n 个非负整数表示每个宽度为 1 的柱子的高度图，计算按此排列的柱子，下雨之后能接多少雨水。
 *  
 * 示例 1：
 * 输入：height = [0,1,0,2,1,0,1,3,2,1,2,1]
 * 输出：6
 * 解释：上面是由数组 [0,1,0,2,1,0,1,3,2,1,2,1] 表示的高度图，在这种情况下，可以接 6 个单位的雨水（蓝色部分表示雨水）。
 * 示例 2：
 * 输入：height = [4,2,0,3,2,5]
 * 输出：9
 *  
 * 提示：
 * n == height.length
 * 1 <= n <= 2 * 104
 * 0 <= height[i] <= 105
 * 来源：力扣（LeetCode）
 * 链接：https://leetcode.cn/problems/trapping-rain-water
 * 著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
 */
public class LC42_trapping_rain_water {

    public int trap(int[] height) {
        int leftMax = 0;
        int rightMax = 0;
        Map<Integer, Integer[]> map = new HashMap<>();
        for (int i = 0; i < height.length; i++) {
            map.putIfAbsent(i, new Integer[2]);
            map.putIfAbsent(height.length - 1 - i, new Integer[2]);

            leftMax = Math.max(leftMax, height[i]);
            map.get(i)[0] = leftMax;

            rightMax = Math.max(rightMax, height[height.length - 1 - i]);
            map.get(height.length - 1 - i)[1] = rightMax;
        }

        int area = 0;
        for (int i = 0; i < height.length; i++) {
            Integer[] intArr = map.get(i);
            int curHeight = height[i];
            int curBound = Math.min(intArr[0], intArr[1]);
            if (curBound > curHeight) {
                area += (curBound - curHeight);
            }
        }
        return area;
    }
}
