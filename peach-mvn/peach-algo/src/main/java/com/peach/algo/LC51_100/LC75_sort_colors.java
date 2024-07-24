package com.peach.algo.LC51_100;

/**
 * @author feitao.zt
 * @date 2024/7/17
 * 给定一个包含红色、白色和蓝色、共 n 个元素的数组 nums ，原地对它们进行排序，使得相同颜色的元素相邻，并按照红色、白色、蓝色顺序排列。
 * 我们使用整数 0、 1 和 2 分别表示红色、白色和蓝色。
 * 必须在不使用库内置的 sort 函数的情况下解决这个问题。
 * 示例 1：
 * 输入：nums = [2,0,2,1,1,0]
 * 输出：[0,0,1,1,2,2]
 * 示例 2：
 * 输入：nums = [2,0,1]
 * 输出：[0,1,2]
 * 提示：
 * n == nums.length
 * 1 <= n <= 300
 * nums[i] 为 0、1 或 2
 * 进阶：
 * 你能想出一个仅使用常数空间的一趟扫描算法吗？
 */
public class LC75_sort_colors {

    public static void main(String[] args) {
        new LC75_sort_colors().sortColors(new int[]{ 1, 0, 0 });
        int i = 1;
    }

    int[] nums;

    public void sortColors(int[] nums) {
        this.nums = nums;
        int begin = 0;
        int end = nums.length - 1;

        for (int i = 0; i < nums.length; i++) {
            if (i > end) {
                return;
            }
            while (true) {
                int num = nums[i];
                if (num == 0) {
                    if (begin == i) {
                        begin++;
                        break;
                    } else {
                        swap(begin, i);
                        begin++;
                    }
                } else if (num == 1) {
                    break;
                } else if (num == 2) {
                    if (i == end) {
                        return;
                    } else {
                        swap(i, end);
                        end--;
                    }
                }
            }
        }
    }

    private void swap(int i, int j) {
        int temp = nums[i];
        nums[i] = nums[j];
        nums[j] = temp;
    }

}
