package com.peach.algo.LC51_100;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2023/3/31
 */
public class LC66_plus_one {

    public int[] plusOne1(int[] digits) {
        if (digits.length == 0) {
            return digits;
        }
        if (Arrays.stream(digits).allMatch(d -> d == 9)) {
            int[] result = new int[digits.length + 1];
            result[0] = 1;
            for (int i = 0; i < digits.length; i++) {
                result[i + 1] = 0;
            }
            return result;
        }
        plusCur(digits, digits.length - 1);
        return digits;
    }

    private void plusCur(int[] digits, int n) {
        if (digits[n] != 9) {
            digits[n] = digits[n] + 1;
            return;
        }
        digits[n] = 0;
        plusCur(digits, n - 1);
    }

    public int[] plusOne(int[] digits) {
        if (digits.length == 0) {
            return digits;
        }
        for (int i = digits.length - 1; i >= 0; i--) {
            int digit = digits[i];
            if (digit != 9) {
                digits[i] = digit + 1;
                return digits;
            } else {
                digits[i] = 0;
            }
        }
        digits = new int[digits.length + 1];
        digits[0] = 1;
        return digits;
    }
}
