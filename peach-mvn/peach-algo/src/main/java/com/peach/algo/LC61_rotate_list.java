package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/15
 * 给你一个链表的头节点 head ，旋转链表，将链表每个节点向右移动 k 个位置。
 * 示例 1：
 * 输入：head = [1,2,3,4,5], k = 2
 * 输出：[4,5,1,2,3]
 * 示例 2：
 * 输入：head = [0,1,2], k = 4
 * 输出：[2,0,1]
 * 提示：
 * 链表中节点的数目在范围 [0, 500] 内
 * -100 <= Node.val <= 100
 * 0 <= k <= 2 * 109
 */
public class LC61_rotate_list {

    public static class ListNode {

        int val;
        ListNode next;

        ListNode() {}

        ListNode(int val) { this.val = val; }

        ListNode(int val, ListNode next) { this.val = val; this.next = next; }
    }

    public static void main(String[] args) {
        ListNode head = new ListNode(1);
        ListNode l2 = new ListNode(2);
        ListNode l3 = new ListNode(3);
        ListNode l4 = new ListNode(4);
        ListNode l5 = new ListNode(5);
        head.next = l2;
        l2.next = l3;
        l3.next = l4;
        l4.next = l5;
        new LC61_rotate_list().rotateRight(head, 2);
    }

    public ListNode rotateRight(ListNode head, int k) {
        if (head == null || k == 0) {
            return head;
        }
        int num = 1;
        ListNode cur = head;
        List<ListNode> list = new ArrayList<>();
        list.add(new ListNode());
        while (true) {
            list.add(cur);
            if (cur.next != null) {
                cur = cur.next;
                num++;
            } else {
                break;
            }
        }

        k = k % num;
        if (k == 0) {
            return head;
        }

        ListNode newLast = list.get(num - k);
        ListNode oldLast = list.get(num);
        newLast.next = null;
        oldLast.next = head;
        return list.get(num - k + 1);
    }
}
