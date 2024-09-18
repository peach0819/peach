package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/9/18
 * 给你一个数组 nums ，请你完成两类查询。
 * 其中一类查询要求 更新 数组 nums 下标对应的值
 * 另一类查询要求返回数组 nums 中索引 left 和索引 right 之间（ 包含 ）的nums元素的 和 ，其中 left <= right
 * 实现 NumArray 类：
 * NumArray(int[] nums) 用整数数组 nums 初始化对象
 * void update(int index, int val) 将 nums[index] 的值 更新 为 val
 * int sumRange(int left, int right) 返回数组 nums 中索引 left 和索引 right 之间（ 包含 ）的nums元素的 和 （即，nums[left] + nums[left + 1], ..., nums[right]）
 * 示例 1：
 * 输入：
 * ["NumArray", "sumRange", "update", "sumRange"]
 * [[[1, 3, 5]], [0, 2], [1, 2], [0, 2]]
 * 输出：
 * [null, 9, null, 8]
 * 解释：
 * NumArray numArray = new NumArray([1, 3, 5]);
 * numArray.sumRange(0, 2); // 返回 1 + 3 + 5 = 9
 * numArray.update(1, 2);   // nums = [1,2,5]
 * numArray.sumRange(0, 2); // 返回 1 + 2 + 5 = 8
 * 提示：
 * 1 <= nums.length <= 3 * 104
 * -100 <= nums[i] <= 100
 * 0 <= index < nums.length
 * -100 <= val <= 100
 * 0 <= left <= right < nums.length
 * 调用 update 和 sumRange 方法次数不大于 3 * 104
 */
public class LC307_range_sum_query_mutable {

    /**
     * Your NumArray object will be instantiated and called as such:
     * NumArray obj = new NumArray(nums);
     * obj.update(index,val);
     * int param_2 = obj.sumRange(left,right);
     */
    class NumArray {

        int[] result;

        int[] toUpdate;

        int[] nums;

        boolean update = false;

        public NumArray(int[] nums) {
            this.nums = nums;
            result = new int[nums.length];
            int sum = 0;
            for (int i = 0; i < nums.length; i++) {
                sum += nums[i];
                result[i] = sum;
            }
            toUpdate = new int[nums.length];
        }

        public void update(int index, int val) {
            if (nums[index] == val) {
                return;
            }
            toUpdate[index] += val - nums[index];
            nums[index] = val;
            update = true;
        }

        public int sumRange(int left, int right) {
            if (update) {
                doUpdate();
                update = false;
            }
            return get(right) - get(left - 1);
        }

        private void doUpdate() {
            int toAdd = 0;
            for (int i = 0; i < toUpdate.length; i++) {
                if (toUpdate[i] != 0) {
                    toAdd += toUpdate[i];
                    toUpdate[i] = 0;
                }
                if (toAdd != 0) {
                    result[i] += toAdd;
                }
            }
        }

        private int get(int index) {
            if (index < 0) {
                return 0;
            }
            return result[index];
        }
    }

    class NumArray1 {
        private int[] tree;
        private int[] numbers;
        public NumArray1(int[] nums) {
            int n = nums.length;
            numbers = new int[n];
            tree = new int[n+1];

            for (int i = 0; i < n; i++){
                update(i, nums[i]);
            }

            // System.out.println(Arrays.toString(tree));
            // System.out.println(Arrays.toString(numbers));
        }

        public void update(int index, int val) {
            int delta = val - numbers[index];
            numbers[index] = val;

            for (int i = index + 1; i < tree.length; i += (i & -i)){
                tree[i] += delta;
            }
        }

        public int prefixSum(int index){
            int ret = 0;
            while (index > 0){
                ret += tree[index];
                index -= (index & -index);
            }
            return ret;
        }

        public int sumRange(int left, int right) {
            return prefixSum(right + 1) - prefixSum(left);
        }
    }

}
