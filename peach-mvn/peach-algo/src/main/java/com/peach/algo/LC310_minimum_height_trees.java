package com.peach.algo;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Queue;

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

    public List<Integer> findMinHeightTrees1(int n, int[][] edges) {
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

    public List<Integer> findMinHeightTrees(int n, int[][] edges) {
        if (n == 1) {
            return Collections.singletonList(0);
        }
        /*
        无向图拓扑排序处理子节点的方式：
        1. 定义数组g[]，g[i]表示i节点的所有相邻节点之和。
        2. 当i的度为1时，g[i]的值就是那个唯一的相邻节点。
        3. 每次拓扑循环时，一定会先把i的其他相邻节点入队。而每次处理度为1的节点x时，都会把相邻节点的值减去x。
        4. 所以当处理到i时，g[i]就变成了唯一的相邻节点。
         */
        int[] g = new int[n];
        int[] degree = new int[n];
        for (int[] edge : edges) {
            int a = edge[0];
            int b = edge[1];
            // 维护节点的度
            degree[a]++;
            degree[b]++;
            // g[]表示相邻节点之和
            g[a] += b;
            g[b] += a;
        }
        Queue<Integer> q = new ArrayDeque<>();
        // 初始化，入度等于1的节点入队
        for (int i = 0; i < n; i++) {
            if (degree[i] == 1) {
                q.offer(i);
            }
        }
        // 还剩多少节点没有处理
        int remain = n;
        // 剩余超过2个节点，说明还没到中间点
        while (remain > 2) {
            int size = q.size();
            // 每轮处理一圈外部叶子节点
            remain -= size;
            for (int k = 0; k < size; k++) {
                // cur是当前处理节点，度=1
                int cur = q.poll();
                // 由于度=1，所以g[cur]的值就是cur唯一的一个相邻节点
                int nx = g[cur];
                // 相邻节点的g值减去当前节点
                g[nx] -= cur;
                // 相邻节点度减1，如果度等于1，入队
                if (--degree[nx] == 1) {
                    q.offer(nx);
                }
            }
        }
        // 最后剩1个或2个节点，这两个节点一定是度为1的节点且放入了队列
        List<Integer> ans = new ArrayList<>();
        while (!q.isEmpty()) {
            ans.add(q.poll());
        }
        return ans;
    }
}
