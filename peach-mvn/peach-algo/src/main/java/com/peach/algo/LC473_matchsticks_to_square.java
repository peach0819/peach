package com.peach.algo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2025/1/13
 * 你将得到一个整数数组 matchsticks ，其中 matchsticks[i] 是第 i 个火柴棒的长度。你要用 所有的火柴棍 拼成一个正方形。你 不能折断 任何一根火柴棒，但你可以把它们连在一起，而且每根火柴棒必须 使用一次 。
 * 如果你能使这个正方形，则返回 true ，否则返回 false 。
 * 示例 1:
 * 输入: matchsticks = [1,1,2,2,2]
 * 输出: true
 * 解释: 能拼成一个边长为2的正方形，每边两根火柴。
 * 示例 2:
 * 输入: matchsticks = [3,3,3,3,4]
 * 输出: false
 * 解释: 不能用所有火柴拼成一个正方形。
 * 提示:
 * 1 <= matchsticks.length <= 15
 * 1 <= matchsticks[i] <= 108
 */
public class LC473_matchsticks_to_square {

    public boolean makesquare(int[] nums) {
        if (nums == null || nums.length < 4) {
            return false;
        }
        int sum = 0;
        for (int num : nums) {
            sum += num;
        }
        if (sum % 4 != 0) {
            return false;
        }
        Arrays.sort(nums);
        boolean[] used = new boolean[nums.length];
        return helper(nums, nums.length - 1, 0, sum / 4, 0, used);
    }

    public boolean helper(int[] nums, int index, int sum, int sideLength, int completedSides, boolean[] used) {
        if (completedSides == 3) {
            return true;
        }
        if (sum == sideLength) {
            return helper(nums, nums.length - 1, 0, sideLength, completedSides + 1, used);
        }
        if (sum > sideLength) {
            return false;
        }
        for (int i = index; i >= 0; i--) {
            if (used[i]) {
                continue;
            }
            used[i] = true;
            if (helper(nums, i - 1, sum + nums[i], sideLength, completedSides, used)) {
                return true;
            }
            used[i] = false;
            while (i > 0 && nums[i] == nums[i - 1]) {
                i--;
            }
        }
        return false;
    }

}
