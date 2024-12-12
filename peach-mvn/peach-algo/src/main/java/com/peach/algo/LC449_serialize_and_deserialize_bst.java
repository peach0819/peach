package com.peach.algo;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2024/12/12
 * 序列化是将数据结构或对象转换为一系列位的过程，以便它可以存储在文件或内存缓冲区中，或通过网络连接链路传输，以便稍后在同一个或另一个计算机环境中重建。
 * 设计一个算法来序列化和反序列化 二叉搜索树 。 对序列化/反序列化算法的工作方式没有限制。 您只需确保二叉搜索树可以序列化为字符串，并且可以将该字符串反序列化为最初的二叉搜索树。
 * 编码的字符串应尽可能紧凑。
 * 示例 1：
 * 输入：root = [2,1,3]
 * 输出：[2,1,3]
 * 示例 2：
 * 输入：root = []
 * 输出：[]
 * 提示：
 * 树中节点数范围是 [0, 104]
 * 0 <= Node.val <= 104
 * 题目数据 保证 输入的树是一棵二叉搜索树。
 */
public class LC449_serialize_and_deserialize_bst {

    // Your Codec object will be instantiated and called as such:
    // Codec ser = new Codec();
    // Codec deser = new Codec();
    // String tree = ser.serialize(root);
    // TreeNode ans = deser.deserialize(tree);
    // return ans;
    public class Codec {

        // Encodes a tree to a single string.
        public String serialize(TreeNode root) {
            if (root == null) {
                return "";
            }
            StringBuilder sb = new StringBuilder();
            combine(root, sb);
            return sb.toString();
        }

        private void combine(TreeNode root, StringBuilder sb) {
            sb.append(root.val);
            if (root.left != null) {
                sb.append(",");
                combine(root.left, sb);
            }
            if (root.right != null) {
                sb.append(",");
                combine(root.right, sb);
            }
        }

        // Decodes your encoded data to tree.
        public TreeNode deserialize(String data) {
            if (data.isEmpty()) {
                return null;
            }
            String[] split = data.split(",");
            int[] array = new int[split.length];
            for (int i = 0; i < split.length; i++) {
                array[i] = Integer.parseInt(split[i]);
            }
            return build(array, 0, array.length - 1);
        }

        private TreeNode build(int[] array, int begin, int end) {
            int val = array[begin];
            TreeNode node = new TreeNode();
            node.val = val;
            if (begin == end) {
                return node;
            }
            int nextVal = array[begin + 1];
            if (nextVal > val) {
                node.left = null;
                node.right = build(array, begin + 1, end);
            } else {
                boolean hasRight = false;
                int rightBegin = 0;
                for (int i = begin + 2; i <= end; i++) {
                    if (array[i] > val) {
                        hasRight = true;
                        rightBegin = i;
                        break;
                    }
                }
                if (hasRight) {
                    node.left = build(array, begin + 1, rightBegin - 1);
                    node.right = build(array, rightBegin, end);
                } else {
                    node.left = build(array, begin + 1, end);
                    node.right = null;
                }
            }
            return node;
        }
    }

}
