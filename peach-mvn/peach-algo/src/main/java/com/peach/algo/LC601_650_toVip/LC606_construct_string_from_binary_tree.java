package com.peach.algo.LC601_650_toVip;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2025/9/1
 * 给你二叉树的根节点 root ，请你采用前序遍历的方式，将二叉树转化为一个由括号和整数组成的字符串，返回构造出的字符串。
 * 空节点使用一对空括号对 "()" 表示，转化后需要省略所有不影响字符串与原始二叉树之间的一对一映射关系的空括号对。
 * 示例 1：
 * 输入：root = [1,2,3,4]
 * 输出："1(2(4))(3)"
 * 解释：初步转化后得到 "1(2(4)())(3()())" ，但省略所有不必要的空括号对后，字符串应该是"1(2(4))(3)" 。
 * 示例 2：
 * 输入：root = [1,2,3,null,4]
 * 输出："1(2()(4))(3)"
 * 解释：和第一个示例类似，但是无法省略第一个空括号对，否则会破坏输入与输出一一映射的关系。
 * 提示：
 * 树中节点的数目范围是 [1, 104]
 * -1000 <= Node.val <= 1000
 */
public class LC606_construct_string_from_binary_tree {

    public String tree2str(TreeNode root) {
        StringBuilder sb = new StringBuilder();
        handle(root, sb);
        return sb.toString();
    }

    private void handle(TreeNode node, StringBuilder sb) {
        if (node == null) {
            return;
        }
        sb.append(node.val);
        if (node.left == null && node.right == null) {
            return;
        }
        if (node.left != null) {
            sb.append("(");
            handle(node.left, sb);
            sb.append(")");
        } else {
            sb.append("()");
        }
        if (node.right != null) {
            sb.append("(");
            handle(node.right, sb);
            sb.append(")");
        }
    }
}
