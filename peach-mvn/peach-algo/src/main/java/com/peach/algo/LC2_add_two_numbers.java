package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/6/11
 * 给你两个 非空 的链表，表示两个非负的整数。它们每位数字都是按照 逆序 的方式存储的，并且每个节点只能存储 一位 数字。
 * 请你将两个数相加，并以相同形式返回一个表示和的链表。
 * 你可以假设除了数字 0 之外，这两个数都不会以 0 开头。
 * 示例 1：
 * 输入：l1 = [2,4,3], l2 = [5,6,4]
 * 输出：[7,0,8]
 * 解释：342 + 465 = 807.
 * 示例 2：
 * 输入：l1 = [0], l2 = [0]
 * 输出：[0]
 * 示例 3：
 * 输入：l1 = [9,9,9,9,9,9,9], l2 = [9,9,9,9]
 * 输出：[8,9,9,9,0,0,0,1]
 * 提示：
 * 每个链表中的节点数在范围 [1, 100] 内
 * 0 <= Node.val <= 9
 * 题目数据保证列表表示的数字不含前导零
 */
public class LC2_add_two_numbers {

    public class ListNode {

        int val;
        ListNode next;

        ListNode() {}

        ListNode(int val) { this.val = val; }

        ListNode(int val, ListNode next) { this.val = val; this.next = next; }
    }

    public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
        boolean needAdd = false;
        ListNode start = new ListNode();
        ListNode cur = start;
        int curVal = 0;
        while (true) {
            int cur1 = 0;
            if (l1 != null) {
                cur1 = l1.val;
            }

            int cur2 = 0;
            if (l2 != null) {
                cur2 = l2.val;
            }
            curVal = cur1 + cur2 + (needAdd ? 1 : 0);
            if (curVal > 9) {
                curVal = curVal - 10;
                needAdd = true;
            } else {
                needAdd = false;
            }
            cur.val = curVal;
            if ((l1 == null || l1.next == null) && (l2 == null || l2.next == null) && !needAdd) {
                break;
            }
            if (l1 != null) {
                l1 = l1.next;
            }
            if (l2 != null) {
                l2 = l2.next;
            }
            cur.next = new ListNode();
            cur = cur.next;
        }
        return start;
    }
}
