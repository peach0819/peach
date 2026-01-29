package com.peach.algo.LC651_700_toVip;

/**
 * @author feitao.zt
 * @date 2025/11/13
 * 树可以看成是一个连通且 无环 的 无向 图。
 * 给定一个图，该图从一棵 n 个节点 (节点值 1～n) 的树中添加一条边后获得。添加的边的两个不同顶点编号在 1 到 n 中间，且这条附加的边不属于树中已存在的边。图的信息记录于长度为 n 的二维数组 edges ，edges[i] = [ai, bi] 表示图中在 ai 和 bi 之间存在一条边。
 * 请找出一条可以删去的边，删除后可使得剩余部分是一个有着 n 个节点的树。如果有多个答案，则返回数组 edges 中最后出现的那个。
 * 示例 1：
 * 输入: edges = [[1,2], [1,3], [2,3]]
 * 输出: [2,3]
 * 示例 2：
 * 输入: edges = [[1,2], [2,3], [3,4], [1,4], [1,5]]
 * 输出: [1,4]
 * 提示:
 * n == edges.length
 * 3 <= n <= 1000
 * edges[i].length == 2
 * 1 <= ai < bi <= edges.length
 * ai != bi
 * edges 中无重复元素
 * 给定的图是连通的
 */
public class LC684_redundant_connection {

    int[] parent;

    /**
     * 官方题解， 并查集， 思路是顶点不同的两个节点，顶点合并，如果顶点相同，就说明出现环了
     */
    public int[] findRedundantConnection(int[][] edges) {
        parent = new int[edges.length + 1];
        for (int i = 1; i <= edges.length; i++) {
            parent[i] = i;
        }
        for (int[] cur : edges) {
            int cur0Parent = find(cur[0]);
            int cur1Parent = find(cur[1]);
            if (cur0Parent != cur1Parent) {
                parent[cur1Parent] = cur0Parent;
            } else {
                return cur;
            }
        }
        return new int[0];
    }

    public int find(int index) {
        if (parent[index] != index) {
            parent[index] = find(parent[index]);
        }
        return parent[index];
    }

    //public int[] findRedundantConnection(int[][] edges) {
    //    Set<Integer>[] map = new Set[edges.length + 1];
    //    int[] last = null;
    //    for (int i = 0; i < edges.length; i++) {
    //        int[] edge = edges[i];
    //        if (map[edge[0]] == null) {
    //            map[edge[0]] = new HashSet<>();
    //        }
    //        if (map[edge[1]] == null) {
    //            map[edge[1]] = new HashSet<>();
    //        }
    //        if (map[edge[0]].contains(edge[1]) || map[edge[1]].contains(edge[0])) {
    //            last = edge;
    //            continue;
    //        }
    //        Set<Integer> cur = new HashSet<>();
    //        cur.add(edge[0]);
    //        cur.add(edge[1]);
    //        cur.addAll(map[edge[0]]);
    //        cur.addAll(map[edge[1]]);
    //        for (Integer val1 : cur) {
    //            for (Integer val2 : cur) {
    //                if (val1.equals(val2)) {
    //                    continue;
    //                }
    //                map[val1].add(val2);
    //            }
    //        }
    //    }
    //    return last;
    //}

    //public int[] findRedundantConnection(int[][] edges) {
    //    List<Integer>[] map = new List[edges.length + 1];
    //    for (int[] edge : edges) {
    //        if (map[edge[0]] == null) {
    //            map[edge[0]] = new ArrayList<>();
    //        }
    //        map[edge[0]].add(edge[1]);
    //    }
    //    boolean[] visited = new boolean[edges.length + 1];
    //    List<Integer> queue = new ArrayList<>();
    //    queue.add(edges[0][0]);
    //    visited[edges[0][0]] = true;
    //    while (true) {
    //        List<Integer> newQueue = new ArrayList<>();
    //        for (Integer cur : queue) {
    //            Integer result = null;
    //            List<Integer> list = map[cur];
    //            if (list == null) {
    //                continue;
    //            }
    //            for (Integer next : list) {
    //                if (visited[next]) {
    //                    result = next;
    //                } else {
    //                    visited[next] = true;
    //                    newQueue.add(next);
    //                }
    //            }
    //            if (result != null) {
    //                return new int[]{ cur, result };
    //            }
    //        }
    //        queue = newQueue;
    //    }
    //}

}
