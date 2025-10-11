package com.peach.algo.LC601_650_toVip;

/**
 * @author feitao.zt
 * @date 2025/9/1
 * 假设有一个很长的花坛，一部分地块种植了花，另一部分却没有。可是，花不能种植在相邻的地块上，它们会争夺水源，两者都会死去。
 * 给你一个整数数组 flowerbed 表示花坛，由若干 0 和 1 组成，其中 0 表示没种植花，1 表示种植了花。另有一个数 n ，能否在不打破种植规则的情况下种入 n 朵花？能则返回 true ，不能则返回 false 。
 * 示例 1：
 * 输入：flowerbed = [1,0,0,0,1], n = 1
 * 输出：true
 * 示例 2：
 * 输入：flowerbed = [1,0,0,0,1], n = 2
 * 输出：false
 * 提示：
 * 1 <= flowerbed.length <= 2 * 104
 * flowerbed[i] 为 0 或 1
 * flowerbed 中不存在相邻的两朵花
 * 0 <= n <= flowerbed.length
 */
public class LC605_can_place_flowers {

    public static void main(String[] args) {
        System.out.println(new LC605_can_place_flowers().canPlaceFlowers(new int[]{ 1, 0, 0, 0, 1 }, 2));
    }

    public boolean canPlaceFlowers(int[] flowerbed, int n) {
        if (n == 0) {
            return true;
        }
        int i = 0;
        while (i < flowerbed.length && n > 0) {
            int cur = flowerbed[i];
            if (cur == 0) {
                int left = i == 0 ? 0 : flowerbed[i - 1];
                int right = i == flowerbed.length - 1 ? 0 : flowerbed[i + 1];
                if (left == 0 && right == 0) {
                    flowerbed[i] = 1;
                    n--;
                    i += 2;
                } else {
                    i++;
                }
            } else {
                i++;
            }
        }
        return n == 0;
    }
}
