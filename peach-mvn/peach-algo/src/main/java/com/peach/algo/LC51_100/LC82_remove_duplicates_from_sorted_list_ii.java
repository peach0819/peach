package com.peach.algo.LC51_100;

import com.peach.algo.base.ListNode;

/**
 * @author feitao.zt
 * @date 2024/7/18
 * 给定一个已排序的链表的头 head ， 删除原始链表中所有重复数字的节点，只留下不同的数字 。返回 已排序的链表 。
 * 示例 1：
 * 输入：head = [1,2,3,3,4,4,5]
 * 输出：[1,2,5]
 * 示例 2：
 * 输入：head = [1,1,1,2,3]
 * 输出：[2,3]
 * 提示：
 * 链表中节点数目在范围 [0, 300] 内
 * -100 <= Node.val <= 100
 * 题目数据保证链表已经按升序 排列
 */
public class LC82_remove_duplicates_from_sorted_list_ii {

    public ListNode deleteDuplicates(ListNode head) {
        if (head == null) {
            return null;
        }
        ListNode init = new ListNode(-101);
        init.next = head;

        ListNode pre = init;

        ListNode begin = head;

        ListNode cur = head;
        int val = head.val;
        boolean repeat = false;

        while (cur.next != null) {
            cur = cur.next;
            if (cur.val != val) {
                if (!repeat) {
                    pre.next = begin;
                    pre = begin;
                }

                begin = cur;
                val = cur.val;
                repeat = false;
            } else {
                repeat = true;
            }
        }
        if (!repeat) {
            pre.next = begin;
        } else {
            pre.next = null;
        }
        return init.next;
    }
}
