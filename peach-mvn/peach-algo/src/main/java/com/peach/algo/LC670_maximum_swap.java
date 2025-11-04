package com.peach.algo;

import java.util.PriorityQueue;

/**
 * @author feitao.zt
 * @date 2025/11/3
 * 给定一个非负整数，你至多可以交换一次数字中的任意两位。返回你能得到的最大值。
 * 示例 1 :
 * 输入: 2736
 * 输出: 7236
 * 解释: 交换数字2和数字7。
 * 示例 2 :
 * 输入: 9973
 * 输出: 9973
 * 解释: 不需要交换。
 * 注意:
 * 给定数字的范围是 [0, 108]
 */
public class LC670_maximum_swap {

    public static void main(String[] args) {
        System.out.println(new LC670_maximum_swap().maximumSwap(9973));
    }

    public int maximumSwap(int num) {
        char[] array = String.valueOf(num).toCharArray();
        boolean[] has = new boolean[array.length];
        //int[2] 0：数字 1：索引
        PriorityQueue<int[]> queue = new PriorityQueue<>((a, b) -> {
            if (a[0] == b[0]) {
                return b[1] - a[1];
            }
            return b[0] - a[0];
        });

        for (int i = 0; i < array.length; i++) {
            queue.offer(new int[]{ array[i] - '0', i });
        }
        for (int i = 0; i < array.length; i++) {
            int[] peek = queue.peek();
            while (has[peek[1]]) {
                queue.poll();
                peek = queue.peek();
            }
            if (peek[0] == (array[i] - '0')) {
                has[i] = true;
                continue;
            }
            int[] poll = queue.poll();
            int replaceIndex = poll[1];
            array[replaceIndex] = array[i];
            array[i] = (char) (poll[0] + '0');
            break;
        }
        return Integer.parseInt(new String(array));
    }
}
