package com.peach.algo;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2024/9/3
 * 给你一个整数数组 nums 和两个整数 indexDiff 和 valueDiff 。
 * 找出满足下述条件的下标对 (i, j)：
 * i != j,
 * abs(i - j) <= indexDiff
 * abs(nums[i] - nums[j]) <= valueDiff
 * 如果存在，返回 true ；否则，返回 false 。
 * 示例 1：
 * 输入：nums = [1,2,3,1], indexDiff = 3, valueDiff = 0
 * 输出：true
 * 解释：可以找出 (i, j) = (0, 3) 。
 * 满足下述 3 个条件：
 * i != j --> 0 != 3
 * abs(i - j) <= indexDiff --> abs(0 - 3) <= 3
 * abs(nums[i] - nums[j]) <= valueDiff --> abs(1 - 1) <= 0
 * 示例 2：
 * 输入：nums = [1,5,9,1,5,9], indexDiff = 2, valueDiff = 3
 * 输出：false
 * 解释：尝试所有可能的下标对 (i, j) ，均无法满足这 3 个条件，因此返回 false 。
 * 提示：
 * 2 <= nums.length <= 105
 * -109 <= nums[i] <= 109
 * 1 <= indexDiff <= nums.length
 * 0 <= valueDiff <= 109
 */
public class LC220_contains_duplicate_iii {

    public static void main(String[] args) {
        new LC220_contains_duplicate_iii().containsNearbyAlmostDuplicate(new int[]{ 1, 2, 3, 1 }, 3, 0);
    }

    /**
     * 我是傻逼
     */
    public boolean containsNearbyAlmostDuplicate(int[] nums, int indexDiff, int valueDiff) {
        // 如果数组为空或者要求的indexDiff或valueDiff不合理，直接返回false
        if (nums == null || nums.length < 2 || indexDiff < 1 || valueDiff < 0) {
            return false;
        }

        // 初始化最小值和最大值
        int min = Integer.MAX_VALUE, max = Integer.MIN_VALUE;

        // 找到数组中的最小值和最大值
        for (int num : nums) {
            if (num < min) {
                min = num;
            }
            if (num > max) {
                max = num;
            }
        }

        // 计算桶的宽度
        int bucketWidth = valueDiff + 1;

        // 计算桶的数量
        int numBuckets = (max - min) / bucketWidth + 1;

        // 桶数组，每个桶初始值设为Integer.MIN_VALUE
        int[] buckets = new int[numBuckets];
        Arrays.fill(buckets, Integer.MIN_VALUE);

        // 遍历数组，处理每个元素
        for (int i = 0; i < nums.length; i++) {
            int num = nums[i];
            // 计算当前元素所属的桶索引
            int bucketIndex = (num - min) / bucketWidth;

            // 检查当前桶中是否已经有元素，满足差值条件
            if (buckets[bucketIndex] != Integer.MIN_VALUE) {
                return true;
            }

            // 检查相邻桶左侧的元素
            if (bucketIndex > 0 && buckets[bucketIndex - 1] != Integer.MIN_VALUE) {
                int leftBucketValue = buckets[bucketIndex - 1];
                if (Math.abs((long) leftBucketValue - num) <= valueDiff) {
                    return true;
                }
            }

            // 检查相邻桶右侧的元素
            if (bucketIndex < numBuckets - 1 && buckets[bucketIndex + 1] != Integer.MIN_VALUE) {
                int rightBucketValue = buckets[bucketIndex + 1];
                if (Math.abs((long) rightBucketValue - num) <= valueDiff) {
                    return true;
                }
            }

            // 更新当前桶的值为当前元素
            buckets[bucketIndex] = num;

            // 如果超过了indexDiff，则将前面的桶的值置为Integer.MIN_VALUE
            if (i >= indexDiff) {
                int expiredNum = nums[i - indexDiff];
                int expiredBucketIndex = (expiredNum - min) / bucketWidth;
                if (buckets[expiredBucketIndex] == expiredNum) {
                    buckets[expiredBucketIndex] = Integer.MIN_VALUE;
                }
            }
        }

        // 如果遍历完数组都没有找到符合条件的下标对，则返回false
        return false;
    }
}
