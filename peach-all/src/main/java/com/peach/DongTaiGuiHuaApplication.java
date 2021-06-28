package com.peach;

/**
 * @author feitao.zt
 * @date 2021/5/26
 */
public class DongTaiGuiHuaApplication {

    public static void main(String[] args) {
        int[][] value = { { 1, 3, 5, 9 }, { 2, 1, 3, 4 }, { 5, 2, 6, 7 }, { 6, 8, 4, 3 } };
        handle(value);
    }

    private static void handle(int[][] value) {
        int[][] result = new int[4][4];
        //初始化
        result[0][0] = value[0][0];
        for (int i = 1; i < 4; i++) {
            result[0][i] = result[0][i - 1] + value[0][i];
            result[i][0] = result[i - 1][0] + value[i][0];
        }
        for (int i = 1; i < 4; i++) {
            for (int j = 1; j < 4; j++) {
                result[i][j] = Math.min(result[i - 1][j], result[i][j - 1]) + value[i][j];
            }
        }
        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++) {
                System.out.print(i + "-" + j + ": " + result[i][j] + "    ");
            }
            System.out.print("\n");
        }
    }
}
