package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/7/8
 * 给定一个长度为 n 的 0 索引整数数组 nums。初始位置为 nums[0]。
 * 每个元素 nums[i] 表示从索引 i 向前跳转的最大长度。换句话说，如果你在 nums[i] 处，你可以跳转到任意 nums[i + j] 处:
 * 0 <= j <= nums[i]
 * i + j < n
 * 返回到达 nums[n - 1] 的最小跳跃次数。生成的测试用例可以到达 nums[n - 1]。
 * 示例 1:
 * 输入: nums = [2,3,1,1,4]
 * 输出: 2
 * 解释: 跳到最后一个位置的最小跳跃数是 2。
 * 从下标为 0 跳到下标为 1 的位置，跳 1 步，然后跳 3 步到达数组的最后一个位置。
 * 示例 2:
 * 输入: nums = [2,3,0,1,4]
 * 输出: 2
 * 提示:
 * 1 <= nums.length <= 104
 * 0 <= nums[i] <= 1000
 * 题目保证可以到达 nums[n-1]
 */
public class LC45_jump_game_ii {

    public int jump1(int[] nums) {
        if (nums.length == 1) {
            return 0;
        }
        int[] result = new int[nums.length];
        int max = nums.length - 1;
        result[0] = 0;
        int val = Integer.MAX_VALUE;
        for (int i = 0; i < nums.length; i++) {
            int num = nums[i];
            if (num == 0) {
                continue;
            }
            if (i + num >= max) {
                return Math.min(result[i] + 1, val);
            }
            for (int j = 1; j <= num; j++) {
                if (i + j < nums.length) {
                    if (result[i + j] == 0) {
                        result[i + j] = result[i] + 1;
                    } else {
                        result[i + j] = Math.min(result[i + j], result[i] + 1);
                    }
                }
            }
        }
        return result[result.length - 1];
    }

    public static void main(String[] args) {
        new LC45_jump_game_ii().jump(new int[]{ 2, 3, 1, 1, 4 });
    }

    /**
     * 贪心算法， 每一步都找 nums[i] + i可以到达的最大值，这样不管怎么走，从最大值出发能到达的下一步最大值都是更大的
     */
    public int jump(int[] nums) {
        int length = nums.length;
        if (length == 1) {
            return 0;
        }
        int index = 0;
        int step = 0;
        while (index + nums[index] < nums.length - 1) {
            int maxIndex = 0;
            int maxVal = 0;
            for (int i = index + 1; i <= index + nums[index]; i++) {
                int val1 = nums[i] + i;
                if (val1 >= nums.length - 1) {
                    maxIndex = i;
                    break;
                }
                if (val1 > maxVal) {
                    maxIndex = i;
                    maxVal = val1;
                }
            }
            index = maxIndex;
            step++;
        }
        return step + 1;
    }
}
