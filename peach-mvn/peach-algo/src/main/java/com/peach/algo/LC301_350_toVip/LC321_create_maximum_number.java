package com.peach.algo.LC301_350_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/24
 * 给你两个整数数组 nums1 和 nums2，它们的长度分别为 m 和 n。数组 nums1 和 nums2 分别代表两个数各位上的数字。同时你也会得到一个整数 k。
 * 请你利用这两个数组中的数字中创建一个长度为 k <= m + n 的最大数，在这个必须保留来自同一数组的数字的相对顺序。
 * 返回代表答案的长度为 k 的数组。
 * 示例 1：
 * 输入：nums1 = [3,4,6,5], nums2 = [9,1,2,5,8,3], k = 5
 * 输出：[9,8,6,5,3]
 * 示例 2：
 * 输入：nums1 = [6,7], nums2 = [6,0,4], k = 5
 * 输出：[6,7,6,0,4]
 * 示例 3：
 * 输入：nums1 = [3,9], nums2 = [8,9], k = 3
 * 输出：[9,8,9]
 * 提示：
 * m == nums1.length
 * n == nums2.length
 * 1 <= m, n <= 500
 * 0 <= nums1[i], nums2[i] <= 9
 * 1 <= k <= m + n
 */
public class LC321_create_maximum_number {

    /**
     * 我是傻逼
     */
    public int[] maxNumber(int[] nums1, int[] nums2, int k) {
        int[] result = new int[k];
        int len1 = nums1.length, len2 = nums2.length;
        int[] maxSeq1 = new int[Math.max(len1, k)];
        int[] maxSeq2 = new int[Math.max(len2, k)];
        for (int i = Math.max(0, k - len2), end = Math.min(k, len1); i <= end; i++) {
            getMaxSequence(nums1, maxSeq1, i);
            getMaxSequence(nums2, maxSeq2, k - i);
            mergeMaxSequence(maxSeq1, i, maxSeq2, k - i, result);
        }
        return result;
    }

    void getMaxSequence(int[] nums, int[] seq, int len) {
        int n = nums.length;
        for (int i = 0, j = 0; i < n; i++) {
            int num = nums[i];
            for (; j > 0 && seq[j - 1] < num && len - j < n - i; ) {
                j--;
            }
            if (j < len) {
                seq[j++] = num;
            }
        }
    }

    void mergeMaxSequence(int[] seq1, int len1, int[] seq2, int len2, int[] seq) {
        int len = len1 + len2;
        int start1 = 0, start2 = 0;
        boolean isBigger = false;
        for (int i = 0; i < len; i++) {
            int maxNum;
            if (compare(seq1, start1, len1, seq2, start2, len2) > 0) {
                maxNum = seq1[start1++];
            } else {
                maxNum = seq2[start2++];
            }
            if (!isBigger) {
                int num = seq[i];
                if (maxNum > num) {
                    isBigger = true;
                } else if (maxNum < num) {
                    return;
                }
            }
            seq[i] = maxNum;
        }
    }

    int compare(int[] seq1, int start1, int len1, int[] seq2, int start2, int len2) {
        for (; ; ) {
            if (start1 == len1) {
                return start2 == len2 ? 0 : -1;
            } else if (start2 == len2) {
                return 1;
            } else {
                int cmp = seq1[start1++] - seq2[start2++];
                if (cmp != 0) {
                    return cmp;
                }
            }
        }
    }
}
