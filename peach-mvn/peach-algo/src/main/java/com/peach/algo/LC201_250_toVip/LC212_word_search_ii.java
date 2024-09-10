package com.peach.algo.LC201_250_toVip;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/8/28
 * 给定一个 m x n 二维字符网格 board 和一个单词（字符串）列表 words， 返回所有二维网格上的单词 。
 * 单词必须按照字母顺序，通过 相邻的单元格 内的字母构成，其中“相邻”单元格是那些水平相邻或垂直相邻的单元格。同一个单元格内的字母在一个单词中不允许被重复使用。
 * 示例 1：
 * 输入：board = [["o","a","a","n"],["e","t","a","e"],["i","h","k","r"],["i","f","l","v"]], words = ["oath","pea","eat","rain"]
 * 输出：["eat","oath"]
 * 示例 2：
 * 输入：board = [["a","b"],["c","d"]], words = ["abcb"]
 * 输出：[]
 * 提示：
 * m == board.length
 * n == board[i].length
 * 1 <= m, n <= 12
 * board[i][j] 是一个小写英文字母
 * 1 <= words.length <= 3 * 104
 * 1 <= words[i].length <= 10
 * words[i] 由小写英文字母组成
 * words 中的所有字符串互不相同
 */
public class LC212_word_search_ii {

    public static void main(String[] args) {
        new LC212_word_search_ii().findWords(new char[][]{ { 'a', 'b' } }, new String[]{ "ba" });
    }

    char[][] board;
    List<String> result = new ArrayList<>();

    public List<String> findWords(char[][] board, String[] words) {
        this.board = board;
        for (String word : words) {
            if (can(word.toCharArray())) {
                result.add(word);
            }
        }
        return result;
    }

    private boolean can(char[] array) {
        for (int i = 0; i < board.length; i++) {
            for (int j = 0; j < board[i].length; j++) {
                if (handle(array, 0, i, j)) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean handle(char[] array, int index, int i, int j) {
        if (i < 0 || i >= board.length || j < 0 || j >= board[0].length) {
            return false;
        }
        char c = board[i][j];
        if (c == '.') {
            return false;
        }
        char cur = array[index];
        if (cur != c) {
            return false;
        }
        if (index == array.length - 1) {
            return true;
        }
        board[i][j] = '.';
        boolean b = handle(array, index + 1, i - 1, j)
                || handle(array, index + 1, i + 1, j)
                || handle(array, index + 1, i, j - 1)
                || handle(array, index + 1, i, j + 1);
        board[i][j] = c;
        return b;
    }

}
