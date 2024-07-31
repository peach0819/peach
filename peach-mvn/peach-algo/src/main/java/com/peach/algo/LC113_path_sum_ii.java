package com.peach.algo;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/25
 * 给你二叉树的根节点 root 和一个整数目标和 targetSum ，找出所有 从根节点到叶子节点 路径总和等于给定目标和的路径。
 * 叶子节点 是指没有子节点的节点。
 * 示例 1：
 * 输入：root = [5,4,8,11,null,13,4,7,2,null,null,5,1], targetSum = 22
 * 输出：[[5,4,11,2],[5,8,4,5]]
 * 示例 2：
 * 输入：root = [1,2,3], targetSum = 5
 * 输出：[]
 * 示例 3：
 * 输入：root = [1,2], targetSum = 0
 * 输出：[]
 * 提示：
 * 树中节点总数在范围 [0, 5000] 内
 * -1000 <= Node.val <= 1000
 * -1000 <= targetSum <= 1000
 */
public class LC113_path_sum_ii {

    List<List<Integer>> result = new ArrayList<>();
    int targetSum;

    public List<List<Integer>> pathSum(TreeNode root, int targetSum) {
        if (root == null) {
            return result;
        }
        List<Integer> list = new ArrayList<>();
        list.add(root.val);
        this.targetSum = targetSum;
        handle(root, list, 0);
        return result;
    }

    public void handle(TreeNode node, List<Integer> list, int sum) {
        if (node == null) {
            return;
        }
        sum += node.val;
        if (sum == targetSum && node.left == null && node.right == null) {
            result.add(new ArrayList<>(list));
            return;
        }
        if (node.left != null) {
            list.add(node.left.val);
            handle(node.left, list, sum);
            list.remove(list.size() - 1);
        }
        if (node.right != null) {
            list.add(node.right.val);
            handle(node.right, list, sum);
            list.remove(list.size() - 1);
        }
    }
}
