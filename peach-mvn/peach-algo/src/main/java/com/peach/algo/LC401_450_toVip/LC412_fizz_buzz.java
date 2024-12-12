package com.peach.algo.LC401_450_toVip;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/10/24
 * 给你一个整数 n ，找出从 1 到 n 各个整数的 Fizz Buzz 表示，并用字符串数组 answer（下标从 1 开始）返回结果，其中：
 * answer[i] == "FizzBuzz" 如果 i 同时是 3 和 5 的倍数。
 * answer[i] == "Fizz" 如果 i 是 3 的倍数。
 * answer[i] == "Buzz" 如果 i 是 5 的倍数。
 * answer[i] == i （以字符串形式）如果上述条件全不满足。
 * 示例 1：
 * 输入：n = 3
 * 输出：["1","2","Fizz"]
 * 示例 2：
 * 输入：n = 5
 * 输出：["1","2","Fizz","4","Buzz"]
 * 示例 3：
 * 输入：n = 15
 * 输出：["1","2","Fizz","4","Buzz","Fizz","7","8","Fizz","Buzz","11","Fizz","13","14","FizzBuzz"]
 * 提示：
 * 1 <= n <= 104
 */
public class LC412_fizz_buzz {

    public List<String> fizzBuzz(int n) {
        List<String> result = new ArrayList<>();
        int[] array = new int[n + 1];
        for (int i = 1; i <= n; i++) {
            result.add(get(i, array[i]));
            if (i * 3 <= n) {
                array[i * 3] += 3;
            }
            if (i * 5 <= n) {
                array[i * 5] += 5;
            }
        }
        return result;
    }

    private String get(int i, int num) {
        if (num == 3) {
            return "Fizz";
        } else if (num == 5) {
            return "Buzz";
        } else if (num == 8) {
            return "FizzBuzz";
        }
        return String.valueOf(i);
    }

}
