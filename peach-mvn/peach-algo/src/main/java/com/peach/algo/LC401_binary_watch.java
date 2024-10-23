package com.peach.algo;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/10/23
 * 二进制手表顶部有 4 个 LED 代表 小时（0-11），底部的 6 个 LED 代表 分钟（0-59）。每个 LED 代表一个 0 或 1，最低位在右侧。
 * 例如，下面的二进制手表读取 "4:51" 。
 * 给你一个整数 turnedOn ，表示当前亮着的 LED 的数量，返回二进制手表可以表示的所有可能时间。你可以 按任意顺序 返回答案。
 * 小时不会以零开头：
 * 例如，"01:00" 是无效的时间，正确的写法应该是 "1:00" 。
 * 分钟必须由两位数组成，可能会以零开头：
 * 例如，"10:2" 是无效的时间，正确的写法应该是 "10:02" 。
 * 示例 1：
 * 输入：turnedOn = 1
 * 输出：["0:01","0:02","0:04","0:08","0:16","0:32","1:00","2:00","4:00","8:00"]
 * 示例 2：
 * 输入：turnedOn = 9
 * 输出：[]
 * 提示：
 * 0 <= turnedOn <= 10
 */
public class LC401_binary_watch {

    List<String> result = new ArrayList<>();

    public List<String> readBinaryWatch(int turnedOn) {
        if (turnedOn >= 9) {
            return result;
        }
        for (int i = 0; i <= 3 && i <= turnedOn; i++) {
            get(i, turnedOn - i);
        }
        result.sort(Comparator.comparing(String::toString));
        return result;
    }

    private void get(int upNum, int downNum) {
        if (upNum >= 4 || downNum >= 6) {
            return;
        }
        List<String> upList = up(upNum);
        List<String> downList = down(downNum);
        for (String up : upList) {
            for (String down : downList) {
                result.add(up + ":" + down);
            }
        }
    }

    private List<String> up(int upNum) {
        List<String> result = new ArrayList<>();
        if (upNum == 0) {
            result.add("0");
            return result;
        }
        List<List<Integer>> resultList = new ArrayList<>();
        List<Integer> last = new ArrayList<>();
        last.add(8);
        last.add(4);
        last.add(2);
        last.add(1);
        handle(last, new ArrayList<>(), resultList, upNum);
        for (List<Integer> list : resultList) {
            int num = 0;
            for (Integer integer : list) {
                num += integer;
            }
            if (num >= 12) {
                continue;
            }
            result.add(String.valueOf(num));
        }
        return result;
    }

    private List<String> down(int downNum) {
        List<String> result = new ArrayList<>();
        if (downNum == 0) {
            result.add("00");
            return result;
        }

        List<List<Integer>> resultList = new ArrayList<>();
        List<Integer> last = new ArrayList<>();
        last.add(32);
        last.add(16);
        last.add(8);
        last.add(4);
        last.add(2);
        last.add(1);
        handle(last, new ArrayList<>(), resultList, downNum);
        for (List<Integer> list : resultList) {
            int num = 0;
            for (Integer integer : list) {
                num += integer;
            }
            if (num >= 60) {
                continue;
            }
            if (num < 10) {
                result.add("0" + num);
            } else {
                result.add(String.valueOf(num));
            }
        }
        return result;
    }

    private void handle(List<Integer> last, List<Integer> curResult, List<List<Integer>> resultList, int num) {
        if (num == 0) {
            resultList.add(new ArrayList<>(curResult));
            return;
        }
        if (last.size() < num) {
            return;
        }
        Integer remove = last.remove(0);
        curResult.add(remove);
        handle(last, curResult, resultList, num - 1);
        curResult.remove(curResult.size() - 1);

        handle(last, curResult, resultList, num);
        last.add(0, remove);
    }
}
