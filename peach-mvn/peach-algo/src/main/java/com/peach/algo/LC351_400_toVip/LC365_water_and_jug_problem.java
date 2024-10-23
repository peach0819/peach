package com.peach.algo.LC351_400_toVip;

/**
 * @author feitao.zt
 * @date 2024/10/10
 * 有两个水壶，容量分别为 x 和 y 升。水的供应是无限的。确定是否有可能使用这两个壶准确得到 target 升。
 * 你可以：
 * 装满任意一个水壶
 * 清空任意一个水壶
 * 将水从一个水壶倒入另一个水壶，直到接水壶已满，或倒水壶已空。
 * 示例 1:
 * 输入: x = 3,y = 5,target = 4
 * 输出: true
 * 解释：
 * 按照以下步骤操作，以达到总共 4 升水：
 * 1. 装满 5 升的水壶(0, 5)。
 * 2. 把 5 升的水壶倒进 3 升的水壶，留下 2 升(3, 2)。
 * 3. 倒空 3 升的水壶(0, 2)。
 * 4. 把 2 升水从 5 升的水壶转移到 3 升的水壶(2, 0)。
 * 5. 再次加满 5 升的水壶(2, 5)。
 * 6. 从 5 升的水壶向 3 升的水壶倒水直到 3 升的水壶倒满。5 升的水壶里留下了 4 升水(3, 4)。
 * 7. 倒空 3 升的水壶。现在，5 升的水壶里正好有 4 升水(0, 4)。
 * 参考：来自著名的 "Die Hard"
 * 示例 2:
 * 输入: x = 2, y = 6, target = 5
 * 输出: false
 * 示例 3:
 * 输入: x = 1, y = 2, target = 3
 * 输出: true
 * 解释：同时倒满两个水壶。现在两个水壶中水的总量等于 3。
 * 提示:
 * 1 <= x, y, target <= 103
 */
public class LC365_water_and_jug_problem {

    public static void main(String[] args) {
        new LC365_water_and_jug_problem().canMeasureWater(34, 5, 6);
    }

    Boolean[] can = new Boolean[1001];

    int x;
    int y;
    int target;

    public boolean canMeasureWater(int x, int y, int target) {
        if (x + y == target || x == target || y == target) {
            return true;
        }
        if (x + y < target) {
            return false;
        }
        if (x % 2 == 0 && y % 2 == 0 && target % 2 == 1) {
            return false;
        }
        if (x == y) {
            return false;
        }
        this.x = Math.min(x, y);
        this.y = Math.max(x, y);
        this.target = target;
        can[x] = true;
        can[y] = true;
        handle(this.y - this.x);
        return can[target] != null;
    }

    private void handle(int cur) {
        if (can[cur] != null || can[target] != null) {
            return;
        }
        can[cur] = true;
        if (cur == target) {
            return;
        }
        if (cur < x) {
            handle(x - cur);
        }
        if (cur < y) {
            handle(y - cur);
        }
        if (cur > x) {
            handle(cur - x);
        }
        if (cur + x <= target) {
            handle(cur + x);
        }
        if (cur + y <= target) {
            handle(cur + y);
        }
    }
}
