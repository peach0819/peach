package com.peach.algo.LC651_700_toVip;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.PriorityQueue;

/**
 * @author feitao.zt
 * @date 2025/10/24
 * 给定一个 排序好 的数组 arr ，两个整数 k 和 x ，从数组中找到最靠近 x（两数之差最小）的 k 个数。返回的结果必须要是按升序排好的。
 * 整数 a 比整数 b 更接近 x 需要满足：
 * |a - x| < |b - x| 或者
 * |a - x| == |b - x| 且 a < b
 * 示例 1：
 * 输入：arr = [1,2,3,4,5], k = 4, x = 3
 * 输出：[1,2,3,4]
 * 示例 2：
 * 输入：arr = [1,1,2,3,4,5], k = 4, x = -1
 * 输出：[1,1,2,3]
 * 提示：
 * 1 <= k <= arr.length
 * 1 <= arr.length <= 104
 * arr 按 升序 排列
 * -104 <= arr[i], x <= 104
 */
public class LC658_find_k_closest_elements {

    public List<Integer> findClosestElements(int[] arr, int k, int x) {
        //int[3] 0: 原始val  1:两数之差绝对值 2: 原始index
        PriorityQueue<int[]> queue = new PriorityQueue<>((a, b) -> {
            if (a[1] == b[1]) {
                return a[2] - b[2];
            }
            return a[1] - b[1];
        });
        for (int i = 0; i < arr.length; i++) {
            queue.offer(new int[]{ arr[i], Math.abs(arr[i] - x), i });
        }
        List<Integer> result = new ArrayList<>();
        for (int i = 0; i < k; i++) {
            result.add(queue.poll()[0]);
        }
        result.sort(Comparator.comparing(Integer::intValue));
        return result;
    }
}
