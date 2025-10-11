package com.peach.algo.LC601_650_toVip;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2025/9/2
 * 给定一个包含非负整数的数组 nums ，返回其中可以组成三角形三条边的三元组个数。
 * 示例 1:
 * 输入: nums = [2,2,3,4]
 * 输出: 3
 * 解释:有效的组合是:
 * 2,3,4 (使用第一个 2)
 * 2,3,4 (使用第二个 2)
 * 2,2,3
 * 示例 2:
 * 输入: nums = [4,2,3,4]
 * 输出: 4
 * 提示:
 * 1 <= nums.length <= 1000
 * 0 <= nums[i] <= 1000
 */
public class LC611_valid_triangle_number {

    // 3 3 4 5 6
    public int triangleNumber(int[] nums) {
        Arrays.sort(nums);
        int result = 0;
        int add;
        for (int i = 0; i < nums.length - 2; i++) {
            int a = nums[i];
            if (a == 0) {
                continue;
            }
            int cindex = Integer.MIN_VALUE;
            for (int j = i + 1; j < nums.length - 1; j++) {
                int b = nums[j];
                add = a + b;
                if (cindex != Integer.MIN_VALUE) {
                    result += cindex - j;
                } else {
                    cindex = j;
                }
                for (int k = cindex + 1; k < nums.length; k++) {
                    int c = nums[k];
                    if (c < add) {
                        result++;
                        cindex = k;
                    } else {
                        break;
                    }
                }
            }
        }
        return result;
    }
}
