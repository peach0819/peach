package com.peach.algo.LC51_100;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/16
 * 给定一个单词数组 words 和一个长度 maxWidth ，重新排版单词，使其成为每行恰好有 maxWidth 个字符，且左右两端对齐的文本。
 * 你应该使用 “贪心算法” 来放置给定的单词；也就是说，尽可能多地往每行中放置单词。必要时可用空格 ' ' 填充，使得每行恰好有 maxWidth 个字符。
 * 要求尽可能均匀分配单词间的空格数量。如果某一行单词间的空格不能均匀分配，则左侧放置的空格数要多于右侧的空格数。
 * 文本的最后一行应为左对齐，且单词之间不插入额外的空格。
 * 注意:
 * 单词是指由非空格字符组成的字符序列。
 * 每个单词的长度大于 0，小于等于 maxWidth。
 * 输入单词数组 words 至少包含一个单词。
 * 示例 1:
 * 输入: words = ["This", "is", "an", "example", "of", "text", "justification."], maxWidth = 16
 * 输出:
 * [
 * "This    is    an",
 * "example  of text",
 * "justification.  "
 * ]
 * 示例 2:
 * 输入:words = ["What","must","be","acknowledgment","shall","be"], maxWidth = 16
 * 输出:
 * [
 * "What   must   be",
 * "acknowledgment  ",
 * "shall be        "
 * ]
 * 解释: 注意最后一行的格式应为 "shall be    " 而不是 "shall     be",
 * 因为最后一行应为左对齐，而不是左右两端对齐。
 * 第二行同样为左对齐，这是因为这行只包含一个单词。
 * 示例 3:
 * 输入:words = ["Science","is","what","we","understand","well","enough","to","explain","to","a","computer.","Art","is","everything","else","we","do"]，maxWidth = 20
 * 输出:
 * [
 * "Science  is  what we",
 * "understand      well",
 * "enough to explain to",
 * "a  computer.  Art is",
 * "everything  else  we",
 * "do                  "
 * ]
 * 提示:
 * 1 <= words.length <= 300
 * 1 <= words[i].length <= 20
 * words[i] 由小写英文字母和符号组成
 * 1 <= maxWidth <= 100
 * words[i].length <= maxWidth
 */
public class LC68_text_justification {

    public static void main(String[] args) {
        new LC68_text_justification()
                .fullJustify(new String[]{ "Listen", "to", "many,", "speak", "to", "a", "few." }, 6);
    }

    String[] words;
    int maxWidth;

    public List<String> fullJustify(String[] words, int maxWidth) {
        this.words = words;
        this.maxWidth = maxWidth;
        List<String> result = new ArrayList<>();
        int begin = 0;
        int num = words[0].length();
        int actualNum = words[0].length();
        for (int i = 1; i < words.length; i++) {
            String word = words[i];
            int length = word.length();
            if (num + length + 1 > maxWidth) {
                result.add(build(begin, i - 1, actualNum));
                begin = i;
                num = length;
                actualNum = num;
            } else {
                num += length + 1;
                actualNum += length;
            }
        }
        result.add(buildLast(begin, words.length - 1, num));
        return result;
    }

    private String build(int begin, int end, int num) {
        int space = maxWidth - num;
        StringBuilder s = new StringBuilder();
        if (begin == end) {
            s.append(words[begin]);
            for (int i = 0; i < space; i++) {
                s.append(' ');
            }
            return s.toString();
        }

        int val = end - begin;
        int spaceNum = space / val;
        int startSpace = space % val;
        for (int i = begin; i < end; i++) {
            s.append(words[i]);
            for (int j = 0; j < spaceNum; j++) {
                s.append(' ');
            }
            if (startSpace > 0) {
                s.append(' ');
                startSpace--;
            }
        }
        s.append(words[end]);
        return s.toString();
    }

    private String buildLast(int begin, int end, int num) {
        if (words[begin].length() == maxWidth) {
            return words[begin];
        }
        StringBuilder s = new StringBuilder();
        int val = 0;
        for (int i = begin; i < end; i++) {
            s.append(words[i]);
            s.append(' ');
            val += words[i].length() + 1;
        }
        s.append(words[end]);
        val += words[end].length();
        for (int i = val; i < maxWidth; i++) {
            s.append(' ');
        }
        return s.toString();
    }

}