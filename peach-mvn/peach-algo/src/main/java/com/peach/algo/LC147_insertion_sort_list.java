package com.peach.algo;

import com.peach.algo.base.ListNode;

/**
 * @author feitao.zt
 * @date 2024/8/2
 * 给定单个链表的头 head ，使用 插入排序 对链表进行排序，并返回 排序后链表的头 。
 * 插入排序 算法的步骤:
 * 插入排序是迭代的，每次只移动一个元素，直到所有元素可以形成一个有序的输出列表。
 * 每次迭代中，插入排序只从输入数据中移除一个待排序的元素，找到它在序列中适当的位置，并将其插入。
 * 重复直到所有输入数据插入完为止。
 * 下面是插入排序算法的一个图形示例。部分排序的列表(黑色)最初只包含列表中的第一个元素。每次迭代时，从输入数据中删除一个元素(红色)，并就地插入已排序的列表中。
 * 对链表进行插入排序。
 * 示例 1：
 * 输入: head = [4,2,1,3]
 * 输出: [1,2,3,4]
 * 示例 2：
 * 输入: head = [-1,5,3,4,0]
 * 输出: [-1,0,3,4,5]
 * 提示：
 * 列表中的节点数在 [1, 5000]范围内
 * -5000 <= Node.val <= 5000
 */
public class LC147_insertion_sort_list {

    public ListNode insertionSortList(ListNode head) {
        if (head == null) {
            return null;
        }
        ListNode node = new ListNode(head.val);
        ListNode pre = new ListNode(-10000);
        pre.next = node;

        ListNode oldCur = head.next;
        ListNode newCur;

        ListNode node1;
        ListNode newLast = null;
        while (oldCur != null) {
            newCur = pre;
            if (newLast != null && oldCur.val > newLast.val) {
                newLast.next = new ListNode(oldCur.val);
                newLast = newLast.next;
            } else {
                while (true) {
                    if (newCur.next == null) {
                        newCur.next = new ListNode(oldCur.val);
                        newLast = newCur.next;
                        break;
                    }
                    if (oldCur.val <= newCur.next.val) {
                        node1 = new ListNode(oldCur.val);
                        node1.next = newCur.next;
                        newCur.next = node1;
                        break;
                    }
                    newCur = newCur.next;
                }
            }
            oldCur = oldCur.next;
        }
        return pre.next;
    }
}
