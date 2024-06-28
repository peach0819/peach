package com.peach.algo;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/6/28
 * 给你一个 非空 整数数组 nums ，除了某个元素只出现一次以外，其余每个元素均出现两次。找出那个只出现了一次的元素。
 * 你必须设计并实现线性时间复杂度的算法来解决此问题，且该算法只使用常量额外空间。
 * 示例 1 ：
 * 输入：nums = [2,2,1]
 * 输出：1
 * 示例 2 ：
 * 输入：nums = [4,1,2,1,2]
 * 输出：4
 * 示例 3 ：
 * 输入：nums = [1]
 * 输出：1
 * 提示：
 * 1 <= nums.length <= 3 * 104
 * -3 * 104 <= nums[i] <= 3 * 104
 * 除了某个元素只出现一次以外，其余每个元素均出现两次。
 */
public class LC136_single_number {

    public int singleNumber1(int[] nums) {
        Set<Integer> set = new HashSet<>();
        for (int num : nums) {
            if (set.contains(num)) {
                set.remove(num);
            } else {
                set.add(num);
            }
        }
        return set.stream().findFirst().get();
    }

    public int singleNumber2(int[] nums) {
        Arrays.sort(nums);
        int index = 0;
        while (index < nums.length) {
            if (index + 1 == nums.length) {
                return nums[index];
            }
            if (nums[index] != nums[index + 1]) {
                return nums[index];
            }
            index += 2;
        }
        return 0;
    }

    /**
     * 一样的数异或结果为0
     */
    public int singleNumber(int[] nums) {
        int x = 0;
        for (int num : nums) {
            x = x ^ num;
        }
        return x;
    }
}
