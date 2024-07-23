package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/7/23
 * 给你单链表的头指针 head 和两个整数 left 和 right ，其中 left <= right 。请你反转从位置 left 到位置 right 的链表节点，返回 反转后的链表 。
 * 示例 1：
 * 输入：head = [1,2,3,4,5], left = 2, right = 4
 * 输出：[1,4,3,2,5]
 * 示例 2：
 * 输入：head = [5], left = 1, right = 1
 * 输出：[5]
 * 提示：
 * 链表中节点数目为 n
 * 1 <= n <= 500
 * -500 <= Node.val <= 500
 * 1 <= left <= right <= n
 * 进阶： 你可以使用一趟扫描完成反转吗？
 */
public class LC92_reverse_linked_list_ii {

    public static class ListNode {

        int val;
        ListNode next;

        ListNode() {}

        ListNode(int val) { this.val = val; }

        ListNode(int val, ListNode next) { this.val = val; this.next = next; }
    }

    public static void main(String[] args) {
        ListNode head = new ListNode(1);
        ListNode cur = head;
        cur.next = new ListNode(2);
        cur = cur.next;
        cur.next = new ListNode(3);
        cur = cur.next;
        cur.next = new ListNode(4);
        cur = cur.next;
        cur.next = new ListNode(5);
        new LC92_reverse_linked_list_ii().reverseBetween(head, 2, 4);
    }

    public ListNode reverseBetween(ListNode head, int left, int right) {
        if (left == right) {
            return head;
        }
        ListNode pre = new ListNode();
        pre.next = head;
        int begin = 0;

        ListNode cur = pre;
        ListNode lastBeforeLeft = null;
        ListNode firstAfterRight = null;
        ListNode leftNode = null;
        ListNode rightNode = null;

        ListNode temp = null;

        while (true) {
            if (begin + 1 == left) {
                lastBeforeLeft = cur;
                leftNode = cur.next;
            }
            if (begin == right) {
                rightNode = cur;
                firstAfterRight = cur.next;
            }
            if (begin > right) {
                break;
            }
            ListNode next = cur.next;
            if (begin >= left) {
                cur.next = temp;
                temp = cur;
            }
            cur = next;
            begin++;
        }
        lastBeforeLeft.next = rightNode;
        leftNode.next = firstAfterRight;
        return pre.next;
    }
}
