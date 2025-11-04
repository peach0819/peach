package com.peach.algo;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2025/11/4
 * 房间中有 n 只已经打开的灯泡，编号从 1 到 n 。墙上挂着 4 个开关 。
 * 这 4 个开关各自都具有不同的功能，其中：
 * 开关 1 ：反转当前所有灯的状态（即开变为关，关变为开）
 * 开关 2 ：反转编号为偶数的灯的状态（即 0, 2, 4, ...）
 * 开关 3 ：反转编号为奇数的灯的状态（即 1, 3, ...）
 * 开关 4 ：反转编号为 j = 3k + 1 的灯的状态，其中 k = 0, 1, 2, ...（即 1, 4, 7, 10, ...）
 * 你必须 恰好 按压开关 presses 次。每次按压，你都需要从 4 个开关中选出一个来执行按压操作。
 * 给你两个整数 n 和 presses ，执行完所有按压之后，返回 不同可能状态 的数量。
 * 示例 1：
 * 输入：n = 1, presses = 1
 * 输出：2
 * 解释：状态可以是：
 * - 按压开关 1 ，[关]
 * - 按压开关 2 ，[开]
 * 示例 2：
 * 输入：n = 2, presses = 1
 * 输出：3
 * 解释：状态可以是：
 * - 按压开关 1 ，[关, 关]
 * - 按压开关 2 ，[开, 关]
 * - 按压开关 3 ，[关, 开]
 * 示例 3：
 * 输入：n = 3, presses = 1
 * 输出：4
 * 解释：状态可以是：
 * - 按压开关 1 ，[关, 关, 关]
 * - 按压开关 2 ，[关, 开, 关]
 * - 按压开关 3 ，[开, 关, 开]
 * - 按压开关 4 ，[关, 开, 开]
 * 提示：
 * 1 <= n <= 1000
 * 0 <= presses <= 1000
 */
public class LC672_bulb_switcher_ii {

    public static void main(String[] args) {
        System.out.println(new LC672_bulb_switcher_ii().flipLights(3, 1));
    }

    //编号为 6k+1，受按钮 1,3,4 影响；
    //编号为 6k+2,6k+6，受按钮 1,2 影响；
    //编号为 6k+3,6k+5，受按钮 1,3 影响；
    //编号为 6k+4，受按钮 1,2,4 影响。
    public int flipLights(int n, int presses) {
        Set<Integer> seen = new HashSet<Integer>();
        for (int i = 0; i < 1 << 4; i++) {
            int[] pressArr = new int[4];
            for (int j = 0; j < 4; j++) {
                pressArr[j] = (i >> j) & 1;
            }
            int sum = Arrays.stream(pressArr).sum();
            if (sum % 2 == presses % 2 && sum <= presses) {
                int status = pressArr[0] ^ pressArr[2] ^ pressArr[3];
                if (n >= 2) {
                    status |= (pressArr[0] ^ pressArr[1]) << 1;
                }
                if (n >= 3) {
                    status |= (pressArr[0] ^ pressArr[2]) << 2;
                }
                if (n >= 4) {
                    status |= (pressArr[0] ^ pressArr[1] ^ pressArr[3]) << 3;
                }
                seen.add(status);
            }
        }
        return seen.size();
    }


    //public int flipLights(int n, int presses) {
    //    if (presses == 0) {
    //        return 1;
    //    }
    //    if (n == 1) {
    //        return 2;
    //    }
    //    if (n == 2) {
    //        if (presses == 1) {
    //            return 3;
    //        }
    //        return 4;
    //    }
    //    Set<Integer> result = new HashSet<>();
    //    int begin = 0b0000;
    //    for (int i = 0; i <= presses; i++) {
    //        int cur = i % 2 == 1 ? begin + 0b1000 : begin;
    //        for (int j = 0; j <= presses - i; j++) {
    //            int cur2 = j % 2 == 1 ? cur + 0b0100 : cur;
    //            for (int k = 0; k <= presses - i - j; k++) {
    //                int cur3 = k % 2 == 1 ? cur2 + 0b0010 : cur2;
    //                int l = presses - i - j - k;
    //                int cur4 = l % 2 == 1 ? cur3 + 0b0001 : cur3;
    //                result.add(cur4);
    //            }
    //        }
    //    }
    //    Set<String> strSet = new HashSet<>();
    //    for (int i : result) {
    //        strSet.add(build(n, i));
    //    }
    //    return strSet.size();
    //}
    //
    //private String build(int n, int num) {
    //    char[] array = new char[6];
    //    boolean flag1 = ((num >> 3) & 1) == 1;
    //    boolean flag2 = ((num >> 2) & 1) == 1;
    //    boolean flag3 = ((num >> 1) & 1) == 1;
    //    boolean flag4 = (num & 1) == 1;
    //    for (int i = 0; i < 6; i++) {
    //        int index = i + 1;
    //        boolean flag = true;
    //        if (flag1) {
    //            flag = !flag;
    //        }
    //        if (flag2 && index % 2 == 0) {
    //            flag = !flag;
    //        }
    //        if (flag3 && index % 2 == 1) {
    //            flag = !flag;
    //        }
    //        if (flag4 && index % 3 == 1) {
    //            flag = !flag;
    //        }
    //        array[i] = flag ? '1' : '0';
    //    }
    //    return new String(array);
    //}
}
