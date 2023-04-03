package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2023/4/3
 * 给定一个长度为 n 的整数数组 height 。有 n 条垂线，第 i 条线的两个端点是 (i, 0) 和 (i, height[i]) 。
 * 找出其中的两条线，使得它们与 x 轴共同构成的容器可以容纳最多的水。
 * 返回容器可以储存的最大水量。
 * 说明：你不能倾斜容器。
 * 输入：[1,8,6,2,5,4,8,3,7]
 * 输出：49
 * 解释：图中垂直线代表输入数组 [1,8,6,2,5,4,8,3,7]。在此情况下，容器能够容纳水（表示为蓝色部分）的最大值为 49。
 * 来源：力扣（LeetCode）
 * 链接：https://leetcode.cn/problems/container-with-most-water
 * 著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
 */
public class LC11_container_with_most_water {

    public int maxArea(int[] height) {
        int begin = 0;
        int end = height.length - 1;
        int max = area(height, begin, end);
        int beginHeight;
        int endHeight;
        while (begin < end) {
            beginHeight = height[begin];
            endHeight = height[end];
            int curArea = area(height, begin, end);
            if (curArea > max) {
                max = curArea;
            }
            if (beginHeight < endHeight) {
                do {
                    begin++;
                } while (height[begin] <= beginHeight && begin < end);
            } else {
                do {
                    end--;
                } while (height[end] <= endHeight && begin < end);
            }
        }
        return max;
    }

    private int area(int[] height, int begin, int end) {
        return Math.min(height[begin], height[end]) * (end - begin);
    }
}
