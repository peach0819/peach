package com.peach.algo.LC401_450_toVip;

/**
 * @author feitao.zt
 * @date 2024/10/24
 * 如果一个数列 至少有三个元素 ，并且任意两个相邻元素之差相同，则称该数列为等差数列。
 * 例如，[1,3,5,7,9]、[7,7,7,7] 和 [3,-1,-5,-9] 都是等差数列。
 * 给你一个整数数组 nums ，返回数组 nums 中所有为等差数组的 子数组 个数。
 * 子数组 是数组中的一个连续序列。
 * 示例 1：
 * 输入：nums = [1,2,3,4]
 * 输出：3
 * 解释：nums 中有三个子等差数组：[1, 2, 3]、[2, 3, 4] 和 [1,2,3,4] 自身。
 * 示例 2：
 * 输入：nums = [1]
 * 输出：0
 * 提示：
 * 1 <= nums.length <= 5000
 * -1000 <= nums[i] <= 1000
 */
public class LC413_arithmetic_slices {

    int result = 0;

    public int numberOfArithmeticSlices(int[] nums) {
        if (nums.length <= 2) {
            return 0;
        }
        int index = 0;
        while (index <= nums.length - 3) {
            int curIndex = index;
            int gap = nums[curIndex + 1] - nums[curIndex];
            while (curIndex <= nums.length - 2) {
                if (nums[curIndex + 1] - nums[curIndex] != gap) {
                    break;
                }
                curIndex++;
            }
            result += get(curIndex - index + 1);
            index = curIndex;
        }
        return result;
    }

    /**
     * 这里求和也用等差数列公式
     * (首项+末项)*项数/2
     */
    private int get(int n) {
        if (n < 3) {
            return 0;
        }
        return (n - 1) * (n - 2) / 2;
    }
}
