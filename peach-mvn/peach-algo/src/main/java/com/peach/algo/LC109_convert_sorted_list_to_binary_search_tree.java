package com.peach.algo;

import com.peach.algo.base.ListNode;
import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2024/7/25
 * 给定一个单链表的头节点  head ，其中的元素 按升序排序 ，将其转换为 平衡 二叉搜索树。
 * 示例 1:
 * 输入: head = [-10,-3,0,5,9]
 * 输出: [0,-3,9,-10,null,5]
 * 解释: 一个可能的答案是[0，-3,9，-10,null,5]，它表示所示的高度平衡的二叉搜索树。
 * 示例 2:
 * 输入: head = []
 * 输出: []
 * 提示:
 * head 中的节点数在[0, 2 * 104] 范围内
 * -105 <= Node.val <= 105
 */
public class LC109_convert_sorted_list_to_binary_search_tree {

    /**
     * 官方用的快慢指针
     */
    public TreeNode sortedListToBST(ListNode head) {
        if (head == null) {
            return null;
        }
        int[] array = new int[20000];
        int index = 0;
        ListNode cur = head;
        while (true) {
            array[index] = cur.val;
            if (cur.next == null) {
                break;
            }
            cur = cur.next;
            index++;
        }
        return handle(array, 0, index);
    }

    private TreeNode handle(int[] nums, int begin, int end) {
        int mid = (begin + end) / 2;
        TreeNode node = new TreeNode(nums[mid]);
        if (begin < mid) {
            node.left = handle(nums, begin, mid - 1);
        }
        if (end > mid) {
            node.right = handle(nums, mid + 1, end);
        }
        return node;
    }
}
