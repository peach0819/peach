package com.peach.algo.LC651_700_toVip;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2026/1/27
 * 给定一个非空且只包含非负数的整数数组 nums，数组的 度 的定义是指数组里任一元素出现频数的最大值。
 * 你的任务是在 nums 中找到与 nums 拥有相同大小的度的最短连续子数组，返回其长度。
 * 示例 1：
 * 输入：nums = [1,2,2,3,1]
 * 输出：2
 * 解释：
 * 输入数组的度是 2 ，因为元素 1 和 2 的出现频数最大，均为 2 。
 * 连续子数组里面拥有相同度的有如下所示：
 * [1, 2, 2, 3, 1], [1, 2, 2, 3], [2, 2, 3, 1], [1, 2, 2], [2, 2, 3], [2, 2]
 * 最短连续子数组 [2, 2] 的长度为 2 ，所以返回 2 。
 * 示例 2：
 * 输入：nums = [1,2,2,3,1,4,2]
 * 输出：6
 * 解释：
 * 数组的度是 3 ，因为元素 2 重复出现 3 次。
 * 所以 [2,2,3,1,4,2] 是最短子数组，因此返回 6 。
 * 提示：
 * nums.length 在 1 到 50,000 范围内。
 * nums[i] 是一个在 0 到 49,999 范围内的整数。
 */
public class LC697_degree_of_an_array {

    public int findShortestSubArray(int[] nums) {
        Map<Integer, int[]> map = new HashMap<>();
        for (int i = 0; i < nums.length; i++) {
            int cur = nums[i];
            if (!map.containsKey(cur)) {
                map.put(cur, new int[]{ 1, i, i });
            } else {
                int[] ints = map.get(cur);
                ints[0]++;
                ints[2] = i;
            }
        }
        List<int[]> list = new ArrayList<>(map.values());
        return list.stream().max((a, b) -> {
            if (a[0] == b[0]) {
                return (b[2] - b[1]) - (a[2] - a[1]);
            }
            return a[0] - b[0];
        }).map(a -> a[2] - a[1] + 1).orElse(0);
    }
}
