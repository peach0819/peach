package com.peach.algo.LC201_250_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/2
 * 给定整数数组 nums 和整数 k，请返回数组中第 k 个最大的元素。
 * 请注意，你需要找的是数组排序后的第 k 个最大的元素，而不是第 k 个不同的元素。
 * 你必须设计并实现时间复杂度为 O(n) 的算法解决此问题。
 * 示例 1:
 * 输入: [3,2,1,5,6,4], k = 2
 * 输出: 5
 * 示例 2:
 * 输入: [3,2,3,1,2,4,5,5,6], k = 4
 * 输出: 4
 * 提示：
 * 1 <= k <= nums.length <= 105
 * -104 <= nums[i] <= 104
 */
public class LC215_kth_largest_element_in_an_array {

    /**
     * 官方用的是快速排序，但是这里有个桶排序，就是直接用数组下标的方式
     */
    public int findKthLargest(int[] nums, int k) {
        int[] result = new int[20001];
        for (int i = 0; i < nums.length; i++) {
            int num = nums[i];
            result[num + 10000] += 1;
        }
        for (int i = result.length - 1; i >= 0; i--) {
            int i1 = result[i];
            if (i1 == 0) {
                continue;
            }
            if (i1 >= k) {
                return i - 10000;
            }
            k -= i1;
        }
        return 0;
    }
}
