package com.peach.algo.LC0_50;

import com.peach.algo.base.ListNode;

/**
 * @author feitao.zt
 * @date 2024/7/3
 * 给你一个链表，两两交换其中相邻的节点，并返回交换后链表的头节点。你必须在不修改节点内部的值的情况下完成本题（即，只能进行节点交换）。
 * 示例 1：
 * 输入：head = [1,2,3,4]
 * 输出：[2,1,4,3]
 * 示例 2：
 * 输入：head = []
 * 输出：[]
 * 示例 3：
 * 输入：head = [1]
 * 输出：[1]
 * 提示：
 * 链表中节点的数目在范围 [0, 100] 内
 * 0 <= Node.val <= 100
 */
public class LC24_swap_nodes_in_pairs {

    public ListNode swapPairs(ListNode head) {
        if (head == null || head.next == null) {
            return head;
        }
        ListNode pre = new ListNode(0, head);
        ListNode index = pre;

        ListNode first;
        ListNode second;
        while (index.next != null && index.next.next != null) {
            first = index.next;
            second = index.next.next;
            index.next = second;
            first.next = second.next;
            second.next = first;
            index = first;
        }
        return pre.next;
    }
}
