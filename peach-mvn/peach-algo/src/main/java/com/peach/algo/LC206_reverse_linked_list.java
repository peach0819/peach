package com.peach.algo;

import com.peach.algo.base.ListNode;

/**
 * @author feitao.zt
 * @date 2024/8/13
 * 给你单链表的头节点 head ，请你反转链表，并返回反转后的链表。
 * 示例 1：
 * 输入：head = [1,2,3,4,5]
 * 输出：[5,4,3,2,1]
 * 示例 2：
 * 输入：head = [1,2]
 * 输出：[2,1]
 * 示例 3：
 * 输入：head = []
 * 输出：[]
 * 提示：
 * 链表中节点的数目范围是 [0, 5000]
 * -5000 <= Node.val <= 5000
 * 进阶：链表可以选用迭代或递归方式完成反转。你能否用两种方法解决这道题？
 */
public class LC206_reverse_linked_list {

    public ListNode reverseList(ListNode head) {
        if (head == null || head.next == null) {
            return head;
        }
        ListNode cur = head.next;
        ListNode pre = head;
        ListNode temp;
        while (true) {
            temp = cur.next;
            cur.next = pre;
            pre = cur;
            if (temp == null) {
                break;
            }
            cur = temp;
        }
        head.next = null;
        return cur;
    }
}
