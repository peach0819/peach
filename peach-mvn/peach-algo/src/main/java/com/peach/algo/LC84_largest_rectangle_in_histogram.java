package com.peach.algo;

import java.util.ArrayDeque;
import java.util.Deque;

/**
 * @author feitao.zt
 * @date 2023/7/10
 * 给定 n 个非负整数，用来表示柱状图中各个柱子的高度。每个柱子彼此相邻，且宽度为 1 。
 * 求在该柱状图中，能够勾勒出来的矩形的最大面积。
 *  
 * 示例 1:
 * 输入：heights = [2,1,5,6,2,3]
 * 输出：10
 * 解释：最大的矩形为图中红色区域，面积为 10
 * 示例 2：
 * 输入： heights = [2,4]
 * 输出： 4
 *  
 * 提示：
 * 1 <= heights.length <=105
 * 0 <= heights[i] <= 104
 * 来源：力扣（LeetCode）
 * 链接：https://leetcode.cn/problems/largest-rectangle-in-histogram
 * 著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
 */
public class LC84_largest_rectangle_in_histogram {

    public int largestRectangleArea1(int[] heights) {
        int max = 0;
        for (int i = 0; i < heights.length; i++) {
            int curHeight = heights[i];
            int j = 0;
            while ((i - j) >= 0 && heights[i - j] >= curHeight) {
                j++;
            }
            int k = 0;
            while ((i + k) < heights.length && heights[i + k] >= curHeight) {
                k++;
            }
            int curArea = curHeight * (j + k - 1);
            max = Math.max(curArea, max);
        }
        return max;
    }

    public static int largestRectangleArea(int[] heights) {
        int res = 0;
        Deque<Integer> stack = new ArrayDeque<>();
        int[] arr = new int[heights.length + 2];
        for (int i = 1; i < heights.length + 1; i++) {
            arr[i] = heights[i - 1];
        }
        for (int i = 0; i < arr.length; i++) {
            while (!stack.isEmpty() && arr[stack.peek()] > arr[i]) {
                int cur = stack.pop();
                res = Math.max(res, (i - stack.peek() - 1) * arr[cur]);
            }
            stack.push(i);
        }
        return res;
    }

    public static void main(String[] args) {
        int[] heights = new int[]{ 2, 1, 5, 6, 2, 3 };
        int i = largestRectangleArea(heights);
        System.out.println(i);
    }

}
