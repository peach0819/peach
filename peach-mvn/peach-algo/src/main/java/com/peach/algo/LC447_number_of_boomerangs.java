package com.peach.algo;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/12/12
 * 给定平面上 n 对 互不相同 的点 points ，其中 points[i] = [xi, yi] 。回旋镖 是由点 (i, j, k) 表示的元组 ，其中 i 和 j 之间的欧式距离和 i 和 k 之间的欧式距离相等（需要考虑元组的顺序）。
 * 返回平面上所有回旋镖的数量。
 * 示例 1：
 * 输入：points = [[0,0],[1,0],[2,0]]
 * 输出：2
 * 解释：两个回旋镖为 [[1,0],[0,0],[2,0]] 和 [[1,0],[2,0],[0,0]]
 * 示例 2：
 * 输入：points = [[1,1],[2,2],[3,3]]
 * 输出：2
 * 示例 3：
 * 输入：points = [[1,1]]
 * 输出：0
 * 提示：
 * n == points.length
 * 1 <= n <= 500
 * points[i].length == 2
 * -104 <= xi, yi <= 104
 * 所有点都 互不相同
 */
public class LC447_number_of_boomerangs {

    /**
     * 以每个节点作为回旋镖顶点判断
     */
    public int numberOfBoomerangs(int[][] points) {
        int result = 0;
        Map<Integer, Integer> map = new HashMap<>(points.length);
        for (int i = 0; i < points.length; i++) {
            map.clear();
            for (int j = 0; j < points.length; j++) {
                if (i == j) {
                    continue;
                }
                int x = points[j][0] - points[i][0];
                int y = points[j][1] - points[i][1];
                int distance = x * x + y * y;
                map.put(distance, map.getOrDefault(distance, 0) + 1);
            }
            for (Integer value : map.values()) {
                result += value * (value - 1);
            }
        }
        return result;
    }

}
