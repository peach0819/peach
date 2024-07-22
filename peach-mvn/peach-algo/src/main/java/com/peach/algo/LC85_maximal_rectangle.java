package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/7/22
 * 给定一个仅包含 0 和 1 、大小为 rows x cols 的二维二进制矩阵，找出只包含 1 的最大矩形，并返回其面积。
 * 示例 1：
 * 输入：matrix = [["1","0","1","0","0"],["1","0","1","1","1"],["1","1","1","1","1"],["1","0","0","1","0"]]
 * 输出：6
 * 解释：最大矩形如上图所示。
 * 示例 2：
 * 输入：matrix = [["0"]]
 * 输出：0
 * 示例 3：
 * 输入：matrix = [["1"]]
 * 输出：1
 * 提示：
 * rows == matrix.length
 * cols == matrix[0].length
 * 1 <= row, cols <= 200
 * matrix[i][j] 为 '0' 或 '1'
 */
public class LC85_maximal_rectangle {

    public static void main(String[] args) {
        new LC85_maximal_rectangle().maximalRectangle(
                new char[][]{ { '1', '0', '1', '0', '0' }, { '1', '0', '1', '1', '1' }, { '1', '1', '1', '1', '1' },
                        { '1', '0', '0', '1', '0' } });
        int i = 1;
    }

    /**
     * 我是傻逼
     */
    public int maximalRectangle1(char[][] matrix) {
        int m = matrix.length;
        int n = matrix[0].length;

        int[][] result = new int[m][n];
        int[][] mm = new int[m][n];
        int[][] nn = new int[m][n];

        //初始化
        char cinit = matrix[0][0];
        result[0][0] = cinit == '0' ? 0 : 1;
        mm[0][0] = cinit == '0' ? 0 : 1;
        nn[0][0] = cinit == '0' ? 0 : 1;

        for (int i = 1; i < m; i++) {
            char c = matrix[i][0];
            if (c == '0') {
                mm[i][0] = 0;
                nn[i][0] = 0;
                result[i][0] = result[i - 1][0];
            } else {
                mm[i][0] = mm[i - 1][0] + 1;
                nn[i][0] = 1;
                result[i][0] = Math.max(result[i - 1][0], mm[i][0] * nn[i][0]);
            }
        }

        for (int i = 1; i < n; i++) {
            char c = matrix[0][i];
            if (c == '0') {
                mm[0][i] = 0;
                nn[0][i] = 0;
                result[0][i] = result[0][i - 1];
            } else {
                mm[0][i] = 1;
                nn[0][i] = nn[0][i - 1] + 1;
                result[0][i] = Math.max(result[0][i - 1], mm[0][i] * nn[0][i]);
            }
        }

        for (int i = 1; i < m; i++) {
            for (int j = 1; j < n; j++) {
                char c = matrix[i][j];
                if (c == '0') {
                    mm[i][j] = 0;
                    nn[i][j] = 0;
                    result[i][j] = Math.max(result[i - 1][j], result[i][j - 1]);
                    continue;
                }
                int curMMax = 1;
                if (mm[i - 1][j] == 0) {
                    mm[i][j] = 1;
                } else {
                    boolean valid = true;
                    int curK = 1;
                    for (int k = j - 1; k >= j - nn[i - 1][j] + 1; k--) {
                        if (matrix[i][k] == '0') {
                            valid = false;
                            break;
                        }
                        curK++;
                    }
                    if (!valid) {
                        mm[i][j] = 1;
                    } else {
                        mm[i][j] = mm[i - 1][j] + 1;
                    }
                    curMMax = mm[i][j] * nn[i - 1][j];
                }

                int curNMax = 1;
                if (nn[i][j - 1] == 0) {
                    nn[i][j] = 1;
                } else {
                    boolean valid = true;
                    for (int k = i - mm[i][j - 1] + 1; k < i; k++) {
                        if (matrix[k][j] == '0') {
                            valid = false;
                            break;
                        }
                    }
                    if (!valid) {
                        nn[i][j] = 1;
                    } else {
                        nn[i][j] = nn[i][j - 1] + 1;
                    }
                    curNMax = nn[i][j] * mm[i][j - 1];
                }
                int curMax = Math.max(curMMax, curNMax);
                result[i][j] = Math.max(Math.max(result[i - 1][j], result[i][j - 1]), curMax);
            }
        }
        return result[m - 1][n - 1];
    }

    public int maximalRectangle(char[][] matrix) {
        /*
        方法1:动态规划+枚举
        枚举每一个1作为矩形的左上角，求出该元素作为矩形左上角，向右下角延伸的最大面积矩形
        而后维护每个计算得到的最大矩形的最大值就是答案
        关键是如何快速求出能延伸的矩形面积最大值，很显然是由每一行中下一个0的位置约束
        因此可以通过DP的方法将每行中下一个0的位置先求出，把每次求面积最大值耗时加速至O(N)
        时间复杂度:O(M*N^2) 空间复杂度:O(M*N)
         */
        int m = matrix.length, n = matrix[0].length;
        // 存储每一行中的下一个0的索引
        int[][] nextZero = new int[m][n];
        for (int i = 0; i < m; i++) {
            int zeroPos = n;
            for (int j = n - 1; j >= 0; j--) {
                if (matrix[i][j] == '0') zeroPos = j;
                nextZero[i][j] = zeroPos;
            }
        }
        int res = 0;
        // 枚举每个左上角
        for (int i = 0; i < m; i++) {
            for (int j = 0; j < n; j++) {
                if (matrix[i][j] == '0') continue;
                int ii = i, maxArea = 0, minWidth = n - j;
                while (ii < m && matrix[ii][j] == '1') {
                    minWidth = Math.min(minWidth, nextZero[ii][j] - j);
                    int area = (ii - i + 1) * minWidth;
                    maxArea = Math.max(maxArea, area);
                    ii++;
                }
                res = Math.max(res, maxArea);
            }
        }
        return res;
    }
}
