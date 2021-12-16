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

SELECT id, value , sum(value) over (partition by id order by user_id  )
FROM t