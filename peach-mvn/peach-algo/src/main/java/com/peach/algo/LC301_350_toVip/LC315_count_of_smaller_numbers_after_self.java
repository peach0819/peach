package com.peach.algo.LC301_350_toVip;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/9/23
 * 给你一个整数数组 nums ，按要求返回一个新数组 counts 。数组 counts 有该性质： counts[i] 的值是  nums[i] 右侧小于 nums[i] 的元素的数量。
 * 示例 1：
 * 输入：nums = [5,2,6,1]
 * 输出：[2,1,1,0]
 * 解释：
 * 5 的右侧有 2 个更小的元素 (2 和 1)
 * 2 的右侧仅有 1 个更小的元素 (1)
 * 6 的右侧有 1 个更小的元素 (1)
 * 1 的右侧有 0 个更小的元素
 * 示例 2：
 * 输入：nums = [-1]
 * 输出：[0]
 * 示例 3：
 * 输入：nums = [-1,-1]
 * 输出：[0,0]
 * 提示：
 * 1 <= nums.length <= 105
 * -104 <= nums[i] <= 104
 */
public class LC315_count_of_smaller_numbers_after_self {

    public static void main(String[] args) {
        List<Integer> list = new LC315_count_of_smaller_numbers_after_self().countSmaller(
                new int[]{ 26, 78, 27, 100, 33, 67, 90, 23, 66, 5, 38, 7, 35, 23, 52, 22, 83, 51, 98, 69, 81, 32, 78,
                        28, 94, 13, 2, 97, 3, 76, 99, 51, 9, 21, 84, 66, 65, 36, 100, 41 });
        int i = 1;
    }

    List<Integer> temp = new ArrayList<>();

    /**
     * 我是傻逼，官方用的树状数组
     */
    public List<Integer> countSmaller(int[] nums) {
        temp.add(nums[nums.length - 1]);
        Integer[] result = new Integer[nums.length];
        int smaller = 0;
        for (int i = nums.length - 2; i >= 0; i--) {
            int cur = nums[i];
            if (cur == nums[i + 1]) {
                result[i] = result[i + 1];
                temp.add(smaller, cur);
                continue;
            }

            smaller = find(cur);
            result[i] = smaller;
        }
        return Arrays.asList(result);
    }

    private int find(int num) {
        if (num <= temp.get(0)) {
            temp.add(0, num);
            return 0;
        }
        if (num > temp.get(temp.size() - 1)) {
            temp.add(num);
            return temp.size() - 1;
        }
        int i = find2(num, 0, temp.size() - 1);
        temp.add(i, num);
        return i;
    }

    private int find2(int num, int begin, int end) {
        if (begin + 1 == end) {
            return begin + 1;
        }
        int mid = (begin + end) / 2;
        int midVal = temp.get(mid);
        if (midVal < num) {
            return find2(num, mid, end);
        } else {
            return find2(num, begin, mid);
        }
    }
}
