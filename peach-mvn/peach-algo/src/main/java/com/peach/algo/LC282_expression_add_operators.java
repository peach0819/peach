package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/9/12
 * 给定一个仅包含数字 0-9 的字符串 num 和一个目标值整数 target ，在 num 的数字之间添加 二元 运算符（不是一元）+、- 或 * ，返回 所有 能够得到 target 的表达式。
 * 注意，返回表达式中的操作数 不应该 包含前导零。
 * 示例 1:
 * 输入: num = "123", target = 6
 * 输出: ["1+2+3", "1*2*3"]
 * 解释: “1*2*3” 和 “1+2+3” 的值都是6。
 * 示例 2:
 * 输入: num = "232", target = 8
 * 输出: ["2*3+2", "2+3*2"]
 * 解释: “2*3+2” 和 “2+3*2” 的值都是8。
 * 示例 3:
 * 输入: num = "3456237490", target = 9191
 * 输出: []
 * 解释: 表达式 “3456237490” 无法得到 9191 。
 * 提示：
 * 1 <= num.length <= 10
 * num 仅含数字
 * -231 <= target <= 231 - 1
 */
public class LC282_expression_add_operators {

    /**
     * 我是傻逼
     */
    public static List<String> addOperators(String num, int target) {
        List<String> ans = new ArrayList<>();
        if (target == Integer.MIN_VALUE) {
            return ans;
        }
        char[] nums = num.toCharArray();
        char[] assist = new char[nums.length * 2 - 1];

        /**
         * 第一部分的数可以选0~0,0~1,0~2...0~n-1
         */
        int cur = 0;
        int len = 0;
        for (int end = 0; end < nums.length; end++) {
            cur = cur * 10 + (nums[end] - '0');
            /**
             * 因为我们现在要算的是第一部分，第一部分前面没有符号
             */
            assist[len++] = nums[end];
            /**
             * 第一部分的值为cur，这里不考虑符号，暂时都按不确定的处理
             */
            //assist[len ++] = '+';
            process(nums, assist, ans, 0, cur, end + 1, len, target);
            /**
             * 我们不能把一个0留给下个数
             */
            if (cur == 0) {
                break;
            }
        }

        return ans;
    }

    /**
     * 递归处理的过程
     *
     * @param nums        原来的字符数组
     * @param assist      辅助数组（加完符号之后的数组）
     * @param ans         目前搜集到的答案
     * @param confirmed   当前所填的表达式能确定的位置的值（加号或者减号之前）
     * @param unconfirmed 当前所填的表达式不能确定的位置的值
     * @param index       当前来到了原数组的哪个位置
     * @param len         当前辅助数组的有效长度
     * @param target      题目要匹配的目标值
     */
    public static void process(char[] nums, char[] assist, List<String> ans, int confirmed, int unconfirmed, int index,
            int len, int target) {
        //已经尝试完了所有的字符
        if (index == nums.length) {
            /*
              如果按照前面我们填的操作符刚好能得到答案，这是一次有效的尝试，搜集答案
             */
            if (confirmed + unconfirmed == target) {
                ans.add(new String(assist).substring(0, len));
            }
            /**
             * 已经没有可以尝试的了，不管有没有得到答案都得返回
             */
            return;
        }

        /**
         * 如果原始的字符还没有用完，那我们当前字符前面可以填+ - *三种符号，而且必须填符号
         * 当我们填+ 或者-的时候，意味着已经确认的部分confirmed又可以把unconfirmed算进去了，unconfirmed变成我们要用的部分
         * 如果填的是*的话则confirmed不变，unconfirmed变成unconfirmed*当前要用的部分
         * 我们要用的部分是什么呢：可以是nums的index，也可以是nums的index到nums.length-1的任意一种连续的长度
         * 开头肯定是index位置，结尾我们这里用end表示
         */
        int cur = 0;
        int curIndex = len + 1;
        for (int end = index; end < nums.length; end++) {
            cur = cur * 10 + (nums[end] - '0');
            /**
             * assist的len是符号，之后是数字
             */
            assist[curIndex++] = nums[end];
            /**
             * 当前数之前可以是+ - *
             * 如果是+，则confirmed变成confirmed + unconfirmed
             * unconfirmed变成cur
             */
            assist[len] = '+';

            process(nums, assist, ans, confirmed + unconfirmed, cur, end + 1, len + (end - index + 2), target);
            /**
             * 如果当前数之前是-则confirmed变成confirmed + unconfirmed
             * unconfirmed变成-cur
             */
            assist[len] = '-';
            process(nums, assist, ans, confirmed + unconfirmed, -cur, end + 1, len + (end - index + 2), target);
            /**
             * 如果当前数之前是*则confirmed不变
             * unconfirmed变成unconfirmed * cur
             */
            assist[len] = '*';
            long curL = cur;
            if (unconfirmed * curL < Integer.MAX_VALUE) {
                process(nums, assist, ans, confirmed, unconfirmed * cur, end + 1, len + (end - index + 2), target);
            }

            /**
             * 如果cur等于0，说明出现了0开头的数，这个不是个正确的数字，本次尝试无效
             */
            if (cur == 0) {
                break;
            }
        }
    }
}
