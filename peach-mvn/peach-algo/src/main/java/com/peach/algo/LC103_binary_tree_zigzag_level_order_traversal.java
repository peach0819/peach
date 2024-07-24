package com.peach.algo;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/24
 * 给你二叉树的根节点 root ，返回其节点值的 锯齿形层序遍历 。（即先从左往右，再从右往左进行下一层遍历，以此类推，层与层之间交替进行）。
 * 示例 1：
 * 输入：root = [3,9,20,null,null,15,7]
 * 输出：[[3],[20,9],[15,7]]
 * 示例 2：
 * 输入：root = [1]
 * 输出：[[1]]
 * 示例 3：
 * 输入：root = []
 * 输出：[]
 * 提示：
 * 树中节点数目在范围 [0, 2000] 内
 * -100 <= Node.val <= 100
 */
public class LC103_binary_tree_zigzag_level_order_traversal {

    List<List<Integer>> result = new ArrayList<>();

    public List<List<Integer>> zigzagLevelOrder(TreeNode root) {
        if (root == null) {
            return new ArrayList<>();
        }
        List<TreeNode> list = new ArrayList<>();
        list.add(root);
        handle(list, true);
        return result;
    }

    private void handle(List<TreeNode> list, boolean asc) {
        if (list.isEmpty()) {
            return;
        }
        List<Integer> cur = new ArrayList<>();
        List<TreeNode> next = new ArrayList<>();
        for (int i = 0; i < list.size(); i++) {
            TreeNode node = list.get(i);
            if (asc) {
                cur.add(node.val);
            } else {
                cur.add(list.get(list.size() - 1 - i).val);
            }

            if (node.left != null) {
                next.add(node.left);
            }
            if (node.right != null) {
                next.add(node.right);
            }
        }
        result.add(cur);
        handle(next, !asc);
    }
}
