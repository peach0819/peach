package com.peach.algo.LC0_50;

import com.peach.algo.base.ListNode;

/**
 * @author feitao.zt
 * @date 2023/3/31
 * 将两个升序链表合并为一个新的 升序 链表并返回。新链表是通过拼接给定的两个链表的所有节点组成的。 
 *  
 * 示例 1：
 * 输入：l1 = [1,2,4], l2 = [1,3,4]
 * 输出：[1,1,2,3,4,4]
 * 示例 2：
 * 输入：l1 = [], l2 = []
 * 输出：[]
 * 示例 3：
 * 输入：l1 = [], l2 = [0]
 * 输出：[0]
 *  
 * 提示：
 * 两个链表的节点数目范围是 [0, 50]
 * -100 <= Node.val <= 100
 * l1 和 l2 均按 非递减顺序 排列
 * 来源：力扣（LeetCode）
 * 链接：https://leetcode.cn/problems/merge-two-sorted-lists
 * 著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
 */
public class LC21_merge_two_sorted_lists {

    public ListNode mergeTwoLists(ListNode list1, ListNode list2) {
        if (list1 == null && list2 == null) {
            return null;
        }
        ListNode resultNode = new ListNode();
        ListNode curNode = resultNode;
        boolean init = false;
        while (list1 != null || list2 != null) {
            if (!init) {
                init = true;
            } else {
                curNode.next = new ListNode();
                curNode = curNode.next;
            }
            if (list1 == null) {
                curNode.val = list2.val;
                list2 = list2.next;
            } else if (list2 == null) {
                curNode.val = list1.val;
                list1 = list1.next;
            } else {
                if (list1.val <= list2.val) {
                    curNode.val = list1.val;
                    list1 = list1.next;
                } else {
                    curNode.val = list2.val;
                    list2 = list2.next;
                }
            }
        }
        return resultNode;
    }
}
