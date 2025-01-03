package com.peach.algo.LC401_450_toVip;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2023/9/8
 * 一只青蛙想要过河。 假定河流被等分为若干个单元格，并且在每一个单元格内都有可能放有一块石子（也有可能没有）。 青蛙可以跳上石子，但是不可以跳入水中。
 * 给你石子的位置列表 stones（用单元格序号 升序 表示）， 请判定青蛙能否成功过河（即能否在最后一步跳至最后一块石子上）。开始时， 青蛙默认已站在第一块石子上，并可以假定它第一步只能跳跃 1 个单位（即只能从单元格 1 跳至单元格 2 ）。
 * 如果青蛙上一步跳跃了 k 个单位，那么它接下来的跳跃距离只能选择为 k - 1、k 或 k + 1 个单位。 另请注意，青蛙只能向前方（终点的方向）跳跃。
 * 示例 1：
 * 输入：stones = [0,1,3,5,6,8,12,17]
 * 输出：true
 * 解释：青蛙可以成功过河，按照如下方案跳跃：跳 1 个单位到第 2 块石子, 然后跳 2 个单位到第 3 块石子, 接着 跳 2 个单位到第 4 块石子, 然后跳 3 个单位到第 6 块石子, 跳 4 个单位到第 7 块石子, 最后，跳 5 个单位到第 8 个石子（即最后一块石子）。
 * 示例 2：
 * 输入：stones = [0,1,2,3,4,8,9,11]
 * 输出：false
 * 解释：这是因为第 5 和第 6 个石子之间的间距太大，没有可选的方案供青蛙跳跃过去。
 * 提示：
 * 2 <= stones.length <= 2000
 * 0 <= stones[i] <= 231 - 1
 * stones[0] == 0
 * stones 按严格升序排列
 */
public class LC403_frog_jump {

    Map<Integer, Integer> indexMap = new HashMap<>();

    Map<String, Boolean> map = new HashMap<>();

    public boolean canCross(int[] stones) {
        if (stones[1] != 1) {
            return false;
        }
        for (int i = 0; i < stones.length; i++) {
            indexMap.put(stones[i], i);
        }
        return cross(stones, 1, 1);
    }

    private boolean cross(int[] stones, int curIndex, int k) {
        String key = curIndex + "_" + k;
        if (map.containsKey(key)) {
            return map.get(key);
        }
        boolean result = false;
        if (curIndex == (stones.length - 1)) {
            result = true;
        } else {
            int value = stones[curIndex];
            int[] nextValue = new int[]{ value + k - 1, value + k, value + k + 1 };
            for (int i = 0; i < nextValue.length; i++) {
                int cur = nextValue[i];
                int curk = cur - value;
                if (curk == 0) {
                    continue;
                }
                if (!indexMap.containsKey(cur)) {
                    continue;
                }
                boolean cross = cross(stones, indexMap.get(cur), curk);
                if (cross) {
                    result = true;
                    break;
                }
            }
        }
        map.put(key, result);
        return result;
    }

    public static void main(String[] args) {
        boolean b = new LC403_frog_jump().canCross(new int[]{ 0, 1, 3, 5, 6, 8, 12, 17 });
        int i = 1;
    }
}
