package com.peach.algo;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2026/1/29
 * 设计一个找到数据流中第 k 大元素的类（class）。注意是排序后的第 k 大元素，不是第 k 个不同的元素。
 * 请实现 KthLargest 类：
 * KthLargest(int k, int[] nums) 使用整数 k 和整数流 nums 初始化对象。
 * int add(int val) 将 val 插入数据流 nums 后，返回当前数据流中第 k 大的元素。
 * 示例 1：
 * 输入：
 * ["KthLargest", "add", "add", "add", "add", "add"]
 * [[3, [4, 5, 8, 2]], [3], [5], [10], [9], [4]]
 * 输出：[null, 4, 5, 5, 8, 8]
 * 解释：
 * KthLargest kthLargest = new KthLargest(3, [4, 5, 8, 2]);
 * kthLargest.add(3); // 返回 4
 * kthLargest.add(5); // 返回 5
 * kthLargest.add(10); // 返回 5
 * kthLargest.add(9); // 返回 8
 * kthLargest.add(4); // 返回 8
 * 示例 2：
 * 输入：
 * ["KthLargest", "add", "add", "add", "add"]
 * [[4, [7, 7, 7, 7, 8, 3]], [2], [10], [9], [9]]
 * 输出：[null, 7, 7, 7, 8]
 * 解释：
 * KthLargest kthLargest = new KthLargest(4, [7, 7, 7, 7, 8, 3]);
 * kthLargest.add(2); // 返回 7
 * kthLargest.add(10); // 返回 7
 * kthLargest.add(9); // 返回 7
 * kthLargest.add(9); // 返回 8
 * 提示：
 * 0 <= nums.length <= 104
 * 1 <= k <= nums.length + 1
 * -104 <= nums[i] <= 104
 * -104 <= val <= 104
 * 最多调用 add 方法 104 次
 */
public class LC703_kth_largest_element_in_a_stream {

    public static void main(String[] args) {
        LC703_kth_largest_element_in_a_stream.KthLargest kthLargest = new LC703_kth_largest_element_in_a_stream().new KthLargest(3, new int[]{4, 5, 8, 2});
        System.out.println(kthLargest.add(10));
        System.out.println(kthLargest.add(9));
        System.out.println(kthLargest.add(4));
    }

    /**
     * Your KthLargest object will be instantiated and called as such:
     * KthLargest obj = new KthLargest(k, nums);
     * int param_1 = obj.add(val);
     */
    class KthLargest {

        int[] nums;

        public KthLargest(int k, int[] nums) {
            Arrays.sort(nums);
            if (nums.length >= k) {
                this.nums = Arrays.copyOfRange(nums, nums.length - k, nums.length);
            } else {
                this.nums = new int[k];
                Arrays.fill(this.nums, -10001);
                System.arraycopy(nums, 0, this.nums, this.nums.length - nums.length, nums.length);
            }
        }

        public int add(int val) {
            if (val < nums[0]) {
                return nums[0];
            }
            for (int i = nums.length - 1; i >= 0; i--) {
                if (nums[i] < val) {
                    for (int j = 0; j < i; j++) {
                        nums[j] = nums[j + 1];
                    }
                    nums[i] = val;
                    break;
                }
            }
            return nums[0];
        }
    }
}
