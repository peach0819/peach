package com.peach.algo.LC201_250_toVip;

/**
 * @author feitao.zt
 * @date 2023/7/11
 * 给你一个整数数组 nums，有一个大小为 k 的滑动窗口从数组的最左侧移动到数组的最右侧。你只可以看到在滑动窗口内的 k 个数字。滑动窗口每次只向右移动一位。
 * 返回 滑动窗口中的最大值 。
 *  
 * 示例 1：
 * 输入：nums = [1,3,-1,-3,5,3,6,7], k = 3
 * 输出：[3,3,5,5,6,7]
 * 解释：
 * 滑动窗口的位置                最大值
 * ---------------               -----
 * [1  3  -1] -3  5  3  6  7       3
 * 1 [3  -1  -3] 5  3  6  7       3
 * 1  3 [-1  -3  5] 3  6  7       5
 * 1  3  -1 [-3  5  3] 6  7       5
 * 1  3  -1  -3 [5  3  6] 7       6
 * 1  3  -1  -3  5 [3  6  7]      7
 * 示例 2：
 * 输入：nums = [1], k = 1
 * 输出：[1]
 *  
 * 提示：
 * 1 <= nums.length <= 105
 * -104 <= nums[i] <= 104
 * 1 <= k <= nums.length
 * 来源：力扣（LeetCode）
 * 链接：https://leetcode.cn/problems/sliding-window-maximum
 * 著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
 */
public class LC239_sliding_window_maximum {

    public int[] maxSlidingWindow(int[] nums, int k) {
        int[] result = new int[nums.length - k + 1];
        int lastMaxIndex = -1;
        int lastMax = nums[0];
        for (int i = 0; i < nums.length - k + 1; i++) {
            if (i > lastMaxIndex) {
                int[] curMax = max(nums, i, k);
                lastMaxIndex = curMax[0];
                lastMax = curMax[1];
            } else if (nums[i + k - 1] > lastMax) {
                lastMaxIndex = i + k - 1;
                lastMax = nums[i + k - 1];
            }
            result[i] = lastMax;
        }
        return result;
    }

    public int[] max(int[] nums, int beginIndex, int k) {
        int maxIndex = beginIndex;
        int max = nums[beginIndex];
        for (int i = 1; i < k; i++) {
            int curNum = nums[beginIndex + i];
            if (curNum >= max) {
                maxIndex = beginIndex + i;
                max = curNum;
            }
        }
        return new int[]{ maxIndex, max };
    }

}
