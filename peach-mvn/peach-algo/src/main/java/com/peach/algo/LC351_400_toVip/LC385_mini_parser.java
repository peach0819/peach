package com.peach.algo.LC351_400_toVip;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Stack;

/**
 * @author feitao.zt
 * @date 2024/10/15
 * 给定一个字符串 s 表示一个整数嵌套列表，实现一个解析它的语法分析器并返回解析的结果 NestedInteger 。
 * 列表中的每个元素只可能是整数或整数嵌套列表
 * 示例 1：
 * 输入：s = "324",
 * 输出：324
 * 解释：你应该返回一个 NestedInteger 对象，其中只包含整数值 324。
 * 示例 2：
 * 输入：s = "[123,[456,[789]]]",
 * 输出：[123,[456,[789]]]
 * 解释：返回一个 NestedInteger 对象包含一个有两个元素的嵌套列表：
 * 1. 一个 integer 包含值 123
 * 2. 一个包含两个元素的嵌套列表：
 * i.  一个 integer 包含值 456
 * ii. 一个包含一个元素的嵌套列表
 * a. 一个 integer 包含值 789
 * 提示：
 * 1 <= s.length <= 5 * 104
 * s 由数字、方括号 "[]"、负号 '-' 、逗号 ','组成
 * 用例保证 s 是可解析的 NestedInteger
 * 输入中的所有值的范围是 [-106, 106]
 */
public class LC385_mini_parser {

    public class NestedInteger {

        Integer value;
        List<NestedInteger> list;

        NestedInteger() {}

        boolean isInteger() {
            return value != null;
        }

        Integer getInteger() {
            return value;
        }

        void setInteger(int value) {
            this.value = value;
        }

        void add(NestedInteger ni) {
            if (list == null) {
                list = new ArrayList<>();
            }
            list.add(ni);
        }

        List<NestedInteger> getList() {
            return list;
        }
    }

    public static void main(String[] args) {
        new LC385_mini_parser().deserialize("[123,[456,[789]]]");
    }

    char[] chars;
    Map<Integer, Integer> indexMap = new HashMap<>();

    public NestedInteger deserialize(String s) {
        this.chars = s.toCharArray();
        Stack<Integer> stack = new Stack<>();
        for (int i = 0; i < chars.length; i++) {
            if (chars[i] == '[') {
                stack.push(i);
            } else if (chars[i] == ']') {
                indexMap.put(stack.pop(), i);
            }
        }
        return handle(0, s.length() - 1);
    }

    private NestedInteger handle(int begin, int end) {
        NestedInteger result = new NestedInteger();
        if (chars[begin] == '[') {
            List<NestedInteger> list = handleList(begin, end);
            for (NestedInteger nestedInteger : list) {
                result.add(nestedInteger);
            }
        } else {
            result.setInteger(handleInt(begin, end));
        }
        return result;
    }

    private int handleInt(int begin, int end) {
        return Integer.parseInt(new String(chars, begin, end + 1 - begin));
    }

    private List<NestedInteger> handleList(int begin, int end) {
        int curBegin = begin + 1;
        int index = begin + 1;
        List<NestedInteger> result = new ArrayList<>();
        while (index < end) {
            if (chars[index] == ',') {
                result.add(handle(curBegin, index - 1));
                curBegin = index + 1;
                index++;
            } else if (chars[index] == '[') {
                Integer curLast = indexMap.get(index);
                result.add(handle(index, curLast));
                curBegin = curLast + 2;
                index = curLast + 2;
            } else {
                if (index == end - 1) {
                    result.add(handle(curBegin, index));
                }
                index++;
            }
        }
        return result;
    }
}
