package com.peach.algo.LC51_100;

/**
 * @author feitao.zt
 * @date 2024/7/18
 * 给定一个 m x n 二维字符网格 board 和一个字符串单词 word 。如果 word 存在于网格中，返回 true ；否则，返回 false 。
 * 单词必须按照字母顺序，通过相邻的单元格内的字母构成，其中“相邻”单元格是那些水平相邻或垂直相邻的单元格。同一个单元格内的字母不允许被重复使用。
 * 示例 1：
 * 输入：board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], word = "ABCCED"
 * 输出：true
 * 示例 2：
 * 输入：board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], word = "SEE"
 * 输出：true
 * 示例 3：
 * 输入：board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], word = "ABCB"
 * 输出：false
 * 提示：
 * m == board.length
 * n = board[i].length
 * 1 <= m, n <= 6
 * 1 <= word.length <= 15
 * board 和 word 仅由大小写英文字母组成
 * 进阶：你可以使用搜索剪枝的技术来优化解决方案，使其在 board 更大的情况下可以更快解决问题？
 */
public class LC79_word_search {

    char[][] board;
    char[] chars;

    public boolean exist(char[][] board, String word) {
        this.board = board;
        chars = word.toCharArray();
        for (int i = 0; i < board.length; i++) {
            for (int j = 0; j < board[0].length; j++) {
                boolean handle = handle(0, i, j);
                if (handle) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean handle(int i, int x, int y) {
        if (i == chars.length) {
            return true;
        }
        if (x < 0 || x >= board.length) {
            return false;
        }
        if (y < 0 || y >= board[0].length) {
            return false;
        }
        char c = chars[i];
        char c1 = board[x][y];
        if (c != c1) {
            return false;
        }
        board[x][y] = ' ';
        boolean result = handle(i + 1, x - 1, y)
                || handle(i + 1, x + 1, y)
                || handle(i + 1, x, y - 1)
                || handle(i + 1, x, y + 1);
        board[x][y] = c1;
        return result;
    }

}
