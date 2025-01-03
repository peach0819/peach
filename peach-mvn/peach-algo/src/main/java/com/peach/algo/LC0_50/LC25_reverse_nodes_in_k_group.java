package com.peach.algo.LC0_50;

import com.peach.algo.base.ListNode;

/**
 * @author feitao.zt
 * @date 2024/7/3
 * 给你链表的头节点 head ，每 k 个节点一组进行翻转，请你返回修改后的链表。
 * k 是一个正整数，它的值小于或等于链表的长度。如果节点总数不是 k 的整数倍，那么请将最后剩余的节点保持原有顺序。
 * 你不能只是单纯的改变节点内部的值，而是需要实际进行节点交换。
 * 示例 1：
 * 输入：head = [1,2,3,4,5], k = 2
 * 输出：[2,1,4,3,5]
 * 示例 2：
 * 输入：head = [1,2,3,4,5], k = 3
 * 输出：[3,2,1,4,5]
 * 提示：
 * 链表中的节点数目为 n
 * 1 <= k <= n <= 5000
 * 0 <= Node.val <= 1000
 * 进阶：你可以设计一个只用 O(1) 额外内存空间的算法解决此问题吗？
 */
public class LC25_reverse_nodes_in_k_group {

    public ListNode reverseKGroup(ListNode head, int k) {
        if (k == 1) {
            return head;
        }
        ListNode pre = new ListNode(0, head);
        ListNode index = pre;
        ListNode[] arrays;
        while (true) {
            arrays = new ListNode[k];
            ListNode begin = index;
            boolean enough = true;
            for (int i = 0; i < k; i++) {
                if (begin.next != null) {
                    arrays[i] = begin.next;
                    begin = begin.next;
                } else {
                    enough = false;
                    break;
                }
            }
            if (!enough) {
                break;
            }

            for (int i = 0; i < k; i++) {
                if (i == 0) {
                    arrays[i].next = arrays[k - 1].next;
                } else {
                    arrays[i].next = arrays[i - 1];
                }
            }
            index.next = arrays[k - 1];
            index = arrays[0];
        }
        return pre.next;
    }
}
