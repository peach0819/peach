package com.peach.algo.LC451_500_toVip;

import java.util.Random;

/**
 * @author feitao.zt
 * @date 2025/2/7
 * 给定一个由非重叠的轴对齐矩形的数组 rects ，其中 rects[i] = [ai, bi, xi, yi] 表示 (ai, bi) 是第 i 个矩形的左下角点，(xi, yi) 是第 i 个矩形的右上角点。设计一个算法来随机挑选一个被某一矩形覆盖的整数点。矩形周长上的点也算做是被矩形覆盖。所有满足要求的点必须等概率被返回。
 * 在给定的矩形覆盖的空间内的任何整数点都有可能被返回。
 * 请注意 ，整数点是具有整数坐标的点。
 * 实现 Solution 类:
 * Solution(int[][] rects) 用给定的矩形数组 rects 初始化对象。
 * int[] pick() 返回一个随机的整数点 [u, v] 在给定的矩形所覆盖的空间内。
 * 示例 1：
 * 输入:
 * ["Solution", "pick", "pick", "pick", "pick", "pick"]
 * [[[[-2, -2, 1, 1], [2, 2, 4, 6]]], [], [], [], [], []]
 * 输出:
 * [null, [1, -2], [1, -1], [-1, -2], [-2, -2], [0, 0]]
 * 解释：
 * Solution solution = new Solution([[-2, -2, 1, 1], [2, 2, 4, 6]]);
 * solution.pick(); // 返回 [1, -2]
 * solution.pick(); // 返回 [1, -1]
 * solution.pick(); // 返回 [-1, -2]
 * solution.pick(); // 返回 [-2, -2]
 * solution.pick(); // 返回 [0, 0]
 * 提示：
 * 1 <= rects.length <= 100
 * rects[i].length == 4
 * -109 <= ai < xi <= 109
 * -109 <= bi < yi <= 109
 * xi - ai <= 2000
 * yi - bi <= 2000
 * 所有的矩形不重叠。
 * pick 最多被调用 104 次。
 */
public class LC497_random_point_in_non_overlapping_rectangles {

    /**
     * Your Solution object will be instantiated and called as such:
     * Solution obj = new Solution(rects);
     * int[] param_1 = obj.pick();
     */
    class Solution {

        Random random = new Random();

        int[] area;
        int[][] rects;
        int total;

        public Solution(int[][] rects) {
            this.area = new int[rects.length];
            this.rects = rects;
            int total = 0;
            for (int i = 0; i < rects.length; i++) {
                int x1 = rects[i][0];
                int y1 = rects[i][1];
                int x2 = rects[i][2];
                int y2 = rects[i][3];
                //比如0 1 2, 2-0 = 2, 但是实际上有3个数，所以要+1
                total += (x2 - x1 + 1) * (y2 - y1 + 1);
                area[i] = total;
            }
            this.total = total;
        }

        public int[] pick() {
            int val = random.nextInt(total) + 1;
            int match = match(val, 0, area.length - 1);
            int[] rect = rects[match];
            int x1 = rect[0];
            int y1 = rect[1];
            int x2 = rect[2];
            int y2 = rect[3];
            return new int[]{ random.nextInt(x2 - x1 + 1) + x1, random.nextInt(y2 - y1 + 1) + y1 };
        }

        /**
         * 二分法用begin = end来匹配比较准确，只要提前处理val = mid的情况，就可以用 mid+1去处理
         */
        private int match(int val, int begin, int end) {
            if (begin == end) {
                return begin;
            }
            int mid = begin + (end - begin) / 2;
            if (val == area[mid]) {
                return mid;
            }
            if (val < area[mid]) {
                return match(val, begin, mid);
            } else {
                return match(val, mid + 1, end);
            }
        }
    }

}
