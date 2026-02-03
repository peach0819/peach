package com.peach.algo;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Random;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2026/2/2
 * 给定一个整数 n 和一个 无重复 黑名单整数数组 blacklist 。设计一种算法，从 [0, n - 1] 范围内的任意整数中选取一个 未加入 黑名单 blacklist 的整数。任何在上述范围内且不在黑名单 blacklist 中的整数都应该有 同等的可能性 被返回。
 * 优化你的算法，使它最小化调用语言 内置 随机函数的次数。
 * 实现 Solution 类:
 * Solution(int n, int[] blacklist) 初始化整数 n 和被加入黑名单 blacklist 的整数
 * int pick() 返回一个范围为 [0, n - 1] 且不在黑名单 blacklist 中的随机整数
 * 示例 1：
 * 输入
 * ["Solution", "pick", "pick", "pick", "pick", "pick", "pick", "pick"]
 * [[7, [2, 3, 5]], [], [], [], [], [], [], []]
 * 输出
 * [null, 0, 4, 1, 6, 1, 0, 4]
 * 解释
 * Solution solution = new Solution(7, [2, 3, 5]);
 * solution.pick(); // 返回0，任何[0,1,4,6]的整数都可以。注意，对于每一个pick的调用，
 * // 0、1、4和6的返回概率必须相等(即概率为1/4)。
 * solution.pick(); // 返回 4
 * solution.pick(); // 返回 1
 * solution.pick(); // 返回 6
 * solution.pick(); // 返回 1
 * solution.pick(); // 返回 0
 * solution.pick(); // 返回 4
 * 提示:
 * 1 <= n <= 109
 * 0 <= blacklist.length <= min(105, n - 1)
 * 0 <= blacklist[i] < n
 * blacklist 中所有值都 不同
 * pick 最多被调用 2 * 104 次
 */
public class LC710_random_pick_with_blacklist {

    /**
     * Your Solution object will be instantiated and called as such:
     * Solution obj = new Solution(n, blacklist);
     * int param_1 = obj.pick();
     */
    class Solution {

        int n;
        int[] blacklist;
        Random random = new Random();

        Map<Integer, Integer> replaceMap = new HashMap<>();

        public Solution(int n, int[] blacklist) {
            this.n = n;
            this.blacklist = blacklist;

            // 创建一个黑名单的set
            Set<Integer> set = new HashSet<>();
            for (int i : blacklist) {
                set.add(i);
            }

            int last = n - blacklist.length - 1;
            int index = 1;
            for (int i = 0; i < blacklist.length; i++) {
                int cur = blacklist[i];
                if (cur > last) {
                    continue;
                }
                while (set.contains(last + index)) {
                    index++;
                }
                replaceMap.put(blacklist[i], last + index);
                index++;
            }
        }

        public int pick() {
            int i = random.nextInt(n - blacklist.length);
            if (replaceMap.containsKey(i)) {
                return replaceMap.get(i);
            }
            return i;
        }

    }

}
