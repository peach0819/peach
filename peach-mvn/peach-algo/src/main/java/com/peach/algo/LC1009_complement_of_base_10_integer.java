package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/1/15
 */
public class LC1009_complement_of_base_10_integer {

    public int bitwiseComplement(int n) {
        int i = 1;
        int k = 1;
        while (true) {
            if (n / 2 >= i) {
                i = i << 1;
                k = (k << 1) + 1;
            } else {
                break;
            }
        }
        return k & (-n - 1);
    }
}
