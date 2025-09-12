package com.peach.algo;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2025/9/12
 * 给定一个非空二叉树的根节点 root , 以数组的形式返回每一层节点的平均值。与实际答案相差 10-5 以内的答案可以被接受。
 * 示例 1：
 * 输入：root = [3,9,20,null,null,15,7]
 * 输出：[3.00000,14.50000,11.00000]
 * 解释：第 0 层的平均值为 3,第 1 层的平均值为 14.5,第 2 层的平均值为 11 。
 * 因此返回 [3, 14.5, 11] 。
 * 示例 2:
 * 输入：root = [3,9,20,15,7]
 * 输出：[3.00000,14.50000,11.00000]
 * 提示：
 * 树中节点数量在 [1, 104] 范围内
 * -231 <= Node.val <= 231 - 1
 */
public class LC637_average_of_levels_in_binary_tree {

    List<Double> sumMap = new ArrayList<>();
    List<Integer> depthMap = new ArrayList<>();

    public List<Double> averageOfLevels(TreeNode root) {
        handle(root, 0);
        List<Double> result = new ArrayList<>();
        for (int i = 0; i < depthMap.size(); i++) {
            result.add(sumMap.get(i) / depthMap.get(i));
        }
        return result;
    }

    private void handle(TreeNode node, int depth) {
        if (node == null) {
            return;
        }
        if (depthMap.size() <= depth) {
            depthMap.add(1);
            sumMap.add((double) node.val);
        } else {
            depthMap.set(depth, depthMap.get(depth) + 1);
            sumMap.set(depth, sumMap.get(depth) + node.val);
        }
        handle(node.left, depth + 1);
        handle(node.right, depth + 1);
    }
}
