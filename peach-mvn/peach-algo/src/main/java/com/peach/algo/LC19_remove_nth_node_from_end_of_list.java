package com.peach.algo;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/7/2
 * 给你一个链表，删除链表的倒数第 n 个结点，并且返回链表的头结点。
 * 示例 1：
 * 输入：head = [1,2,3,4,5], n = 2
 * 输出：[1,2,3,5]
 * 示例 2：
 * 输入：head = [1], n = 1
 * 输出：[]
 * 示例 3：
 * 输入：head = [1,2], n = 1
 * 输出：[1]
 * 提示：
 * 链表中结点的数目为 sz
 * 1 <= sz <= 30
 * 0 <= Node.val <= 100
 * 1 <= n <= sz
 * 进阶：你能尝试使用一趟扫描实现吗？
 */
public class LC19_remove_nth_node_from_end_of_list {

    public class ListNode {

        int val;
        ListNode next;

        ListNode() {}

        ListNode(int val) { this.val = val; }

        ListNode(int val, ListNode next) { this.val = val; this.next = next; }
    }

    /**
     * 官方题解用的是快慢指针
     */
    public ListNode removeNthFromEnd(ListNode head, int n) {
        Map<Integer, ListNode> map = new HashMap<>();
        ListNode cur = head;
        int index = 1;
        while (true) {
            map.put(index, cur);
            if (cur.next != null) {
                cur = cur.next;
                index++;
            } else {
                break;
            }
        }
        if (index == 1) {
            return null;
        }
        n = index + 1 - n;
        if (n == index) {
            map.get(n - 1).next = null;
            return map.get(1);
        } else if (n == 1) {
            return map.get(2);
        } else {
            map.get(n - 1).next = map.get(n + 1);
            return map.get(1);
        }
    }
}
