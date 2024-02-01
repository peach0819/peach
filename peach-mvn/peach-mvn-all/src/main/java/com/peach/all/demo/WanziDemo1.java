package com.peach.all.demo;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * @author feitao.zt
 * @date 2024/1/31
 */
public class WanziDemo1 {

    public static void main(String[] args) {
        System.out.println("包含1指定洗4的成本");
        print(4, 12);
        print(4, 11);
        print(4, 10);
        print(4, 9);
        print(4, 8);
        System.out.println("\n包含1指定洗3的成本");
        print(3, 12);
        print(3, 11);
        print(3, 10);
        print(3, 9);
        print(3, 8);
    }

    private static void print(int x, int y) {
        System.out.println(String.format("x:[%s], y:[%s], nolock_rate:[%s], lock1_rate:[%s], lock2_rate:[%s]",
                x, y,
                doRate(x, y, 0),
                doRate(x, y, 1),
                doRate(x, y, 2)
        ));
    }

    private static String doRate(int x, int y, int base) {
        Double result = 0D;
        if (base == 0) {
            result = 1 / rate1(x, y);
        }
        if (base == 1) {
            result = 1 / rate1(1, y) + 1 / rate(x - 1, y - 1, 0) * 5;
        }

        return round(result).toPlainString();
    }

    private static double rate(int x, int y, int base) {
        double total = 43d - base;
        x = x - base;
        y = y - base;

        double rate = 1d;
        for (int i = 0; i < x; i++) {
            rate = rate * y / total;
            total--;
            y--;
        }
        return rate;
    }

    private static double rate1(int x, int y) {
        double total = 43d;
        double rate = 1d;
        for (int i = 0; i < x; i++) {
            rate = rate * (i == 0 ? 1 : y) / total;
            total--;
            y--;
        }
        return rate * x;
    }

    private static BigDecimal round(double d) {
        return new BigDecimal(d).divide(new BigDecimal("1"), 0, RoundingMode.UP);
    }
}
