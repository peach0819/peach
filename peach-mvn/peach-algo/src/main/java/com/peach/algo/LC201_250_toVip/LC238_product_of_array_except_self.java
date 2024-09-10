package com.peach.algo.LC201_250_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/10
 * 给你一个整数数组 nums，返回 数组 answer ，其中 answer[i] 等于 nums 中除 nums[i] 之外其余各元素的乘积 。
 * 题目数据 保证 数组 nums之中任意元素的全部前缀元素和后缀的乘积都在  32 位 整数范围内。
 * 请 不要使用除法，且在 O(n) 时间复杂度内完成此题。
 * 示例 1:
 * 输入: nums = [1,2,3,4]
 * 输出: [24,12,8,6]
 * 示例 2:
 * 输入: nums = [-1,1,0,-3,3]
 * 输出: [0,0,9,0,0]
 * 提示：
 * 2 <= nums.length <= 105
 * -30 <= nums[i] <= 30
 * 保证 数组 nums之中任意元素的全部前缀元素和后缀的乘积都在  32 位 整数范围内
 * 进阶：你可以在 O(1) 的额外空间复杂度内完成这个题目吗？（ 出于对空间复杂度分析的目的，输出数组 不被视为 额外空间。）
 */
public class LC238_product_of_array_except_self {

    public int[] productExceptSelf(int[] nums) {
        int[] result = new int[nums.length];
        result[0] = 1;
        int i = 1;
        while (i < nums.length) {
            if (nums[i - 1] == 0) {
                break;
            }
            result[i] = result[i - 1] * nums[i - 1];
            i++;
        }

        int end = 1;
        i = nums.length - 2;
        while (i >= 0) {
            if (nums[i + 1] == 0) {
                for (int j = i; j >= 0; j--) {
                    result[j] = 0;
                }
                break;
            }
            end *= nums[i + 1];
            result[i] *= end;
            i--;
        }
        return result;
    }
}
