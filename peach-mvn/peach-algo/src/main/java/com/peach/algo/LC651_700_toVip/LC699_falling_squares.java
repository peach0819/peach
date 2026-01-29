package com.peach.algo.LC651_700_toVip;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2026/1/28
 * 在二维平面上的 x 轴上，放置着一些方块。
 * 给你一个二维整数数组 positions ，其中 positions[i] = [lefti, sideLengthi] 表示：第 i 个方块边长为 sideLengthi ，其左侧边与 x 轴上坐标点 lefti 对齐。
 * 每个方块都从一个比目前所有的落地方块更高的高度掉落而下。方块沿 y 轴负方向下落，直到着陆到 另一个正方形的顶边 或者是 x 轴上 。一个方块仅仅是擦过另一个方块的左侧边或右侧边不算着陆。一旦着陆，它就会固定在原地，无法移动。
 * 在每个方块掉落后，你必须记录目前所有已经落稳的 方块堆叠的最高高度 。
 * 返回一个整数数组 ans ，其中 ans[i] 表示在第 i 块方块掉落后堆叠的最高高度。
 * 示例 1：
 * 输入：positions = [[1,2],[2,3],[6,1]]
 * 输出：[2,5,5]
 * 解释：
 * 第 1 个方块掉落后，最高的堆叠由方块 1 组成，堆叠的最高高度为 2 。
 * 第 2 个方块掉落后，最高的堆叠由方块 1 和 2 组成，堆叠的最高高度为 5 。
 * 第 3 个方块掉落后，最高的堆叠仍然由方块 1 和 2 组成，堆叠的最高高度为 5 。
 * 因此，返回 [2, 5, 5] 作为答案。
 * 示例 2：
 * 输入：positions = [[100,100],[200,100]]
 * 输出：[100,100]
 * 解释：
 * 第 1 个方块掉落后，最高的堆叠由方块 1 组成，堆叠的最高高度为 100 。
 * 第 2 个方块掉落后，最高的堆叠可以由方块 1 组成也可以由方块 2 组成，堆叠的最高高度为 100 。
 * 因此，返回 [100, 100] 作为答案。
 * 注意，方块 2 擦过方块 1 的右侧边，但不会算作在方块 1 上着陆。
 * 提示：
 * 1 <= positions.length <= 1000
 * 1 <= lefti <= 108
 * 1 <= sideLengthi <= 106
 */
public class LC699_falling_squares {

    // {left, right, 高度}
    //[ {1,2,1} ]
    List<int[]> list = new ArrayList<>();
    int maxHeight = 0;

    public List<Integer> fallingSquares(int[][] positions) {
        List<Integer> result = new ArrayList<>();
        for (int[] position : positions) {
            int left = position[0];
            int right = left + position[1];
            List<int[]> effectList = new ArrayList<>();
            int first = -1;
            for (int i = 0; i < list.size(); i++) {
                int[] cur = list.get(i);
                if (cur[1] <= left) {
                    first = i;
                    continue;
                }
                if (cur[0] >= right) {
                    break;
                }
                effectList.add(cur);
            }
            List<int[]> handle = handle(effectList, left, right);
            list.removeAll(effectList);
            list.addAll(first + 1, handle);
            result.add(maxHeight);
        }
        return result;
    }

    private List<int[]> handle(List<int[]> effectList, int left, int right) {
        int curHeight = right - left;
        List<int[]> result = new ArrayList<>();
        if (effectList.isEmpty()) {
            this.maxHeight = Math.max(this.maxHeight, curHeight);
            result.add(new int[]{ left, right, curHeight });
        }
        int curMaxHeight = 0;
        for (int[] ints : effectList) {
            curMaxHeight = Math.max(curMaxHeight, ints[2]);
        }
        result.add(new int[]{ left, right, curMaxHeight + curHeight });
        this.maxHeight = Math.max(this.maxHeight, curMaxHeight + curHeight);
        for (int[] ints : effectList) {
            if (ints[0] >= left && ints[1] <= right) {
                continue;
            }
            if (ints[0] < left) {
                result.add(0, new int[]{ ints[0], left, ints[2] });
            }
            if (ints[1] > right) {
                result.add(new int[]{ right, ints[1], ints[2] });
            }
        }
        return result;
    }
}
