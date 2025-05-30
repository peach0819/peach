package com.peach.algo.LC501_550_toVip;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2025/3/10
 * 给定一个二进制数组 nums , 找到含有相同数量的 0 和 1 的最长连续子数组，并返回该子数组的长度。
 * 示例 1：
 * 输入：nums = [0,1]
 * 输出：2
 * 说明：[0, 1] 是具有相同数量 0 和 1 的最长连续子数组。
 * 示例 2：
 * 输入：nums = [0,1,0]
 * 输出：2
 * 说明：[0, 1] (或 [1, 0]) 是具有相同数量 0 和 1 的最长连续子数组。
 * 示例 3：
 * 输入：nums = [0,1,1,1,1,1,0,0,0]
 * 输出：6
 * 解释：[1,1,1,0,0,0] 是具有相同数量 0 和 1 的最长连续子数组。
 * 提示：
 * 1 <= nums.length <= 105
 * nums[i] 不是 0 就是 1
 */
public class LC525_contiguous_array {

    /**
     * 跟LC523可以一个思路，记录每个位置当前节点连续01的数量，如果两个位置数量相同，那中间间隔一定满足条件
     */
    public int findMaxLength(int[] nums) {
        Map<Integer, Integer> map = new HashMap<>();
        int num = 0;
        int result = 0;
        map.put(0, -1);
        for (int i = 0; i < nums.length; i++) {
            int cur = nums[i];
            if (cur == 0) {
                num--;
            } else {
                num++;
            }
            if (map.containsKey(num)) {
                result = Math.max(result, i - map.get(num));
            } else {
                map.put(num, i);
            }
        }
        return result;
    }
}

