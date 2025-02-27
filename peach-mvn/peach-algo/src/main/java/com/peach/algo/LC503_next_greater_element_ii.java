package com.peach.algo;

import java.util.Arrays;
import java.util.Stack;

/**
 * @author feitao.zt
 * @date 2025/2/21
 * 给定一个循环数组 nums （ nums[nums.length - 1] 的下一个元素是 nums[0] ），返回 nums 中每个元素的 下一个更大元素 。
 * 数字 x 的 下一个更大的元素 是按数组遍历顺序，这个数字之后的第一个比它更大的数，这意味着你应该循环地搜索它的下一个更大的数。如果不存在，则输出 -1 。
 * 示例 1:
 * 输入: nums = [1,2,1]
 * 输出: [2,-1,2]
 * 解释: 第一个 1 的下一个更大的数是 2；
 * 数字 2 找不到下一个更大的数；
 * 第二个 1 的下一个最大的数需要循环搜索，结果也是 2。
 * 示例 2:
 * 输入: nums = [1,2,3,4,3]
 * 输出: [2,3,4,-1,4]
 * 提示:
 * 1 <= nums.length <= 104
 * -109 <= nums[i] <= 109
 */
public class LC503_next_greater_element_ii {

    public static void main(String[] args) {
        int[] ints = new LC503_next_greater_element_ii().nextGreaterElements(new int[]{ 1, 2, 1 });
        int i = 1;
    }

    public int[] nextGreaterElements(int[] nums) {
        int[] result = new int[nums.length];
        Arrays.fill(result, Integer.MIN_VALUE);
        Stack<Integer> stack = new Stack<>();
        for (int i = 0; i < nums.length * 2; i++) {
            int curi = i % nums.length;
            while (!stack.isEmpty() && nums[curi] > nums[stack.peek()]) {
                result[stack.pop()] = nums[curi];
            }
            if (result[curi] == Integer.MIN_VALUE) {
                stack.push(curi);
            }
            if (i >= nums.length && stack.isEmpty()) {
                break;
            }
        }
        for (int i = 0; i < result.length; i++) {
            if (result[i] == Integer.MIN_VALUE) {
                result[i] = -1;
            }
        }
        return result;
    }
}
