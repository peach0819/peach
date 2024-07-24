package com.peach.algo.LC51_100;

/**
 * @author feitao.zt
 * @date 2024/7/18
 * 给定一个已排序的链表的头 head ， 删除所有重复的元素，使每个元素只出现一次 。返回 已排序的链表 。
 * 示例 1：
 * 输入：head = [1,1,2]
 * 输出：[1,2]
 * 示例 2：
 * 输入：head = [1,1,2,3,3]
 * 输出：[1,2,3]
 * 提示：
 * 链表中节点数目在范围 [0, 300] 内
 * -100 <= Node.val <= 100
 * 题目数据保证链表已经按升序 排列
 */
public class LC83_remove_duplicates_from_sorted_list {

    public class ListNode {

        int val;
        ListNode next;

        ListNode() {}

        ListNode(int val) { this.val = val; }

        ListNode(int val, ListNode next) { this.val = val; this.next = next; }
    }

    public ListNode deleteDuplicates(ListNode head) {
        if (head == null) {
            return null;
        }
        ListNode begin = head;
        ListNode cur = head;
        int val = head.val;
        boolean need = false;
        while (cur.next != null) {
            cur = cur.next;
            if (cur.val != val) {
                if (need) {
                    begin.next = cur;
                }
                begin = cur;
                need = false;
                val = cur.val;
            } else {
                need = true;
            }
        }
        begin.next = null;
        return head;
    }

}
