package com.peach.algo.LC301_350_toVip;

import com.peach.algo.base.ListNode;

/**
 * @author feitao.zt
 * @date 2024/9/25
 * 给定单链表的头节点 head ，将所有索引为奇数的节点和索引为偶数的节点分别组合在一起，然后返回重新排序的列表。
 * 第一个节点的索引被认为是 奇数 ， 第二个节点的索引为 偶数 ，以此类推。
 * 请注意，偶数组和奇数组内部的相对顺序应该与输入时保持一致。
 * 你必须在 O(1) 的额外空间复杂度和 O(n) 的时间复杂度下解决这个问题。
 * 示例 1:
 * 输入: head = [1,2,3,4,5]
 * 输出: [1,3,5,2,4]
 * 示例 2:
 * 输入: head = [2,1,3,5,6,4,7]
 * 输出: [2,3,6,7,1,5,4]
 * 提示:
 * n ==  链表中的节点数
 * 0 <= n <= 104
 * -106 <= Node.val <= 106
 */
public class LC328_odd_even_linked_list {

    public ListNode oddEvenList(ListNode head) {
        if (head == null || head.next == null || head.next.next == null) {
            return head;
        }
        ListNode cur = head.next.next;

        ListNode oneHead = head;
        ListNode twoHead = head.next;

        ListNode one = oneHead;
        ListNode two = twoHead;

        boolean finish = false;
        while (true) {
            if (cur == null) {
                finish = true;
            } else {
                one.next = cur;
                one = one.next;
                if (cur.next == null) {
                    finish = true;
                } else {
                    two.next = cur.next;
                    two = two.next;
                }
            }

            if (finish) {
                one.next = twoHead;
                two.next = null;
                break;
            } else {
                cur = cur.next.next;
            }
        }
        return oneHead;
    }
}
