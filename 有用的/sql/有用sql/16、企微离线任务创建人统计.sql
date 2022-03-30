SELECT d.fail_hour, t.creator,  u.full_name, count(*) as c
FROM (SELECT *, date_format(fail_time, '%H') as fail_hour FROM t_touch_task_detail WHERE detail_status = 3 AND fail_type = 3) d
INNER JOIN (SELECT * FROM t_touch_task WHERE start_time > '2022-03-01 00:00:00' AND task_status = 3) t ON d.task_id = t.id
INNER JOIN yt_ustone.t_user_admin u ON t.creator = u.user_id
WHERE fail_hour is not null
group by d.fail_hour, t.creator, u.full_name
order by c desc