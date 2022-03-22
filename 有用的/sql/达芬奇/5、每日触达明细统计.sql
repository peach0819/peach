SELECT  date_format(create_time, '%Y-%m-%d') as task_date,
        count(distinct admin_chat_id) as qw_count,
        count(distinct shop_id) as shop_count,
        count(DISTINCT shop_chat_id) as total_customer_count
FROM t_touch_task_detail
WHERE detail_status = 2
AND task_id > (SELECT min(id) FROM t_touch_task WHERE date_format(start_time, '%Y-%m-%d') > date_format(DATE_SUB(now(), INTERVAL 15 DAY), '%Y-%m-%d'))
group by date_format(create_time, '%Y-%m-%d')
order by task_date