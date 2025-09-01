package com.peach.algo.LC551_600_toVip;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2025/6/26
 * 索引从0开始长度为N的数组A，包含0到N - 1的所有整数。找到最大的集合S并返回其大小，其中 S[i] = {A[i], A[A[i]], A[A[A[i]]], ... }且遵守以下的规则。
 * 假设选择索引为i的元素A[i]为S的第一个元素，S的下一个元素应该是A[A[i]]，之后是A[A[A[i]]]... 以此类推，不断添加直到S出现重复的元素。
 * 示例 1:
 * 输入: A = [5,4,0,3,1,6,2]
 * 输出: 4
 * 解释:
 * A[0] = 5, A[1] = 4, A[2] = 0, A[3] = 3, A[4] = 1, A[5] = 6, A[6] = 2.
 * 其中一种最长的 S[K]:
 * S[0] = {A[0], A[5], A[6], A[2]} = {5, 6, 2, 0}
 * 提示：
 * 1 <= nums.length <= 105
 * 0 <= nums[i] < nums.length
 * A中不含有重复的元素。
 */
public class LC565_array_nesting {

    public static void main(String[] args) {
        int i = new LC565_array_nesting().arrayNesting(new int[]{ 5, 4, 0, 3, 1, 6, 2 });
    }

    boolean[] visited;
    int[] result;
    int[] nums;

    public int arrayNesting(int[] nums) {
        this.visited = new boolean[nums.length];
        this.result = new int[nums.length];
        this.nums = nums;
        for (int i = 0; i < nums.length; i++) {
            if (visited[i]) {
                continue;
            }
            handle(i);
        }
        int max = 0;
        for (int cur : result) {
            max = Math.max(max, cur);
        }
        return max;
    }

    private void handle(int i) {
        List<Integer> list = new ArrayList<>();
        while (true) {
            if (visited[i]) {
                if (result[i] == 0) {
                    //表示在当前循环才重复的
                    int exist = list.indexOf(i);
                    int circle = list.size() - exist;
                    for (int j = 0; j < list.size(); j++) {
                        if (j < exist) {
                            result[list.get(j)] = circle + exist - j;
                        } else {
                            result[list.get(j)] = circle;
                        }
                    }
                } else {
                    //表示历史循环已经有数据了
                    int circle = result[i];
                    for (int j = 0; j < list.size(); j++) {
                        result[list.get(j)] = circle + list.size() - j;
                    }
                }
                return;
            }
            list.add(i);
            visited[i] = true;
            i = nums[i];
        }
    }
}
