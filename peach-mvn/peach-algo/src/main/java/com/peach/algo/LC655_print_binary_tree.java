package com.peach.algo;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2025/10/23
 * 给你一棵二叉树的根节点 root ，请你构造一个下标从 0 开始、大小为 m x n 的字符串矩阵 res ，用以表示树的 格式化布局 。构造此格式化布局矩阵需要遵循以下规则：
 * 树的 高度 为 height ，矩阵的行数 m 应该等于 height + 1 。
 * 矩阵的列数 n 应该等于 2height+1 - 1 。
 * 根节点 需要放置在 顶行 的 正中间 ，对应位置为 res[0][(n-1)/2] 。
 * 对于放置在矩阵中的每个节点，设对应位置为 res[r][c] ，将其左子节点放置在 res[r+1][c-2height-r-1] ，右子节点放置在 res[r+1][c+2height-r-1] 。
 * 继续这一过程，直到树中的所有节点都妥善放置。
 * 任意空单元格都应该包含空字符串 "" 。
 * 返回构造得到的矩阵 res 。
 * 示例 1：
 * 输入：root = [1,2]
 * 输出：
 * [["","1",""],
 * ["2","",""]]
 * 示例 2：
 * 输入：root = [1,2,3,null,4]
 * 输出：
 * [["","","","1","","",""],
 * ["","2","","","","3",""],
 * ["","","4","","","",""]]
 * 提示：
 * 树中节点数在范围 [1, 210] 内
 * -99 <= Node.val <= 99
 * 树的深度在范围 [1, 10] 内
 */
public class LC655_print_binary_tree {

    int height = 0;

    String[][] array;

    public List<List<String>> printTree(TreeNode root) {
        handleHeight(root, 0);
        int length = (1 << (height + 1)) - 1;
        array = new String[height + 1][length];
        for (String[] strings : array) {
            Arrays.fill(strings, "");
        }

        handle(root, 0, (length - 1) / 2);

        List<List<String>> result = new ArrayList<>();
        for (String[] strings : array) {
            result.add(Arrays.asList(strings));
        }
        return result;
    }

    private void handleHeight(TreeNode node, int height) {
        if (node == null) {
            return;
        }
        this.height = Math.max(this.height, height);
        handleHeight(node.left, height + 1);
        handleHeight(node.right, height + 1);
    }

    private void handle(TreeNode node, int height, int parentIndex) {
        if (node == null) {
            return;
        }
        array[height][parentIndex] = String.valueOf(node.val);
        int interval = 1 << (this.height - height - 1);
        handle(node.left, height + 1, parentIndex - interval);
        handle(node.right, height + 1, parentIndex + interval);
    }
}
