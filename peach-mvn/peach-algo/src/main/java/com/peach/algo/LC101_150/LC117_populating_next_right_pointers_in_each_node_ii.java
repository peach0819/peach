package com.peach.algo.LC101_150;

/**
 * @author feitao.zt
 * @date 2024/7/26
 * 给定一个二叉树：
 * struct Node {
 * int val;
 * Node *left;
 * Node *right;
 * Node *next;
 * }
 * 填充它的每个 next 指针，让这个指针指向其下一个右侧节点。如果找不到下一个右侧节点，则将 next 指针设置为 NULL 。
 * 初始状态下，所有 next 指针都被设置为 NULL 。
 * 示例 1：
 * 输入：root = [1,2,3,4,5,null,7]
 * 输出：[1,#,2,3,#,4,5,7,#]
 * 解释：给定二叉树如图 A 所示，你的函数应该填充它的每个 next 指针，以指向其下一个右侧节点，如图 B 所示。序列化输出按层序遍历顺序（由 next 指针连接），'#' 表示每层的末尾。
 * 示例 2：
 * 输入：root = []
 * 输出：[]
 * 提示：
 * 树中的节点数在范围 [0, 6000] 内
 * -100 <= Node.val <= 100
 * 进阶：
 * 你只能使用常量级额外空间。
 * 使用递归解题也符合要求，本题中递归程序的隐式栈空间不计入额外空间复杂度。
 */
public class LC117_populating_next_right_pointers_in_each_node_ii {

    class Node {

        public int val;
        public Node left;
        public Node right;
        public Node next;

        public Node() {}

        public Node(int _val) {
            val = _val;
        }

        public Node(int _val, Node _left, Node _right, Node _next) {
            val = _val;
            left = _left;
            right = _right;
            next = _next;
        }
    }

    public Node connect(Node root) {
        handle(root);
        return root;
    }

    private void handle(Node root) {
        if (root == null || (root.left == null && root.right == null)) {
            return;
        }
        if (root.left != null && root.right != null) {
            root.left.next = root.right;
        }
        Node next = root.next;
        if (next != null) {
            Node left = firstNotNull(root.right, root.left);
            Node right = null;
            while (next != null) {
                right = firstNotNull(next.left, next.right);
                if (right != null) {
                    break;
                }
                next = next.next;
            }
            left.next = right;
        }

        handle(root.right);
        handle(root.left);
    }

    public Node firstNotNull(Node... nodes) {
        for (Node node : nodes) {
            if (node != null) {
                return node;
            }
        }
        return null;
    }
}
