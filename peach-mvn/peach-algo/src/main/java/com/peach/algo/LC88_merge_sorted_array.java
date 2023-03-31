package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2023/3/31
 */
public class LC88_merge_sorted_array {

    public void merge(int[] nums1, int m, int[] nums2, int n) {
        if (m == 0 && n == 0) {
            return;
        }
        int i = m - 1;
        int j = n - 1;
        int k = m + n - 1;
        while (i >= 0 || j >= 0) {
            if (i < 0) {
                nums1[k] = nums2[j];
                j--;
            } else if (j < 0) {
                nums1[k] = nums1[i];
                i--;
            } else {
                if (nums1[i] <= nums2[j]) {
                    nums1[k] = nums2[j];
                    j--;
                } else {
                    nums1[k] = nums1[i];
                    i--;
                }
            }
            k--;
        }
    }
}
