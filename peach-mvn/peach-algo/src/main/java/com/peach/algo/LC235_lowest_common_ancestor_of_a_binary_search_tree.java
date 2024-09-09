package com.peach.algo;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2024/9/9
 * 给定一个二叉搜索树, 找到该树中两个指定节点的最近公共祖先。
 * 百度百科中最近公共祖先的定义为：“对于有根树 T 的两个结点 p、q，最近公共祖先表示为一个结点 x，满足 x 是 p、q 的祖先且 x 的深度尽可能大（一个节点也可以是它自己的祖先）。”
 * 例如，给定如下二叉搜索树:  root = [6,2,8,0,4,7,9,null,null,3,5]
 * 示例 1:
 * 输入: root = [6,2,8,0,4,7,9,null,null,3,5], p = 2, q = 8
 * 输出: 6
 * 解释: 节点 2 和节点 8 的最近公共祖先是 6。
 * 示例 2:
 * 输入: root = [6,2,8,0,4,7,9,null,null,3,5], p = 2, q = 4
 * 输出: 2
 * 解释: 节点 2 和节点 4 的最近公共祖先是 2, 因为根据定义最近公共祖先节点可以为节点本身。
 * 说明:
 * 所有节点的值都是唯一的。
 * p、q 为不同节点且均存在于给定的二叉搜索树中。
 */
public class LC235_lowest_common_ancestor_of_a_binary_search_tree {

    TreeNode ancestor = null;

    int depth = -1;

    public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
        if (root == null || p == null || q == null) {
            return null;
        }
        if (p.val < q.val) {
            can(root, p, q, 0);
        } else {
            can(root, q, p, 0);
        }
        return ancestor;
    }

    private boolean[] can(TreeNode cur, TreeNode p, TreeNode q, int depth) {
        if (cur == null) {
            return new boolean[]{ false, false };
        }
        boolean[] left = cur.val > p.val ? can(cur.left, p, q, depth + 1) : new boolean[]{ false, false };
        boolean[] right = cur.val < q.val ? can(cur.right, p, q, depth + 1) : new boolean[]{ false, false };

        boolean leftCan = cur.val == p.val || left[0] || right[0];
        boolean rightCan = cur.val == q.val || left[1] || right[1];
        if (leftCan && rightCan && depth > this.depth) {
            ancestor = cur;
            this.depth = depth;
        }
        return new boolean[]{ leftCan, rightCan };
    }

}
