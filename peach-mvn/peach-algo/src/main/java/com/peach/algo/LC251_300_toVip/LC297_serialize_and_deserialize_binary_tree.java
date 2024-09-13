package com.peach.algo.LC251_300_toVip;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2024/9/12
 * 序列化是将一个数据结构或者对象转换为连续的比特位的操作，进而可以将转换后的数据存储在一个文件或者内存中，同时也可以通过网络传输到另一个计算机环境，采取相反方式重构得到原数据。
 * 请设计一个算法来实现二叉树的序列化与反序列化。这里不限定你的序列 / 反序列化算法执行逻辑，你只需要保证一个二叉树可以被序列化为一个字符串并且将这个字符串反序列化为原始的树结构。
 * 提示: 输入输出格式与 LeetCode 目前使用的方式一致，详情请参阅 LeetCode 序列化二叉树的格式。你并非必须采取这种方式，你也可以采用其他的方法解决这个问题。
 * 示例 1：
 * 输入：root = [1,2,3,null,null,4,5]
 * 输出：[1,2,3,null,null,4,5]
 * 示例 2：
 * 输入：root = []
 * 输出：[]
 * 示例 3：
 * 输入：root = [1]
 * 输出：[1]
 * 示例 4：
 * 输入：root = [1,2]
 * 输出：[1,2]
 * 提示：
 * 树中结点数在范围 [0, 104] 内
 * -1000 <= Node.val <= 1000
 */
public class LC297_serialize_and_deserialize_binary_tree {

    public static void main(String[] args) {
        TreeNode node1 = new TreeNode(1);
        TreeNode node2 = new TreeNode(2);
        TreeNode node3 = new TreeNode(3);
        TreeNode node4 = new TreeNode(4);
        TreeNode node5 = new TreeNode(5);
        node1.left = node2;
        node1.right = node3;
        node3.left = node4;
        node3.right = node5;

        Codec codec = new LC297_serialize_and_deserialize_binary_tree().new Codec();
        String serialize = codec.serialize(node1);
        TreeNode deserialize = codec.deserialize(serialize);
        int i = 1;
    }

    // Your Codec object will be instantiated and called as such:
    // Codec ser = new Codec();
    // Codec deser = new Codec();
    // TreeNode ans = deser.deserialize(ser.serialize(root));
    public class Codec {

        // Encodes a tree to a single string.
        public String serialize(TreeNode root) {
            if (root == null) {
                return "";
            }
            StringBuilder s = new StringBuilder();
            serialize(s, root, 0);
            return s.toString();
        }

        private void serialize(StringBuilder s, TreeNode node, int depth) {
            s.append(node.val);
            if (node.left != null) {
                s.append("l").append(depth).append("@");
                serialize(s, node.left, depth + 1);
            } else {
                s.append("l").append(depth).append("@x");
            }

            if (node.right != null) {
                s.append("r").append(depth).append("@");
                serialize(s, node.right, depth + 1);
            } else {
                s.append("r").append(depth).append("@x");
            }

        }

        // Decodes your encoded data to tree.
        public TreeNode deserialize(String data) {
            if (data.isEmpty()) {
                return null;
            }
            return deserialize(data, 0, data.length() - 1, 0);
        }

        private TreeNode deserialize(String data, int begin, int end, int depth) {
            if (data.charAt(begin) == 'x') {
                return null;
            }
            int i = data.substring(begin, end + 1).indexOf("l" + depth + "@") + begin;
            int j = data.substring(begin, end + 1).indexOf("r" + depth + "@") + begin;
            int length = ("l" + depth + "@").length();
            TreeNode node = new TreeNode();
            node.val = val(data, begin, i - 1);
            node.left = deserialize(data, i + length, j - 1, depth + 1);
            node.right = deserialize(data, j + length, end, depth + 1);
            return node;
        }

        private int val(String data, int begin, int end) {
            int val = 0;
            boolean nega = false;
            if (data.charAt(begin) == '-') {
                nega = true;
                begin++;
            }
            for (int i = begin; i <= end; i++) {
                val *= 10;
                val += data.charAt(i) - '0';
            }
            return nega ? -val : val;
        }
    }

}
