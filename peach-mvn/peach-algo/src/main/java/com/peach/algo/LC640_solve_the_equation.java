package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/10/9
 * 求解一个给定的方程，将x以字符串 "x=#value" 的形式返回。该方程仅包含 '+' ， '-' 操作，变量 x 和其对应系数。
 * 如果方程没有解或存在的解不为整数，请返回 "No solution" 。如果方程有无限解，则返回 “Infinite solutions” 。
 * 题目保证，如果方程中只有一个解，则 'x' 的值是一个整数。
 * 示例 1：
 * 输入: equation = "x+5-3+x=6+x-2"
 * 输出: "x=2"
 * 示例 2:
 * 输入: equation = "x=x"
 * 输出: "Infinite solutions"
 * 示例 3:
 * 输入: equation = "2x=x"
 * 输出: "x=0"
 * 提示:
 * 3 <= equation.length <= 1000
 * equation 只有一个 '='.
 * 方程由绝对值在 [0, 100]  范围内且无任何前导零的整数和变量 'x' 组成。
 */
public class LC640_solve_the_equation {

    public static void main(String[] args) {
        System.out.println(new LC640_solve_the_equation().solveEquation("0x=0"));
    }

    public String solveEquation(String equation) {
        String[] split = equation.split("=");
        if (split.length != 2) {
            return "No solution";
        }
        int[] left = handle(split[0]);
        int[] right = handle(split[1]);
        int x = left[0] - right[0];
        int num = right[1] - left[1];
        if (x == 0) {
            return num == 0 ? "Infinite solutions" : "No solution";
        }
        if (num % x == 0) {
            return "x=" + (num / x);
        }
        return "No solution";
    }

    private int[] handle(String str) {
        int[] res = new int[2];
        int val = 0;
        boolean positive = true;
        boolean x = false;
        for (int i = 0; i < str.length(); i++) {
            char c = str.charAt(i);
            if (c == '-') {
                if (x) {
                    x = false;
                } else {
                    res[1] += val * (positive ? 1 : -1);
                }
                positive = false;
                val = 0;
            } else if (c == '+') {
                if (x) {
                    x = false;
                } else {
                    res[1] += val * (positive ? 1 : -1);
                }
                positive = true;
                val = 0;
            } else if (c == 'x') {
                x = true;
                res[0] += (i == 0 || str.charAt(i - 1) == '-' || str.charAt(i - 1) == '+' ? 1 : val)
                        * (positive ? 1 : -1);
            } else {
                val = val * 10 + (c - '0');
            }
        }
        if (!x) {
            res[1] += val * (positive ? 1 : -1);
        }
        return res;
    }

}
