package com.peach.algo.LC151_200_toVip;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2024/8/9
 * 给定一组非负整数 nums，重新排列每个数的顺序（每个数不可拆分）使之组成一个最大的整数。
 * 注意：输出结果可能非常大，所以你需要返回一个字符串而不是整数。
 * 示例 1：
 * 输入：nums = [10,2]
 * 输出："210"
 * 示例 2：
 * 输入：nums = [3,30,34,5,9]
 * 输出："9534330"
 * 提示：
 * 1 <= nums.length <= 100
 * 0 <= nums[i] <= 109
 */
public class LC179_largest_number {

    /**
     * 我是傻逼
     */
    public String largestNumber(int[] nums) {
        int n = nums.length;
        String[] ss = new String[n];
        for (int i = 0; i < n; i++) {
            ss[i] = "" + nums[i];
        }
        Arrays.sort(ss, (a, b) -> {
            String sa = a + b, sb = b + a;
            return sb.compareTo(sa);
        });

        StringBuilder sb = new StringBuilder();
        for (String s : ss) {
            sb.append(s);
        }
        int len = sb.length();
        int k = 0;
        while (k < len - 1 && sb.charAt(k) == '0') {
            k++;
        }
        return sb.substring(k);
    }

}
