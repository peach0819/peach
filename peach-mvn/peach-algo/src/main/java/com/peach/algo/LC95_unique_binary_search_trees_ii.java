package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/23
 * 给你一个整数 n ，请你生成并返回所有由 n 个节点组成且节点值从 1 到 n 互不相同的不同 二叉搜索树 。可以按 任意顺序 返回答案。
 * 示例 1：
 * 输入：n = 3
 * 输出：[[1,null,2,null,3],[1,null,3,2],[2,1,3],[3,1,null,null,2],[3,2,null,1]]
 * 示例 2：
 * 输入：n = 1
 * 输出：[[1]]
 * 提示：
 * 1 <= n <= 8
 */
public class LC95_unique_binary_search_trees_ii {

    public class TreeNode {

        int val;
        TreeNode left;
        TreeNode right;

        TreeNode() {}

        TreeNode(int val) { this.val = val; }

        TreeNode(int val, TreeNode left, TreeNode right) {
            this.val = val;
            this.left = left;
            this.right = right;
        }
    }

    public List<TreeNode> generateTrees(int n) {
        List<Integer> list = new ArrayList<>();
        for (int i = 1; i <= n; i++) {
            list.add(i);
        }
        return buildTree(list);
    }

    private List<TreeNode> buildTree(List<Integer> list) {
        if (list.size() == 0) {
            return null;
        }
        List<TreeNode> result = new ArrayList<>();
        if (list.size() == 1) {
            result.add(new TreeNode(list.get(0)));
            return result;
        }
        for (int i = 0; i < list.size(); i++) {
            Integer cur = list.get(i);
            List<TreeNode> leftTrees = buildTree(list, 0, i);
            List<TreeNode> rightTrees = buildTree(list, i + 1, list.size());
            if (leftTrees == null) {
                for (TreeNode rightTree : rightTrees) {
                    result.add(new TreeNode(cur, null, rightTree));
                }
                continue;
            }
            if (rightTrees == null) {
                for (TreeNode leftTree : leftTrees) {
                    result.add(new TreeNode(cur, leftTree, null));
                }
                continue;
            }
            for (TreeNode leftTree : leftTrees) {
                for (TreeNode rightTree : rightTrees) {
                    result.add(new TreeNode(cur, leftTree, rightTree));
                }
            }
        }
        return result;
    }

    private List<TreeNode> buildTree(List<Integer> list, int begin, int end) {
        if (begin == end) {
            return null;
        }
        return buildTree(new ArrayList<>(list.subList(begin, end)));
    }
}
