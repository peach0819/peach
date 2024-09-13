package com.peach.algo.LC251_300_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/11
 * 你是产品经理，目前正在带领一个团队开发新的产品。不幸的是，你的产品的最新版本没有通过质量检测。由于每个版本都是基于之前的版本开发的，所以错误的版本之后的所有版本都是错的。
 * 假设你有 n 个版本 [1, 2, ..., n]，你想找出导致之后所有版本出错的第一个错误的版本。
 * 你可以通过调用 bool isBadVersion(version) 接口来判断版本号 version 是否在单元测试中出错。实现一个函数来查找第一个错误的版本。你应该尽量减少对调用 API 的次数。
 * 示例 1：
 * 输入：n = 5, bad = 4
 * 输出：4
 * 解释：
 * 调用 isBadVersion(3) -> false
 * 调用 isBadVersion(5) -> true
 * 调用 isBadVersion(4) -> true
 * 所以，4 是第一个错误的版本。
 * 示例 2：
 * 输入：n = 1, bad = 1
 * 输出：1
 * 提示：
 * 1 <= bad <= n <= 231 - 1
 */
public class LC278_first_bad_version {

    /* The isBadVersion API is defined in the parent class VersionControl.
      boolean isBadVersion(int version); */
    boolean isBadVersion(int version) {
        if (version >= 1702766719) {
            return true;
        }
        return false;
    }

    public static void main(String[] args) {
        int i = new LC278_first_bad_version().firstBadVersion(2126753390);
        i = 1;
    }

    public int firstBadVersion(int n) {
        return handle(1, n);
    }

    private int handle(int begin, int end) {
        if (begin + 1 == end || begin == end) {
            boolean beginVal = isBadVersion(begin);
            return beginVal ? begin : end;
        }
        int mid = begin + (end - begin) / 2;
        boolean midVal = isBadVersion(mid);
        if (midVal) {
            return handle(begin, mid);
        } else {
            return handle(mid, end);
        }
    }
}
