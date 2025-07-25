package com.peach.algo;

import com.peach.algo.base.Node;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2023/7/12
 * 给定一个 n 叉树的根节点  root ，返回 其节点值的 前序遍历 。
 * n 叉树 在输入中按层序遍历进行序列化表示，每组子节点由空值 null 分隔（请参见示例）。
 * 示例 1：
 * 输入：root = [1,null,3,2,4,null,5,6]
 * 输出：[1,3,5,6,2,4]
 * 示例 2：
 * 输入：root = [1,null,2,3,4,5,null,null,6,7,null,8,null,9,10,null,null,11,null,12,null,13,null,null,14]
 * 输出：[1,2,3,6,7,11,14,4,8,12,5,9,13,10]
 *  
 * 来源：力扣（LeetCode）
 * 链接：https://leetcode.cn/problems/n-ary-tree-preorder-traversal
 * 著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
 */
public class LC589_n_ary_tree_preorder_traversal {

    public List<Integer> preorder(Node root) {
        List<Integer> result = new ArrayList<>();
        readNode(root, result);
        return result;
    }

    private void readNode(Node node, List<Integer> result) {
        if (node == null) {
            return;
        }
        result.add(node.val);
        if (node.children != null && node.children.size() > 0) {
            for (Node child : node.children) {
                readNode(child, result);
            }
        }
    }
}
