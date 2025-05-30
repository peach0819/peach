package com.peach.algo.LC501_550_toVip;

/**
 * @author feitao.zt
 * @date 2025/4/28
 * 让我们一起来玩扫雷游戏！
 * 给你一个大小为 m x n 二维字符矩阵 board ，表示扫雷游戏的盘面，其中：
 * 'M' 代表一个 未挖出的 地雷，
 * 'E' 代表一个 未挖出的 空方块，
 * 'B' 代表没有相邻（上，下，左，右，和所有4个对角线）地雷的 已挖出的 空白方块，
 * 数字（'1' 到 '8'）表示有多少地雷与这块 已挖出的 方块相邻，
 * 'X' 则表示一个 已挖出的 地雷。
 * 给你一个整数数组 click ，其中 click = [clickr, clickc] 表示在所有 未挖出的 方块（'M' 或者 'E'）中的下一个点击位置（clickr 是行下标，clickc 是列下标）。
 * 根据以下规则，返回相应位置被点击后对应的盘面：
 * 如果一个地雷（'M'）被挖出，游戏就结束了- 把它改为 'X' 。
 * 如果一个 没有相邻地雷 的空方块（'E'）被挖出，修改它为（'B'），并且所有和其相邻的 未挖出 方块都应该被递归地揭露。
 * 如果一个 至少与一个地雷相邻 的空方块（'E'）被挖出，修改它为数字（'1' 到 '8' ），表示相邻地雷的数量。
 * 如果在此次点击中，若无更多方块可被揭露，则返回盘面。
 * 示例 1：
 * 输入：board = [["E","E","E","E","E"],["E","E","M","E","E"],["E","E","E","E","E"],["E","E","E","E","E"]], click = [3,0]
 * 输出：[["B","1","E","1","B"],["B","1","M","1","B"],["B","1","1","1","B"],["B","B","B","B","B"]]
 * 示例 2：
 * 输入：board = [["B","1","E","1","B"],["B","1","M","1","B"],["B","1","1","1","B"],["B","B","B","B","B"]], click = [1,2]
 * 输出：[["B","1","E","1","B"],["B","1","X","1","B"],["B","1","1","1","B"],["B","B","B","B","B"]]
 * 提示：
 * m == board.length
 * n == board[i].length
 * 1 <= m, n <= 50
 * board[i][j] 为 'M'、'E'、'B' 或数字 '1' 到 '8' 中的一个
 * click.length == 2
 * 0 <= clickr < m
 * 0 <= clickc < n
 * board[clickr][clickc] 为 'M' 或 'E'
 */
public class LC529_minesweeper {

    public static void main(String[] args) {
        char[][] board = new char[][]{ { 'E', 'E', 'E', 'E', 'E' }, { 'E', 'E', 'M', 'E', 'E' },
                { 'E', 'E', 'E', 'E', 'E' }, { 'E', 'E', 'E', 'E', 'E' } };
        int[] click = new int[]{ 3, 0 };
        char[][] updateBoard = new LC529_minesweeper().updateBoard(board, click);
        int i = 1;
    }

    boolean has[][];
    char[][] board;

    int[][] pre = new int[][]{ { -1, -1 }, { -1, 0 }, { -1, 1 }, { 0, -1 }, { 0, 1 }, { 1, -1 }, { 1, 0 }, { 1, 1 } };

    public char[][] updateBoard(char[][] board, int[] click) {
        this.board = board;
        this.has = new boolean[board.length][board[0].length];
        for (int i = 0; i < board.length; i++) {
            for (int j = 0; j < board[i].length; j++) {
                char cur = board[i][j];
                if (cur != 'M' && cur != 'E') {
                    has[i][j] = true;
                }
            }
        }
        if (board[click[0]][click[1]] == 'M') {
            board[click[0]][click[1]] = 'X';
            return board;
        }
        handle(click[0], click[1]);
        return board;
    }

    private void handle(int i, int j) {
        if (i < 0 || i >= board.length || j < 0 || j >= board[0].length || has[i][j]) {
            return;
        }
        int boom = 0;
        for (int[] cur : pre) {
            if (i + cur[0] < 0 || i + cur[0] >= board.length || j + cur[1] < 0 || j + cur[1] >= board[0].length) {
                continue;
            }
            if (board[i + cur[0]][j + cur[1]] == 'M') {
                boom++;
            }
        }
        has[i][j] = true;
        if (boom != 0) {
            board[i][j] = (char) (boom + '0');
        } else {
            board[i][j] = 'B';
            for (int[] cur : pre) {
                handle(i + cur[0], j + cur[1]);
            }
        }
    }

}