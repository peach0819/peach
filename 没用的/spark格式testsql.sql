


SELECT date_format(create_time, '%Y-%m-%d') as fail_date, fail_type, count(*) as fail_count
FROM t_touch_task_detail
WHERE detail_status = 3
  AND fail_type != 11
group by date_format(create_time, '%Y-%m-%d'), fail_type