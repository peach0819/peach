package com.peach.algo.LC401_450_toVip;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/12/6
 * 基因序列可以表示为一条由 8 个字符组成的字符串，其中每个字符都是 'A'、'C'、'G' 和 'T' 之一。
 * 假设我们需要调查从基因序列 start 变为 end 所发生的基因变化。一次基因变化就意味着这个基因序列中的一个字符发生了变化。
 * 例如，"AACCGGTT" --> "AACCGGTA" 就是一次基因变化。
 * 另有一个基因库 bank 记录了所有有效的基因变化，只有基因库中的基因才是有效的基因序列。（变化后的基因必须位于基因库 bank 中）
 * 给你两个基因序列 start 和 end ，以及一个基因库 bank ，请你找出并返回能够使 start 变化为 end 所需的最少变化次数。如果无法完成此基因变化，返回 -1 。
 * 注意：起始基因序列 start 默认是有效的，但是它并不一定会出现在基因库中。
 * 示例 1：
 * 输入：start = "AACCGGTT", end = "AACCGGTA", bank = ["AACCGGTA"]
 * 输出：1
 * 示例 2：
 * 输入：start = "AACCGGTT", end = "AAACGGTA", bank = ["AACCGGTA","AACCGCTA","AAACGGTA"]
 * 输出：2
 * 示例 3：
 * 输入：start = "AAAAACCC", end = "AACCCCCC", bank = ["AAAACCCC","AAACCCCC","AACCCCCC"]
 * 输出：3
 * 提示：
 * start.length == 8
 * end.length == 8
 * 0 <= bank.length <= 10
 * bank[i].length == 8
 * start、end 和 bank[i] 仅由字符 ['A', 'C', 'G', 'T'] 组成
 */
public class LC433_minimum_genetic_mutation {

    Set<String> existSet = new HashSet<>();

    public int minMutation(String startGene, String endGene, String[] bank) {
        existSet.addAll(Arrays.asList(bank));
        if (!existSet.contains(endGene)) {
            return -1;
        }
        int begin = 1;
        Set<String> cur;
        Set<String> next = new HashSet<>();
        next.add(startGene);
        while (true) {
            cur = next;
            next = new HashSet<>();
            for (String s : existSet) {
                for (String curS : cur) {
                    if (isOne(curS, s)) {
                        if (s.equals(endGene)) {
                            return begin;
                        }
                        next.add(s);
                        break;
                    }
                }
            }
            if (next.isEmpty()) {
                return -1;
            }
            begin++;
            existSet.removeAll(next);
        }
    }

    private boolean isOne(String s1, String s2) {
        int diff = 0;
        for (int i = 0; i < 8; i++) {
            if (s1.charAt(i) != s2.charAt(i)) {
                diff++;
                if (diff > 1) {
                    return false;
                }
            }
        }
        return diff == 1;
    }
}
