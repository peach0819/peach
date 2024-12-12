package com.peach.algo.LC401_450_toVip;

import java.util.HashSet;
import java.util.PriorityQueue;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/10/29
 * 给你一个非空数组，返回此数组中 第三大的数 。如果不存在，则返回数组中最大的数。
 * 示例 1：
 * 输入：[3, 2, 1]
 * 输出：1
 * 解释：第三大的数是 1 。
 * 示例 2：
 * 输入：[1, 2]
 * 输出：2
 * 解释：第三大的数不存在, 所以返回最大的数 2 。
 * 示例 3：
 * 输入：[2, 2, 3, 1]
 * 输出：1
 * 解释：注意，要求返回第三大的数，是指在所有不同数字中排第三大的数。
 * 此例中存在两个值为 2 的数，它们都排第二。在所有不同数字中排第三大的数为 1 。
 * 提示：
 * 1 <= nums.length <= 104
 * -231 <= nums[i] <= 231 - 1
 * 进阶：你能设计一个时间复杂度 O(n) 的解决方案吗？
 */
public class LC414_third_maximum_number {

    public static void main(String[] args) {
        new LC414_third_maximum_number().thirdMax(new int[]{ 3, 2, 1 });
    }

    public int thirdMax(int[] nums) {
        Integer big1 = null;
        Integer big2 = null;
        Integer big3 = null;
        big1 = nums[0];
        for (int i = 1; i < nums.length; i++) {
            Integer num = nums[i];
            if (big3 != null && num < big3) {
                continue;
            }
            if (num.equals(big1) || num.equals(big2) || num.equals(big3)) {
                continue;
            }
            if (num > big1) {
                big3 = big2;
                big2 = big1;
                big1 = num;
            } else if (big2 == null || num > big2) {
                big3 = big2;
                big2 = num;
            } else if (big3 == null || num > big3) {
                big3 = num;
            }
        }
        return big3 != null ? big3 : big1;
    }

    public int thirdMax1(int[] nums) {
        PriorityQueue<Integer> queue = new PriorityQueue<>((a, b) -> {
            if (a.equals(b)) {
                return 0;
            } else if (a > b) {
                return 1;
            }
            return -1;
        });
        Set<Integer> set = new HashSet<>();
        for (int num : nums) {
            if (set.add(num)) {
                queue.offer(num);
            }
        }
        if (queue.size() < 3) {
            return queue.poll();
        }
        queue.poll();
        queue.poll();
        return queue.poll();
    }

}
