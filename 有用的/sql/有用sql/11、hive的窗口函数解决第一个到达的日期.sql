with t as (
    SELECT 1 as id, 1 as user_id, 1 as value
    UNION ALL
    SELECT 1 as id, 2 as user_id, 2 as value
    UNION ALL
    SELECT 1 as id, 3 as user_id, 3 as value
    UNION ALL
    SELECT 1 as id, 4 as user_id, 4 as value
    UNION ALL
    SELECT 1 as id, 5 as user_id, 5 as value
    UNION ALL
    SELECT 1 as id, 6 as user_id, 6 as value
    UNION ALL
    SELECT 1 as id, 7 as user_id, 7 as value
    UNION ALL
    SELECT 1 as id, 8 as user_id, 8 as value
    UNION ALL
    SELECT 1 as id, 9 as user_id, 9 as value
    UNION ALL
    SELECT 1 as id, 10 as user_id, 10 as value

    UNION ALL
    SELECT 2 as id, 11 as user_id, 1 as value
    UNION ALL
    SELECT 2 as id, 12 as user_id, 2 as value
    UNION ALL
    SELECT 2 as id, 13 as user_id, 3 as value
    UNION ALL
    SELECT 2 as id, 14 as user_id, 4 as value
    UNION ALL
    SELECT 2 as id, 15 as user_id, 5 as value
    UNION ALL
    SELECT 2 as id, 16 as user_id, 6 as value
    UNION ALL
    SELECT 2 as id, 17 as user_id, 7 as value
    UNION ALL
    SELECT 2 as id, 18 as user_id, 8 as value
    UNION ALL
    SELECT 2 as id, 19 as user_id, 9 as value
    UNION ALL
    SELECT 2 as id, 110 as user_id, 10 as value
)

SELECT id, value , sum(value) over (partition by id order by user_id  ),
FROM t

lag(exp_str,offset,defval) over(partion by ..order by …)

lead(exp_str,offset,defval) over(partion by ..order by …)

其中exp_str是字段名

     Offset是偏移量，即是上1个或上N个的值，假设当前行在表中排在第5行，则offset 为3，则表示我们所要找的数据行就是表中的第2行（即5-3=2）。

     Defval默认值，当两个函数取上N/下N个值，当在表中从当前行位置向前数N行已经超出了表的范围时，lag（）函数将defval这个参数值作为函数的返回值，若没有指定默认值，则返回NULL，那么在数学运算中，总要给一个默认值才不会出错。