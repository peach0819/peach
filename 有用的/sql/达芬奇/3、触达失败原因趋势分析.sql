SELECT fail_date,
       sum(case when fail_type = 1 then fail_count else 0 end) as 1_fail_count,
       sum(case when fail_type = 2 then fail_count else 0 end) as 2_fail_count,
       sum(case when fail_type = 3 then fail_count else 0 end) as 3_fail_count,
       sum(case when fail_type = 4 then fail_count else 0 end) as 4_fail_count,
       sum(case when fail_type = 5 then fail_count else 0 end) as 5_fail_count,
       sum(case when fail_type = 6 then fail_count else 0 end) as 6_fail_count,
       sum(case when fail_type = 7 then fail_count else 0 end) as 7_fail_count,
       sum(case when fail_type = 8 then fail_count else 0 end) as 8_fail_count,
       sum(case when fail_type = 9 then fail_count else 0 end) as 9_fail_count,
       sum(case when fail_type = 10 then fail_count else 0 end) as 10_fail_count,
       sum(case when fail_type = 12 then fail_count else 0 end) as 12_fail_count,
       sum(case when fail_type = 13 then fail_count else 0 end) as 13_fail_count,
       sum(case when fail_type = 14 then fail_count else 0 end) as 14_fail_count,
       sum(case when fail_type = 15 then fail_count else 0 end) as 15_fail_count,
       sum(case when fail_type = 16 then fail_count else 0 end) as 16_fail_count,
       sum(case when fail_type = 96 then fail_count else 0 end) as 96_fail_count,
       sum(case when fail_type = 97 then fail_count else 0 end) as 97_fail_count,
       sum(case when fail_type = 98 then fail_count else 0 end) as 98_fail_count,
       sum(case when fail_type = 99 then fail_count else 0 end) as 99_fail_count
FROM (
    SELECT d.fail_type, sum(d.fail_count) as fail_count, t.fail_date
    FROM (
        SELECT task_id, fail_type, count(*) as fail_count
        FROM t_touch_task_detail
        WHERE detail_status = 3
        AND fail_type != 11
        group by task_id, fail_type
    ) d
    INNER JOIN (
        SELECT id, date_format(start_time, '%Y-%m-%d') as fail_date FROM t_touch_task
    ) t ON d.task_id = t.id
    group by d.fail_type, d.fail_count, t.fail_date
) temp
group by fail_date
