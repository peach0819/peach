package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/9/2
 * 找出所有相加之和为 n 的 k 个数的组合，且满足下列条件：
 * 只使用数字1到9
 * 每个数字 最多使用一次
 * 返回 所有可能的有效组合的列表 。该列表不能包含相同的组合两次，组合可以以任何顺序返回。
 * 示例 1:
 * 输入: k = 3, n = 7
 * 输出: [[1,2,4]]
 * 解释:
 * 1 + 2 + 4 = 7
 * 没有其他符合的组合了。
 * 示例 2:
 * 输入: k = 3, n = 9
 * 输出: [[1,2,6], [1,3,5], [2,3,4]]
 * 解释:
 * 1 + 2 + 6 = 9
 * 1 + 3 + 5 = 9
 * 2 + 3 + 4 = 9
 * 没有其他符合的组合了。
 * 示例 3:
 * 输入: k = 4, n = 1
 * 输出: []
 * 解释: 不存在有效的组合。
 * 在[1,9]范围内使用4个不同的数字，我们可以得到的最小和是1+2+3+4 = 10，因为10 > 1，没有有效的组合。
 * 提示:
 * 2 <= k <= 9
 * 1 <= n <= 60
 */
public class LC216_combination_sum_iii {

    List<List<Integer>> result = new ArrayList<>();

    public List<List<Integer>> combinationSum3(int k, int n) {
        int min = 0;
        int max = 0;
        for (int i = 1; i <= k; i++) {
            min += i;
            max += 10 - i;
        }
        if (n < min || n > max) {
            return result;
        }
        handle(k, n, 0, new ArrayList<>());
        return result;
    }

    private void handle(int k, int n, int min, List<Integer> list) {
        if (k == 1) {
            if (n > min && n <= 9) {
                list.add(n);
                result.add(new ArrayList<>(list));
                list.remove(list.size() - 1);
            }
            return;
        }
        for (int i = min + 1; i <= 10 - k; i++) {
            list.add(i);
            handle(k - 1, n - i, i, list);
            list.remove(list.size() - 1);
        }
    }

}
