package com.peach.algo;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2025/2/27
 * 给你一个二叉树的根结点 root ，请返回出现次数最多的子树元素和。如果有多个元素出现的次数相同，返回所有出现次数最多的子树元素和（不限顺序）。
 * 一个结点的 「子树元素和」 定义为以该结点为根的二叉树上所有结点的元素之和（包括结点本身）。
 * 示例 1：
 * 输入: root = [5,2,-3]
 * 输出: [2,-3,4]
 * 示例 2：
 * 输入: root = [5,2,-5]
 * 输出: [2]
 * 提示:
 * 节点数在 [1, 104] 范围内
 * -105 <= Node.val <= 105
 */
public class LC508_most_frequent_subtree_sum {

    public static void main(String[] args) {
        TreeNode node = new TreeNode();
        node.val = 5;
        node.left = new TreeNode(2);
        node.right = new TreeNode(-3);
        int[] ints = new LC508_most_frequent_subtree_sum().findFrequentTreeSum(node);
        int i = 1;
    }

    Map<Integer, Integer> map = new HashMap<>();

    List<Integer> mostList = new ArrayList<>();
    int mostTimes = 0;

    public int[] findFrequentTreeSum(TreeNode root) {
        sum(root);
        int[] result = new int[mostList.size()];
        for (int i = 0; i < mostList.size(); i++) {
            result[i] = mostList.get(i);
        }
        return result;
    }

    private int sum(TreeNode root) {
        if (root == null) {
            return 0;
        }
        int sum = root.val + sum(root.left) + sum(root.right);
        int cur = map.getOrDefault(sum, 0) + 1;
        if (cur > mostTimes) {
            mostList = new ArrayList<>();
            mostList.add(sum);
            mostTimes = cur;
        } else if (cur == mostTimes) {
            mostList.add(sum);
        }
        map.put(sum, cur);
        return sum;
    }

}
