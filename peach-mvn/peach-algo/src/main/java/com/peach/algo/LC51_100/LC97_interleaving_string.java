package com.peach.algo.LC51_100;

/**
 * @author feitao.zt
 * @date 2024/7/23
 * 给定三个字符串 s1、s2、s3，请你帮忙验证 s3 是否是由 s1 和 s2 交错 组成的。
 * 两个字符串 s 和 t 交错 的定义与过程如下，其中每个字符串都会被分割成若干 非空
 * 子字符串
 * ：
 * s = s1 + s2 + ... + sn
 * t = t1 + t2 + ... + tm
 * |n - m| <= 1
 * 交错 是 s1 + t1 + s2 + t2 + s3 + t3 + ... 或者 t1 + s1 + t2 + s2 + t3 + s3 + ...
 * 注意：a + b 意味着字符串 a 和 b 连接。
 * 示例 1：
 * 输入：s1 = "aabcc", s2 = "dbbca", s3 = "aadbbcbcac"
 * 输出：true
 * 示例 2：
 * 输入：s1 = "aabcc", s2 = "dbbca", s3 = "aadbbbaccc"
 * 输出：false
 * 示例 3：
 * 输入：s1 = "", s2 = "", s3 = ""
 * 输出：true
 * 提示：
 * 0 <= s1.length, s2.length <= 100
 * 0 <= s3.length <= 200
 * s1、s2、和 s3 都由小写英文字母组成
 * 进阶：您能否仅使用 O(s2.length) 额外的内存空间来解决它?
 */
public class LC97_interleaving_string {

    char[] char1;
    char[] char2;
    char[] char3;
    Boolean[][][] result;

    //官方题解是用动态规划做的，我是傻逼
    public boolean isInterleave(String s1, String s2, String s3) {
        if (s3.length() != (s1.length() + s2.length())) {
            return false;
        }
        char1 = s3.toCharArray();
        char2 = s2.toCharArray();
        char3 = s1.toCharArray();
        result = new Boolean[char1.length + 1][char2.length + 1][char3.length + 1];
        return handle(0, 0, 0);
    }

    private boolean handle(int begin1, int begin2, int begin3) {
        if (begin1 == char1.length) {
            return begin2 == char2.length && begin3 == char3.length;
        }
        if (result[begin1][begin2][begin3] != null) {
            return result[begin1][begin2][begin3];
        }
        char c1 = char1[begin1];
        boolean r = (begin2 < char2.length && char2[begin2] == c1 && handle(begin1 + 1, begin2 + 1, begin3))
                || (begin3 < char3.length && char3[begin3] == c1 && handle(begin1 + 1, begin2, begin3 + 1));
        result[begin1][begin2][begin3] = r;
        return r;
    }
}
