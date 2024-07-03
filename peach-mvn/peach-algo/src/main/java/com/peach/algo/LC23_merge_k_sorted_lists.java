package com.peach.algo;

import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * @author feitao.zt
 * @date 2024/7/3
 * 给你一个链表数组，每个链表都已经按升序排列。
 * 请你将所有链表合并到一个升序链表中，返回合并后的链表。
 * 示例 1：
 * 输入：lists = [[1,4,5],[1,3,4],[2,6]]
 * 输出：[1,1,2,3,4,4,5,6]
 * 解释：链表数组如下：
 * [
 * 1->4->5,
 * 1->3->4,
 * 2->6
 * ]
 * 将它们合并到一个有序链表中得到。
 * 1->1->2->3->4->4->5->6
 * 示例 2：
 * 输入：lists = []
 * 输出：[]
 * 示例 3：
 * 输入：lists = [[]]
 * 输出：[]
 * 提示：
 * k == lists.length
 * 0 <= k <= 10^4
 * 0 <= lists[i].length <= 500
 * -10^4 <= lists[i][j] <= 10^4
 * lists[i] 按 升序 排列
 * lists[i].length 的总和不超过 10^4
 */
public class LC23_merge_k_sorted_lists {

    public class ListNode {

        int val;
        ListNode next;

        ListNode() {}

        ListNode(int val) { this.val = val; }

        ListNode(int val, ListNode next) { this.val = val; this.next = next; }
    }

    public ListNode mergeKLists(ListNode[] lists) {
        if (lists.length == 0) {
            return null;
        }
        Map<Integer, Integer> map = new HashMap<>();
        ListNode cur;
        for (ListNode list : lists) {
            cur = list;
            while (cur != null) {
                map.putIfAbsent(cur.val, 0);
                map.put(cur.val, map.get(cur.val) + 1);
                cur = cur.next;
            }
        }
        List<Integer> keys = map.keySet().stream().sorted(Comparator.comparing(Integer::valueOf))
                .collect(Collectors.toList());
        ListNode pre = new ListNode(0);
        ListNode index = pre;
        for (Integer key : keys) {
            Integer val = map.get(key);
            for (int i = 0; i < val; i++) {
                index.next = new ListNode(key);
                index = index.next;
            }
        }
        return pre.next;
    }
}
