package com.peach.algo.LC151_200_toVip;

import com.peach.algo.base.TreeNode;

import java.util.LinkedList;

/**
 * @author feitao.zt
 * @date 2024/8/8
 * 实现一个二叉搜索树迭代器类BSTIterator ，表示一个按中序遍历二叉搜索树（BST）的迭代器：
 * BSTIterator(TreeNode root) 初始化 BSTIterator 类的一个对象。BST 的根节点 root 会作为构造函数的一部分给出。指针应初始化为一个不存在于 BST 中的数字，且该数字小于 BST 中的任何元素。
 * boolean hasNext() 如果向指针右侧遍历存在数字，则返回 true ；否则返回 false 。
 * int next()将指针向右移动，然后返回指针处的数字。
 * 注意，指针初始化为一个不存在于 BST 中的数字，所以对 next() 的首次调用将返回 BST 中的最小元素。
 * 你可以假设 next() 调用总是有效的，也就是说，当调用 next() 时，BST 的中序遍历中至少存在一个下一个数字。
 * 示例：
 * 输入
 * ["BSTIterator", "next", "next", "hasNext", "next", "hasNext", "next", "hasNext", "next", "hasNext"]
 * [[[7, 3, 15, null, null, 9, 20]], [], [], [], [], [], [], [], [], []]
 * 输出
 * [null, 3, 7, true, 9, true, 15, true, 20, false]
 * 解释
 * BSTIterator bSTIterator = new BSTIterator([7, 3, 15, null, null, 9, 20]);
 * bSTIterator.next();    // 返回 3
 * bSTIterator.next();    // 返回 7
 * bSTIterator.hasNext(); // 返回 True
 * bSTIterator.next();    // 返回 9
 * bSTIterator.hasNext(); // 返回 True
 * bSTIterator.next();    // 返回 15
 * bSTIterator.hasNext(); // 返回 True
 * bSTIterator.next();    // 返回 20
 * bSTIterator.hasNext(); // 返回 False
 * 提示：
 * 树中节点的数目在范围 [1, 105] 内
 * 0 <= Node.val <= 106
 * 最多调用 105 次 hasNext 和 next 操作
 * 进阶：
 * 你可以设计一个满足下述条件的解决方案吗？next() 和 hasNext() 操作均摊时间复杂度为 O(1) ，并使用 O(h) 内存。其中 h 是树的高度。
 */

/**
 * Your BSTIterator object will be instantiated and called as such:
 * BSTIterator obj = new BSTIterator(root);
 * int param_1 = obj.next();
 * boolean param_2 = obj.hasNext();
 */
public class LC173_binary_search_tree_iterator {

    public static void main(String[] args) {
        TreeNode treeNode7 = new TreeNode(7);
        TreeNode treeNode3 = new TreeNode(3);
        TreeNode treeNode15 = new TreeNode(15);
        TreeNode treeNode9 = new TreeNode(9);
        TreeNode treeNode20 = new TreeNode(20);
        treeNode7.left = treeNode3;
        treeNode7.right = treeNode15;
        treeNode15.left = treeNode9;
        treeNode15.right = treeNode20;
        BSTIterator bSTIterator = new LC173_binary_search_tree_iterator().new BSTIterator(treeNode7);
        System.out.println(bSTIterator.next());
        System.out.println(bSTIterator.next());
        System.out.println(bSTIterator.hasNext());
        System.out.println(bSTIterator.next());
        System.out.println(bSTIterator.hasNext());
        System.out.println(bSTIterator.next());
        System.out.println(bSTIterator.hasNext());
        System.out.println(bSTIterator.next());
        System.out.println(bSTIterator.hasNext());
    }

    class BSTIterator {

        LinkedList<TreeNode> indexList = new LinkedList<>();
        LinkedList<Boolean> leftList = new LinkedList<>();
        TreeNode cur;
        boolean firstNext = true;

        public BSTIterator(TreeNode root) {
            cur = findLastLeft(root);
        }

        public int next() {
            if (firstNext) {
                firstNext = false;
                return cur.val;
            }
            if (cur.right != null) {
                indexList.add(cur);
                leftList.add(false);
                cur = findLastLeft(cur.right);
                return cur.val;
            }
            Boolean lastLeft = leftList.removeLast();
            TreeNode lastNode = indexList.removeLast();
            while (true) {
                if (lastLeft) {
                    cur = lastNode;
                    return cur.val;
                }
                if (!indexList.isEmpty()) {
                    lastNode = indexList.removeLast();
                    lastLeft = leftList.removeLast();
                }
            }
        }

        public boolean hasNext() {
            if (firstNext) {
                return true;
            }
            if (cur.right != null) {
                return true;
            }
            for (Boolean left : leftList) {
                if (left) {
                    return true;
                }
            }
            return false;
        }

        public TreeNode findLastLeft(TreeNode root) {
            if (root.left == null) {
                return root;
            }
            indexList.add(root);
            leftList.add(true);
            return findLastLeft(root.left);
        }
    }
}
