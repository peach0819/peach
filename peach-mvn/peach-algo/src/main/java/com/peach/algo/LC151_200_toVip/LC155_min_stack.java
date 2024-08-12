package com.peach.algo.LC151_200_toVip;

/**
 * @author feitao.zt
 * @date 2023/7/10
 * 设计一个支持 push ，pop ，top 操作，并能在常数时间内检索到最小元素的栈。
 * 实现 MinStack 类:
 * MinStack() 初始化堆栈对象。
 * void push(int val) 将元素val推入堆栈。
 * void pop() 删除堆栈顶部的元素。
 * int top() 获取堆栈顶部的元素。
 * int getMin() 获取堆栈中的最小元素。
 *  
 * 示例 1:
 * 输入：
 * ["MinStack","push","push","push","getMin","pop","top","getMin"]
 * [[],[-2],[0],[-3],[],[],[],[]]
 * 输出：
 * [null,null,null,null,-3,null,0,-2]
 * 解释：
 * MinStack minStack = new MinStack();
 * minStack.push(-2);
 * minStack.push(0);
 * minStack.push(-3);
 * minStack.getMin();   --> 返回 -3.
 * minStack.pop();
 * minStack.top();      --> 返回 0.
 * minStack.getMin();   --> 返回 -2.
 *  
 * 提示：
 * -231 <= val <= 231 - 1
 * pop、top 和 getMin 操作总是在 非空栈 上调用
 * push, pop, top, and getMin最多被调用 3 * 104 次
 * 来源：力扣（LeetCode）
 * 链接：https://leetcode.cn/problems/min-stack
 * 著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
 */
public class LC155_min_stack {

    /**
     * Your MinStack object will be instantiated and called as such:
     * MinStack obj = new MinStack();
     * obj.push(val);
     * obj.pop();
     * int param_3 = obj.top();
     * int param_4 = obj.getMin();
     */
    class MinStack {

        private Node cur;

        class Node {

            int cur;
            int min;
            Node last;
        }

        public void push(int val) {
            if (cur == null) {
                cur = new Node();
                cur.cur = val;
                cur.min = val;
            } else {
                Node node = new Node();
                node.cur = val;
                node.min = Math.min(val, cur.min);
                node.last = cur;
                cur = node;
            }
        }

        public void pop() {
            cur = cur.last;
        }

        public int top() {
            return cur.cur;
        }

        public int getMin() {
            return cur.min;
        }
    }

}


