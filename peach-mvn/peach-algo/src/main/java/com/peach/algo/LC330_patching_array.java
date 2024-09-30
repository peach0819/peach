package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/9/30
 * 给定一个已排序的正整数数组 nums ，和一个正整数 n 。从 [1, n] 区间内选取任意个数字补充到 nums 中，使得 [1, n] 区间内的任何数字都可以用 nums 中某几个数字的和来表示。
 * 请返回 满足上述要求的最少需要补充的数字个数 。
 * 示例 1:
 * 输入: nums = [1,3], n = 6
 * 输出: 1
 * 解释:
 * 根据 nums 里现有的组合 [1], [3], [1,3]，可以得出 1, 3, 4。
 * 现在如果我们将 2 添加到 nums 中， 组合变为: [1], [2], [3], [1,3], [2,3], [1,2,3]。
 * 其和可以表示数字 1, 2, 3, 4, 5, 6，能够覆盖 [1, 6] 区间里所有的数。
 * 所以我们最少需要添加一个数字。
 * 示例 2:
 * 输入: nums = [1,5,10], n = 20
 * 输出: 2
 * 解释: 我们需要添加 [2,4]。
 * 示例 3:
 * 输入: nums = [1,2,2], n = 5
 * 输出: 0
 * 提示：
 * 1 <= nums.length <= 1000
 * 1 <= nums[i] <= 104
 * nums 按 升序排列
 * 1 <= n <= 231 - 1
 */
public class LC330_patching_array {

    /**
     * 我是傻逼
     */
    public int minPatches(int[] nums, int n) {
        int patches = 0;  // 初始化要补的次数为0次
        long x = 1;  // 初始化x，此时区间为[0,0]
        int length = nums.length;
        int index = 0;   // 从第0个位置开始
        while (x <= n) {  // 退出条件为x大于n，因为x总是代表[1, x-1]被覆盖到
            if (index < length && nums[index] <= x) {
                // 从x=1开始依次判断，每次如果x在数组中，则更新x为x+nums[index]，因为根据贪心思想，我们总保证区间小于x的所有值会被覆盖掉，因此x+1，x+2，... x+nums[index]-1都会被覆盖到，更新x += nums[index]。
                x += nums[index];
                index++;
            } else {
                // x不在数组中，则将x加入，覆盖范围变为2 * x - 1，更新 x *= 2
                x *= 2;
                patches++;
            }
        }
        return patches;
    }
}
