package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/1/17
 * 以字符串的形式给出 n , 以字符串的形式返回 n 的最小 好进制  。
 * 如果 n 的  k(k>=2) 进制数的所有数位全为1，则称 k(k>=2) 是 n 的一个 好进制 。
 * 示例 1：
 * 输入：n = "13"
 * 输出："3"
 * 解释：13 的 3 进制是 111。
 * 示例 2：
 * 输入：n = "4681"
 * 输出："8"
 * 解释：4681 的 8 进制是 11111。
 * 示例 3：
 * 输入：n = "1000000000000000000"
 * 输出："999999999999999999"
 * 解释：1000000000000000000 的 999999999999999999 进制是 11。
 * 提示：
 * n 的取值范围是 [3, 1018]
 * n 没有前导 0
 */
public class LC483_smallest_good_base {

    /**
     * X = 1 + n + n2 + n3  + ^ + na
     * nX = n + n2 + n3 + ^ + na+1
     * (n-1)X + 1 = n^(a+1)
     * X = (n^(a+1) - 1)/(n-1)
     * 我是傻逼
     */
    public String smallestGoodBase(String n) {
        long nVal = Long.parseLong(n);
        int mMax = (int) Math.floor(Math.log(nVal) / Math.log(2));
        for (int m = mMax; m > 1; m--) {
            int k = (int) Math.pow(nVal, 1.0 / m);
            long mul = 1, sum = 1;
            for (int i = 0; i < m; i++) {
                mul *= k;
                sum += mul;
            }
            if (sum == nVal) {
                return Integer.toString(k);
            }
        }
        return Long.toString(nVal - 1);
    }

}
