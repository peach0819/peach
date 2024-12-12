package com.peach.algo.LC401_450_toVip;

import com.peach.algo.base.ListNode;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/12/11
 * 给你两个 非空 链表来代表两个非负整数。数字最高位位于链表开始位置。它们的每个节点只存储一位数字。将这两数相加会返回一个新的链表。
 * 你可以假设除了数字 0 之外，这两个数字都不会以零开头。
 * 示例1：
 * 输入：l1 = [7,2,4,3], l2 = [5,6,4]
 * 输出：[7,8,0,7]
 * 示例2：
 * 输入：l1 = [2,4,3], l2 = [5,6,4]
 * 输出：[8,0,7]
 * 示例3：
 * 输入：l1 = [0], l2 = [0]
 * 输出：[0]
 * 提示：
 * 链表的长度范围为 [1, 100]
 * 0 <= node.val <= 9
 * 输入数据保证链表代表的数字无前导 0
 * 进阶：如果输入链表不能翻转该如何解决？
 */
public class LC445_add_two_numbers_ii {

    public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
        List<Integer> list1 = new ArrayList<>();
        List<Integer> list2 = new ArrayList<>();

        ListNode cur = l1;
        while (cur != null) {
            list1.add(cur.val);
            cur = cur.next;
        }

        cur = l2;
        while (cur != null) {
            list2.add(cur.val);
            cur = cur.next;
        }
        ListNode node = null;
        int i = list1.size() - 1;
        int j = list2.size() - 1;
        int addition = 0;
        int curVal = 0;
        while (i >= 0 || j >= 0 || addition != 0) {
            curVal = addition;
            if (i >= 0) {
                curVal += list1.get(i);
                i--;
            }
            if (j >= 0) {
                curVal += list2.get(j);
                j--;
            }
            ListNode newNode = new ListNode();
            newNode.val = curVal % 10;
            newNode.next = node;
            node = newNode;
            addition = curVal / 10;
        }
        return node;
    }
}
