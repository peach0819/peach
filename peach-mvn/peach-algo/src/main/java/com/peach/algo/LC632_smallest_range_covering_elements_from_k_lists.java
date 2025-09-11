package com.peach.algo;

import java.util.Comparator;
import java.util.List;
import java.util.PriorityQueue;

/**
 * @author feitao.zt
 * @date 2025/9/10
 * 你有 k 个 非递减排列 的整数列表。找到一个 最小 区间，使得 k 个列表中的每个列表至少有一个数包含在其中。
 * 我们定义如果 b-a < d-c 或者在 b-a == d-c 时 a < c，则区间 [a,b] 比 [c,d] 小。
 * 示例 1：
 * 输入：nums = [[4,10,15,24,26], [0,9,12,20], [5,18,22,30]]
 * 输出：[20,24]
 * 解释：
 * 列表 1：[4, 10, 15, 24, 26]，24 在区间 [20,24] 中。
 * 列表 2：[0, 9, 12, 20]，20 在区间 [20,24] 中。
 * 列表 3：[5, 18, 22, 30]，22 在区间 [20,24] 中。
 * 示例 2：
 * 输入：nums = [[1,2,3],[1,2,3],[1,2,3]]
 * 输出：[1,1]
 * 提示：
 * nums.length == k
 * 1 <= k <= 3500
 * 1 <= nums[i].length <= 50
 * -105 <= nums[i][j] <= 105
 * nums[i] 按非递减顺序排列
 */
public class LC632_smallest_range_covering_elements_from_k_lists {

    /**
     * 我是傻逼
     */
    public int[] smallestRange(List<List<Integer>> nums) {
        //因为每次都要找最小元素，所以维护一个最小堆比较合适
        PriorityQueue<NumGroup> numgrp = new PriorityQueue<>(Comparator.comparingInt(n -> n.num));

        int end = -100001;
        //记录每个数组当前的指针位置，一开始都指向第0个元素，即每个区间的最小元素
        int[] index = new int[nums.size()];

        //起始区间
        for (int i = 0; i < nums.size(); i++) {
            if (nums.get(i).get(0) > end) end = nums.get(i).get(0);
            NumGroup num = new NumGroup(nums.get(i).get(0), i);
            numgrp.offer(num);
        }

        int max = end;
        int start = numgrp.peek().num;
        int min;
        int len = end - start + 1;

        while (true) {
            //grp为当前最小元素的原数组号
            int grp = numgrp.poll().grp;
            //如果当前最小元素已经是原数组最大元素了，则退出
            if (index[grp] + 1 == nums.get(grp).size()) break;

            //索引++，并将当前最小元素的原数组中的下一个元素压入优先级队列
            index[grp]++;
            NumGroup n = new NumGroup(nums.get(grp).get(index[grp]), grp);
            numgrp.offer(n);
            //当前最大值
            if (n.num > max) {
                max = n.num;
            }
            min = numgrp.peek().num;
            //长度变小
            if (max - min + 1 < len) {
                start = min;
                end = max;
                len = max - min + 1;
            }
        }

        return new int[]{ start, end };
    }

    class NumGroup {

        public NumGroup(int num, int grp) {
            this.num = num;
            this.grp = grp;
        }

        int num; //数值
        int grp; //组号
    }
}
