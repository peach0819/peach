package com.peach.algo.LC151_200_toVip;

/**
 * @author feitao.zt
 * @date 2024/8/8
 * 给你一个字符串 columnTitle ，表示 Excel 表格中的列名称。返回 该列名称对应的列序号 。
 * 例如：
 * A -> 1
 * B -> 2
 * C -> 3
 * ...
 * Z -> 26
 * AA -> 27
 * AB -> 28
 * ...
 * 示例 1:
 * 输入: columnTitle = "A"
 * 输出: 1
 * 示例 2:
 * 输入: columnTitle = "AB"
 * 输出: 28
 * 示例 3:
 * 输入: columnTitle = "ZY"
 * 输出: 701
 * 提示：
 * 1 <= columnTitle.length <= 7
 * columnTitle 仅由大写英文组成
 * columnTitle 在范围 ["A", "FXSHRXW"] 内
 */
public class LC171_excel_sheet_column_number {

    public int titleToNumber(String columnTitle) {
        char[] chars = columnTitle.toCharArray();
        int result = 0;
        for (char c : chars) {
            result *= 26;
            result += (c - 'A' + 1);
        }
        return result;
    }
}
