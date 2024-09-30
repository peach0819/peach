package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/9/30
 */
public class LC342_power_of_four {

    public boolean isPowerOfFour(int n) {
        return n > 0 && 1073741824 % n == 0 && (n & 0b1010101010101010101010101010101) == n;
    }

}
