package com.peach.algo.LC151_200_toVip;

/**
 * @author feitao.zt
 * @date 2023/3/30
 * 给定一个整数数组 nums，将数组中的元素向右轮转 k 个位置，其中 k 是非负数。
 *  
 * 示例 1:
 * 输入: nums = [1,2,3,4,5,6,7], k = 3
 * 输出: [5,6,7,1,2,3,4]
 * 解释:
 * 向右轮转 1 步: [7,1,2,3,4,5,6]
 * 向右轮转 2 步: [6,7,1,2,3,4,5]
 * 向右轮转 3 步: [5,6,7,1,2,3,4]
 * 示例 2:
 * 输入：nums = [-1,-100,3,99], k = 2
 * 输出：[3,99,-1,-100]
 * 解释:
 * 向右轮转 1 步: [99,-1,-100,3]
 * 向右轮转 2 步: [3,99,-1,-100]
 *  
 * 提示：
 * 1 <= nums.length <= 105
 * -231 <= nums[i] <= 231 - 1
 * 0 <= k <= 105
 *  
 * 进阶：
 * 尽可能想出更多的解决方案，至少有 三种 不同的方法可以解决这个问题。
 * 你可以使用空间复杂度为 O(1) 的 原地 算法解决这个问题吗？
 * 来源：力扣（LeetCode）
 * 链接：https://leetcode.cn/problems/rotate-array
 * 著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
 */
public class LC189_rotate_array {

    //耗时 64.51%
    //内存 46.55%
    // o(k)
    public void rotate1(int[] nums, int k) {
        int length = nums.length;
        k = k % length;
        int[] rotate = new int[k];
        int index = 0;
        for (int i = length - k; i < length; i++) {
            rotate[index] = nums[i];
            index++;
        }

        for (int i = length - 1; i >= 0; i--) {
            if (i >= k) {
                nums[i] = nums[i - k];
            } else {
                nums[i] = rotate[i];
            }
        }
    }

    //操作	结果
    //原始数组	 1 2 3 4 5 6 7
    //翻转所有元素	 7 6 5 4 3 2 1
    //翻转 [0, k\bmod n - 1][0,kmodn−1] 区间的元素	5 6 7 4 3 2 1
    public void rotate(int[] nums, int k) {
        int length = nums.length;
        k = k % length;

        reverse(nums, 0, length - 1);
        reverse(nums, 0, k - 1);
        reverse(nums, k, length - 1);
    }

    private void reverse(int[] nums, int begin, int end) {
        int temp;
        while (begin < end) {
            temp = nums[end];
            nums[end] = nums[begin];
            nums[begin] = temp;
            begin++;
            end--;
        }
    }

}
