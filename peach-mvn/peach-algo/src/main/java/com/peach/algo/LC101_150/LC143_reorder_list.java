package com.peach.algo.LC101_150;

import com.peach.algo.base.ListNode;

/**
 * @author feitao.zt
 * @date 2024/8/1
 * 给定一个单链表 L 的头节点 head ，单链表 L 表示为：
 * L0 → L1 → … → Ln - 1 → Ln
 * 请将其重新排列后变为：
 * L0 → Ln → L1 → Ln - 1 → L2 → Ln - 2 → …
 * 不能只是单纯的改变节点内部的值，而是需要实际的进行节点交换。
 * 示例 1：
 * 输入：head = [1,2,3,4]
 * 输出：[1,4,2,3]
 * 示例 2：
 * 输入：head = [1,2,3,4,5]
 * 输出：[1,5,2,4,3]
 * 提示：
 * 链表的长度范围为 [1, 5 * 104]
 * 1 <= node.val <= 1000
 */
public class LC143_reorder_list {

    public static void main(String[] args) {
        ListNode head1 = new ListNode(1);
        ListNode head2 = new ListNode(2);
        ListNode head3 = new ListNode(3);
        ListNode head4 = new ListNode(4);
        head1.next = head2;
        head2.next = head3;
        head3.next = head4;
        new LC143_reorder_list().reorderList(head1);
    }

    public void reorderList(ListNode head) {
        if (head == null || head.next == null || head.next.next == null) {
            return;
        }
        ListNode fast = head;
        ListNode slow = head;
        while (true) {
            if (fast.next == null || fast.next.next == null) {
                break;
            }
            fast = fast.next.next;
            slow = slow.next;
        }
        ListNode begin = slow.next;
        slow.next = null;
        ListNode cur = reverse(begin);

        ListNode new1 = head;
        ListNode new2 = cur;
        ListNode temp1;
        ListNode temp2;
        while (true) {
            if (new1 != null && new2 != null) {
                temp1 = new1.next;
                temp2 = new2.next;
                new1.next = new2;
                new2.next = temp1;
                new1 = temp1;
                new2 = temp2;
            } else {
                break;
            }
        }
    }

    private ListNode reverse(ListNode begin) {
        ListNode cur = begin;
        ListNode next = cur.next;
        ListNode temp;
        while (true) {
            if (next == null) {
                break;
            }
            temp = next.next;
            next.next = cur;
            cur = next;
            next = temp;
        }
        begin.next = null;
        return cur;
    }
}
