package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/1/17
 * 神奇字符串 s 仅由 '1' 和 '2' 组成，并需要遵守下面的规则：
 * 神奇字符串 s 的神奇之处在于，串联字符串中 '1' 和 '2' 的连续出现次数可以生成该字符串。
 * s 的前几个元素是 s = "1221121221221121122……" 。如果将 s 中连续的若干 1 和 2 进行分组，可以得到 "1 22 11 2 1 22 1 22 11 2 11 22 ......" 。每组中 1 或者 2 的出现次数分别是 "1 2 2 1 1 2 1 2 2 1 2 2 ......" 。上面的出现次数正是 s 自身。
 * 给你一个整数 n ，返回在神奇字符串 s 的前 n 个数字中 1 的数目。
 * 示例 1：
 * 输入：n = 6
 * 输出：3
 * 解释：神奇字符串 s 的前 6 个元素是 “122112”，它包含三个 1，因此返回 3 。
 * 示例 2：
 * 输入：n = 1
 * 输出：1
 * 提示：
 * 1 <= n <= 105
 */
public class LC481_magical_string {

    public static void main(String[] args) {
        int i = new LC481_magical_string().magicalString(6);
        i = 1;
    }

    char[] from;
    char[] to;
    int result = 1;

    int fromBegin = 1;
    int fromEnd = 1;

    int toBegin = 1;
    int toEnd = 1;

    boolean finish = false;

    public int magicalString(int n) {
        if (n <= 3) {
            return 1;
        }
        from = new char[n + 2];
        to = new char[n + 2];
        from[0] = '1';
        to[0] = '1';

        from[1] = '2';
        while (!finish) {
            handleTo();
            hanldeFrom();
        }
        return result;
    }

    private void hanldeFrom() {
        for (int i = fromEnd + 1; i <= toEnd; i++) {
            from[i] = to[i];
        }
        fromBegin = fromEnd + 1;
        fromEnd = toEnd;
    }

    private void handleTo() {
        int begin = toBegin;
        char last = to[toBegin - 1];
        for (int i = fromBegin; i <= fromEnd; i++) {
            if (begin >= from.length - 2) {
                finish = true;
                break;
            }
            char cur = from[i];
            last = last == '1' ? '2' : '1';
            boolean isOne = last == '1';
            if (cur == '1') {
                to[begin] = last;
                begin += 1;
                if (isOne) {
                    result += 1;
                }
            } else {
                to[begin] = last;
                if (isOne) {
                    result += 1;
                }
                to[begin + 1] = last;
                if (isOne && begin + 1 < from.length - 2) {
                    result += 1;
                }
                begin += 2;
            }
        }
        toBegin = begin;
        toEnd = begin - 1;
    }
}
