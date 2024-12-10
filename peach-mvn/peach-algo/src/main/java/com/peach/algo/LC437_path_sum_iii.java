package com.peach.algo;

import com.peach.algo.base.TreeNode;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/12/10
 * 给定一个二叉树的根节点 root ，和一个整数 targetSum ，求该二叉树里节点值之和等于 targetSum 的 路径 的数目。
 * 路径 不需要从根节点开始，也不需要在叶子节点结束，但是路径方向必须是向下的（只能从父节点到子节点）。
 * 示例 1：
 * 输入：root = [10,5,-3,3,2,null,11,3,-2,null,1], targetSum = 8
 * 输出：3
 * 解释：和等于 8 的路径有 3 条，如图所示。
 * 示例 2：
 * 输入：root = [5,4,8,11,null,13,4,7,2,null,null,5,1], targetSum = 22
 * 输出：3
 * 提示:
 * 二叉树的节点个数的范围是 [0,1000]
 * -109 <= Node.val <= 109
 * -1000 <= targetSum <= 1000
 */
public class LC437_path_sum_iii {

    int result = 0;
    int targetSum;

    //public int pathSum(TreeNode root, int targetSum) {
    //    this.targetSum = targetSum;
    //    if (root == null) {
    //        return 0;
    //    }
    //    handle(root, new ArrayList<>());
    //    return result;
    //}
    //
    //private void handle(TreeNode node, List<Long> list) {
    //    if (node == null) {
    //        return;
    //    }
    //    if (node.val == targetSum) {
    //        result++;
    //    }
    //    List<Long> next = new ArrayList<>(list.size() + 1);
    //    next.add((long) node.val);
    //    for (Long num : list) {
    //        long cur = num + node.val;
    //        if (cur == targetSum) {
    //            result++;
    //        }
    //        next.add(cur);
    //    }
    //    handle(node.left, next);
    //    handle(node.right, next);
    //}

    Map<Long, Integer> prefix = new HashMap<>();

    public int pathSum(TreeNode root, int targetSum) {
        this.targetSum = targetSum;
        prefix.put(0L, 1);
        return dfs(root, 0);
    }

    public int dfs(TreeNode root, long curr) {
        if (root == null) {
            return 0;
        }

        curr += root.val;

        int ret = prefix.getOrDefault(curr - targetSum, 0);
        prefix.put(curr, prefix.getOrDefault(curr, 0) + 1);
        ret += dfs(root.left, curr);
        ret += dfs(root.right, curr);
        prefix.put(curr, prefix.getOrDefault(curr, 0) - 1);

        return ret;
    }

}