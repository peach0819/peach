package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/9/24
 * 给你一个整数数组 nums 以及两个整数 lower 和 upper 。求数组中，值位于范围 [lower, upper] （包含 lower 和 upper）之内的 区间和的个数 。
 * 区间和 S(i, j) 表示在 nums 中，位置从 i 到 j 的元素之和，包含 i 和 j (i ≤ j)。
 * 示例 1：
 * 输入：nums = [-2,5,-1], lower = -2, upper = 2
 * 输出：3
 * 解释：存在三个区间：[0,0]、[2,2] 和 [0,2] ，对应的区间和分别是：-2 、-1 、2 。
 * 示例 2：
 * 输入：nums = [0], lower = 0, upper = 0
 * 输出：1
 * 提示：
 * 1 <= nums.length <= 105
 * -231 <= nums[i] <= 231 - 1
 * -105 <= lower <= upper <= 105
 * 题目数据保证答案是一个 32 位 的整数
 */
public class LC327_count_of_range_sum {

    public static void main(String[] args) {
        int i = new LC327_count_of_range_sum().countRangeSum(new int[]{ -2, 5, -1 }, -2, 2);
        i = 1;
    }

    int[] nums;
    long[] sums;

    public int countRangeSum1(int[] nums, int lower, int upper) {
        this.nums = nums;
        this.sums = new long[nums.length];
        long sum = 0;
        for (int i = 0; i < nums.length; i++) {
            sum += nums[i];
            sums[i] = sum;
        }
        int result = 0;
        for (int i = 0; i < nums.length; i++) {
            for (int j = i; j < nums.length; j++) {
                long sum1 = getSum(i, j);
                if (isRange(lower, upper, sum1)) {
                    result++;
                }
            }
        }
        return result;
    }

    private boolean isRange(int lower, int upper, long num) {
        return num >= lower && num <= upper;
    }

    private long getSum(int begin, int end) {
        if (begin == end) {
            return nums[begin];
        }
        if (begin == 0) {
            return sums[end];
        }
        return sums[end] - sums[begin - 1];
    }

    /**
     * 我是傻逼
     * 官方用的归并排序， 核心是和数组，排序后结果不变
     * 线段树往后再看
     */
    public int countRangeSum(int[] nums, int lower, int upper) {
        long s = 0;
        long[] sum = new long[nums.length + 1];
        for (int i = 0; i < nums.length; ++i) {
            s += nums[i];
            sum[i + 1] = s;
        }
        return countRangeSumRecursive(sum, lower, upper, 0, sum.length - 1);
    }

    public int countRangeSumRecursive(long[] sum, int lower, int upper, int left, int right) {
        if (left == right) {
            return 0;
        } else {
            int mid = (left + right) / 2;
            int n1 = countRangeSumRecursive(sum, lower, upper, left, mid);
            int n2 = countRangeSumRecursive(sum, lower, upper, mid + 1, right);
            int ret = n1 + n2;

            // 首先统计下标对的数量
            int i = left;
            int l = mid + 1;
            int r = mid + 1;
            while (i <= mid) {
                while (l <= right && sum[l] - sum[i] < lower) {
                    l++;
                }
                while (r <= right && sum[r] - sum[i] <= upper) {
                    r++;
                }
                ret += r - l;
                i++;
            }

            // 随后合并两个排序数组
            long[] sorted = new long[right - left + 1];
            int p1 = left, p2 = mid + 1;
            int p = 0;
            while (p1 <= mid || p2 <= right) {
                if (p1 > mid) {
                    sorted[p++] = sum[p2++];
                } else if (p2 > right) {
                    sorted[p++] = sum[p1++];
                } else {
                    if (sum[p1] < sum[p2]) {
                        sorted[p++] = sum[p1++];
                    } else {
                        sorted[p++] = sum[p2++];
                    }
                }
            }
            for (int j = 0; j < sorted.length; j++) {
                sum[left + j] = sorted[j];
            }
            return ret;
        }
    }

}
