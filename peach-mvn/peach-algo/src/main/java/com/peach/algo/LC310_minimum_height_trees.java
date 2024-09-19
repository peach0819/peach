package com.peach.algo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/9/18
 * 树是一个无向图，其中任何两个顶点只通过一条路径连接。 换句话说，任何一个没有简单环路的连通图都是一棵树。
 * 给你一棵包含 n 个节点的树，标记为 0 到 n - 1 。给定数字 n 和一个有 n - 1 条无向边的 edges 列表（每一个边都是一对标签），其中 edges[i] = [ai, bi] 表示树中节点 ai 和 bi 之间存在一条无向边。
 * 可选择树中任何一个节点作为根。当选择节点 x 作为根节点时，设结果树的高度为 h 。在所有可能的树中，具有最小高度的树（即，min(h)）被称为 最小高度树 。
 * 请你找到所有的 最小高度树 并按 任意顺序 返回它们的根节点标签列表。
 * 树的 高度 是指根节点和叶子节点之间最长向下路径上边的数量。
 * 示例 1：
 * 输入：n = 4, edges = [[1,0],[1,2],[1,3]]
 * 输出：[1]
 * 解释：如图所示，当根是标签为 1 的节点时，树的高度是 1 ，这是唯一的最小高度树。
 * 示例 2：
 * 输入：n = 6, edges = [[3,0],[3,1],[3,2],[3,4],[5,4]]
 * 输出：[3,4]
 * 提示：
 * 1 <= n <= 2 * 104
 * edges.length == n - 1
 * 0 <= ai, bi < n
 * ai != bi
 * 所有 (ai, bi) 互不相同
 * 给定的输入 保证 是一棵树，并且 不会有重复的边
 */
public class LC310_minimum_height_trees {

    public static void main(String[] args) {
        List<Integer> minHeightTrees = new LC310_minimum_height_trees()
                .findMinHeightTrees(4, new int[][]{ { 1, 0 }, { 1, 2 }, { 1, 3 } });
        int i = 1;
    }

    public List<Integer> findMinHeightTrees(int n, int[][] edges) {
        if (n == 1) {
            List<Integer> init = new ArrayList<>();
            init.add(0);
            return init;
        }
        Map<Integer, List<Integer>> map = new HashMap<>();
        for (int[] edge : edges) {
            map.putIfAbsent(edge[0], new ArrayList<>());
            map.get(edge[0]).add(edge[1]);

            map.putIfAbsent(edge[1], new ArrayList<>());
            map.get(edge[1]).add(edge[0]);
        }

        while (true) {
            List<Integer> leafList = new ArrayList<>();
            List<Map.Entry<Integer, List<Integer>>> entryList = new ArrayList<>(map.entrySet());
            List<Integer[]> toDelete = new ArrayList<>();
            for (Map.Entry<Integer, List<Integer>> entry : entryList) {
                if (entry.getValue().size() <= 1) {
                    for (Integer val : entry.getValue()) {
                        toDelete.add(new Integer[]{ val, entry.getKey() });
                    }
                    leafList.add(entry.getKey());
                    map.remove(entry.getKey());
                }
            }
            for (Integer[] ints : toDelete) {
                if (map.containsKey(ints[0])) {
                    map.get(ints[0]).remove(ints[1]);
                }
            }
            if (map.isEmpty()) {
                return leafList;
            }
        }
    }
}
