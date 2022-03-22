SELECT task_date,
       total_count,
       touch_success_rate,
       total_success_rate
FROM (
    SELECT task_date,
       sum(total_count) as total_count,
       sum(touch_success_count)/sum(total_count) as touch_success_rate,
       sum(total_success_count)/sum(total_count) as total_success_rate
    FROM (
        SELECT task_id,
               count(case when detail_status = 2 OR fail_type IN (5,14,15,20) then 1 else null end) as touch_success_count,
               count(case when detail_status = 2 then 1 else null end) as total_success_count,
               count(*) as total_count
        FROM t_touch_task_detail
        WHERE detail_status != 1
        AND (fail_type is null OR fail_type not in (7,11,16,19))
        group by task_id
        order by task_id
    ) d
    INNER JOIN (
        SELECT id, date_format(start_time, '%Y-%m-%d') as task_date FROM t_touch_task
    ) t ON d.task_id = t.id
    group by task_date
) temp
order by task_date