package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/9/12
 * 中位数是有序整数列表中的中间值。如果列表的大小是偶数，则没有中间值，中位数是两个中间值的平均值。
 * 例如 arr = [2,3,4] 的中位数是 3 。
 * 例如 arr = [2,3] 的中位数是 (2 + 3) / 2 = 2.5 。
 * 实现 MedianFinder 类:
 * MedianFinder() 初始化 MedianFinder 对象。
 * void addNum(int num) 将数据流中的整数 num 添加到数据结构中。
 * double findMedian() 返回到目前为止所有元素的中位数。与实际答案相差 10-5 以内的答案将被接受。
 * 示例 1：
 * 输入
 * ["MedianFinder", "addNum", "addNum", "findMedian", "addNum", "findMedian"]
 * [[], [1], [2], [], [3], []]
 * 输出
 * [null, null, null, 1.5, null, 2.0]
 * 解释
 * MedianFinder medianFinder = new MedianFinder();
 * medianFinder.addNum(1);    // arr = [1]
 * medianFinder.addNum(2);    // arr = [1, 2]
 * medianFinder.findMedian(); // 返回 1.5 ((1 + 2) / 2)
 * medianFinder.addNum(3);    // arr[1, 2, 3]
 * medianFinder.findMedian(); // return 2.0
 * 提示:
 * -105 <= num <= 105
 * 在调用 findMedian 之前，数据结构中至少有一个元素
 * 最多 5 * 104 次调用 addNum 和 findMedian
 */
public class LC295_find_median_from_data_stream {

    public static void main(String[] args) {
        MedianFinder medianFinder = new LC295_find_median_from_data_stream().new MedianFinder();
        medianFinder.addNum(3);
        medianFinder.addNum(2);
        medianFinder.addNum(1);
        double median = medianFinder.findMedian();
        int i = 1;
    }

    /**
     * Your MedianFinder object will be instantiated and called as such:
     * MedianFinder obj = new MedianFinder();
     * obj.addNum(num);
     * double param_2 = obj.findMedian();
     */
    class MedianFinder {

        List<Integer> list = new ArrayList<>(20002);

        public MedianFinder() {

        }

        public void addNum(int num) {
            if (list.isEmpty()) {
                list.add(num);
                return;
            }
            if (num <= list.get(0)) {
                list.add(0, num);
                return;
            }
            if (num >= list.get(list.size() - 1)) {
                list.add(list.size(), num);
                return;
            }
            list.add(getIndex(0, list.size() - 1, num), num);
        }

        private int getIndex(int begin, int end, int num) {
            if (begin + 1 == end) {
                return end;
            }
            int mid = (begin + end) / 2;
            int midVal = list.get(mid);
            if (midVal == num) {
                return mid;
            }
            int beginVal = list.get(begin);
            int endVal = list.get(end);
            if (midVal < num) {
                return getIndex(mid, end, num);
            } else {
                return getIndex(begin, mid, num);
            }
        }

        public double findMedian() {
            int size = list.size();
            if (size % 2 == 0) {
                return (list.get(size / 2) + list.get(size / 2 - 1)) / 2d;
            } else {
                return list.get(size / 2);
            }
        }
    }

}
