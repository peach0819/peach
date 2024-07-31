package com.peach.algo;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2024/7/25
 * 给你二叉树的根节点 root 和一个表示目标和的整数 targetSum 。判断该树中是否存在 根节点到叶子节点 的路径，这条路径上所有节点值相加等于目标和 targetSum 。如果存在，返回 true ；否则，返回 false 。
 * 叶子节点 是指没有子节点的节点。
 * 示例 1：
 * 输入：root = [5,4,8,11,null,13,4,7,2,null,null,null,1], targetSum = 22
 * 输出：true
 * 解释：等于目标和的根节点到叶节点路径如上图所示。
 * 示例 2：
 * 输入：root = [1,2,3], targetSum = 5
 * 输出：false
 * 解释：树中存在两条根节点到叶子节点的路径：
 * (1 --> 2): 和为 3
 * (1 --> 3): 和为 4
 * 不存在 sum = 5 的根节点到叶子节点的路径。
 * 示例 3：
 * 输入：root = [], targetSum = 0
 * 输出：false
 * 解释：由于树是空的，所以不存在根节点到叶子节点的路径。
 * 提示：
 * 树中节点的数目在范围 [0, 5000] 内
 * -1000 <= Node.val <= 1000
 * -1000 <= targetSum <= 1000
 */
public class LC112_path_sum {

    int targetSum;

    public boolean hasPathSum(TreeNode root, int targetSum) {
        this.targetSum = targetSum;
        return handle(root, 0);
    }

    private boolean handle(TreeNode node, int cur) {
        if (node == null) {
            return false;
        }
        cur += node.val;
        if (cur == targetSum && node.left == null && node.right == null) {
            return true;
        }
        return handle(node.left, cur) || handle(node.right, cur);
    }
}
