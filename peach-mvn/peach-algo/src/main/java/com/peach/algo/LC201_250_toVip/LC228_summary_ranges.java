package com.peach.algo.LC201_250_toVip;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/9/5
 * 给定一个  无重复元素 的 有序 整数数组 nums 。
 * 返回 恰好覆盖数组中所有数字 的 最小有序 区间范围列表 。也就是说，nums 的每个元素都恰好被某个区间范围所覆盖，并且不存在属于某个范围但不属于 nums 的数字 x 。
 * 列表中的每个区间范围 [a,b] 应该按如下格式输出：
 * "a->b" ，如果 a != b
 * "a" ，如果 a == b
 * 示例 1：
 * 输入：nums = [0,1,2,4,5,7]
 * 输出：["0->2","4->5","7"]
 * 解释：区间范围是：
 * [0,2] --> "0->2"
 * [4,5] --> "4->5"
 * [7,7] --> "7"
 * 示例 2：
 * 输入：nums = [0,2,3,4,6,8,9]
 * 输出：["0","2->4","6","8->9"]
 * 解释：区间范围是：
 * [0,0] --> "0"
 * [2,4] --> "2->4"
 * [6,6] --> "6"
 * [8,9] --> "8->9"
 * 提示：
 * 0 <= nums.length <= 20
 * -231 <= nums[i] <= 231 - 1
 * nums 中的所有值都 互不相同
 * nums 按升序排列
 */
public class LC228_summary_ranges {

    List<String> result = new ArrayList<>();

    public List<String> summaryRanges(int[] nums) {
        if (nums.length == 0) {
            return result;
        }
        int begin = nums[0];
        int end = nums[0];
        for (int i = 1; i < nums.length; i++) {
            int num = nums[i];
            if (num != end + 1) {
                result.add(begin == end ? begin + "" : begin + "->" + end);
                begin = num;
                end = num;
            } else {
                end = num;
            }
        }
        result.add(begin == end ? begin + "" : begin + "->" + end);
        return result;
    }

}
