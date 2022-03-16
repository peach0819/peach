SELECT count(*) as detail_count,
       case when detail_status = 2 then '成功'
            when detail_status IN (1,4,5) then '待发送'
       else '失败' end as detail_status
FROM t_touch_task_detail d
INNER JOIN (
    SELECT id
    FROM t_touch_task
    WHERE date_format(start_time, '%Y-%m-%d') = date_format(now(), '%Y-%m-%d')
) t ON d.task_id = t.id
WHERE (fail_type is null OR fail_type!=11)
group by case when detail_status = 2 then '成功'
            when detail_status IN (1,4,5) then '待发送'
       else '失败' end