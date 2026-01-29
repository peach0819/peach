package com.peach.algo.LC651_700_toVip;

import java.util.ArrayDeque;
import java.util.HashSet;
import java.util.Queue;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2026/1/22
 * 我们有 n 种不同的贴纸。每个贴纸上都有一个小写的英文单词。
 * 您想要拼写出给定的字符串 target ，方法是从收集的贴纸中切割单个字母并重新排列它们。如果你愿意，你可以多次使用每个贴纸，每个贴纸的数量是无限的。
 * 返回你需要拼出 target 的最小贴纸数量。如果任务不可能，则返回 -1 。
 * 注意：在所有的测试用例中，所有的单词都是从 1000 个最常见的美国英语单词中随机选择的，并且 target 被选择为两个随机单词的连接。
 * 示例 1：
 * 输入： stickers = ["with","example","science"], target = "thehat"
 * 输出：3
 * 解释：
 * 我们可以使用 2 个 "with" 贴纸，和 1 个 "example" 贴纸。
 * 把贴纸上的字母剪下来并重新排列后，就可以形成目标 “thehat“ 了。
 * 此外，这是形成目标字符串所需的最小贴纸数量。
 * 示例 2:
 * 输入：stickers = ["notice","possible"], target = "basicbasic"
 * 输出：-1
 * 解释：我们不能通过剪切给定贴纸的字母来形成目标“basicbasic”。
 * 提示:
 * n == stickers.length
 * 1 <= n <= 50
 * 1 <= stickers[i].length <= 10
 * 1 <= target.length <= 15
 * stickers[i] 和 target 由小写英文单词组成
 */
public class LC691_stickers_to_spell_word {

    /**
     * 我是傻逼
     */
    public int minStickers(String[] stickers, String target) {
        int[][] sticker = new int[stickers.length][26];
        for (int i = 0; i < stickers.length; i++) {
            for (char c : stickers[i].toCharArray()) {
                sticker[i][c - 'a']++;
            }
        }
        Queue<String> queue = new ArrayDeque<>();
        Set<String> set = new HashSet<>();
        queue.offer(target);
        set.add(target);
        int res = 0;
        while (!queue.isEmpty()) {
            res++;
            int size = queue.size();
            while (size-- > 0) {
                String cur = queue.poll();
                int[] tar = new int[26];
                for (char c : cur.toCharArray()) {
                    tar[c - 'a']++;
                }
                for (int[] count : sticker) {
                    if (count[cur.charAt(0) - 'a'] == 0) {
                        continue;
                    }
                    StringBuilder sb = new StringBuilder();
                    for (int i = 0; i < 26; i++) {
                        if (tar[i] > 0) {
                            int remain = Math.max(tar[i] - count[i], 0);
                            for (int j = 0; j < remain; j++) {
                                sb.append((char) (i + 'a'));
                            }
                        }
                    }
                    if (sb.length() == 0) {
                        return res;
                    }
                    String str = new String(sb);
                    if (!set.contains(str)) {
                        set.add(str);
                        queue.offer(str);
                    }
                }
            }
        }
        return -1;
    }
}
