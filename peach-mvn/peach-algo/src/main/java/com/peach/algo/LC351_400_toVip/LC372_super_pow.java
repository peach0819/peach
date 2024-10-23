package com.peach.algo.LC351_400_toVip;

/**
 * @author feitao.zt
 * @date 2024/10/10
 * 你的任务是计算 ab 对 1337 取模，a 是一个正整数，b 是一个非常大的正整数且会以数组形式给出。
 * 示例 1：
 * 输入：a = 2, b = [3]
 * 输出：8
 * 示例 2：
 * 输入：a = 2, b = [1,0]
 * 输出：1024
 * 示例 3：
 * 输入：a = 1, b = [4,3,3,8,5,2]
 * 输出：1
 * 示例 4：
 * 输入：a = 2147483647, b = [2,0,0]
 * 输出：1198
 * 提示：
 * 1 <= a <= 231 - 1
 * 1 <= b.length <= 2000
 * 0 <= b[i] <= 9
 * b 不含前导 0
 */
public class LC372_super_pow {

    public int superPow(int a, int[] b) {
        //(a*b) % 1337 = ((a%1337) * (b%1337)) %1337
        a = a % 1337;
        return get(a, b, b.length - 1);
    }

    private int get(int a, int[] b, int index) {
        //a ^ b %1337= ((a ^ b/10)10 %1337 * a ^ b%10 % 1337)%1337
        if (index == 0) {
            return pow(a, b[0]);
        }
        return (pow(get(a, b, index - 1), 10) * pow(a, b[index])) % 1337;
    }

    private int pow(int a, int b) {
        a = a % 1337;
        int result = 1;
        while (b > 0) {
            result = result * a % 1337;
            b--;
        }
        return result;
    }
}
