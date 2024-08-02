package com.peach.algo;

import com.peach.algo.base.ListNode;

/**
 * @author feitao.zt
 * @date 2024/8/2
 * 给你链表的头结点 head ，请将其按 升序 排列并返回 排序后的链表 。
 * 示例 1：
 * 输入：head = [4,2,1,3]
 * 输出：[1,2,3,4]
 * 示例 2：
 * 输入：head = [-1,5,3,4,0]
 * 输出：[-1,0,3,4,5]
 * 示例 3：
 * 输入：head = []
 * 输出：[]
 * 提示：
 * 链表中节点的数目在范围 [0, 5 * 104] 内
 * -105 <= Node.val <= 105
 * 进阶：你可以在 O(n log n) 时间复杂度和常数级空间复杂度下，对链表进行排序吗？
 */
public class LC148_sort_list {

    /**
     * 官方用归并排序
     */
    public ListNode sortList1(ListNode head) {
        if (head == null || head.next == null) {
            return head;
        }
        ListNode fast = head.next;
        ListNode slow = head;
        while (fast != null && fast.next != null) {
            slow = slow.next;
            fast = fast.next.next;
        }
        ListNode tmp = slow.next;
        slow.next = null;
        ListNode left = sortList(head);
        ListNode right = sortList(tmp);
        ListNode h = new ListNode(0);
        ListNode res = h;
        while (left != null && right != null) {
            if (left.val < right.val) {
                h.next = left;
                left = left.next;
            } else {
                h.next = right;
                right = right.next;
            }
            h = h.next;
        }
        h.next = left != null ? left : right;
        return res.next;
    }

    // 主函数，调用快速排序函数
    public ListNode sortList(ListNode head) {
        return quickSort(head, null);
    }

    // 快速排序函数，递归实现
    private ListNode quickSort(ListNode head, ListNode tail) {
        // 基本情况：如果链表为空，只有一个节点，或者已经到达尾节点，则返回头节点
        if (head == null || head.next == null || head == tail) {
            return head;
        }

        boolean sorted = true; // 标记链表是否已经排序
        ListNode pivot = head; // 选择头节点作为枢轴
        ListNode curr = head.next, prev = head; // 初始化当前节点和前一个节点

        // 遍历链表，进行分区操作
        while (curr != null && curr != tail) {
            ListNode next = curr.next; // 保存当前节点的下一个节点

            if (curr.val < pivot.val) { // 如果当前节点的值小于枢轴值
                sorted = false; // 标记链表未排序
                prev.next = next; // 将当前节点从链表中摘除
                curr.next = head; // 将当前节点插入到头部
                head = curr; // 更新头节点
            } else {
                if (curr.val < prev.val) { // 如果当前节点的值小于前一个节点的值
                    sorted = false; // 标记链表未排序
                }
                prev = curr; // 更新前一个节点
            }
            curr = next; // 继续处理下一个节点
        }

        if (sorted) { // 如果链表已经排序，直接返回头节点
            return head;
        }

        // 递归排序枢轴右侧的链表
        pivot.next = quickSort(pivot.next, tail);
        // 递归排序枢轴左侧的链表
        return quickSort(head, pivot);
    }

}
