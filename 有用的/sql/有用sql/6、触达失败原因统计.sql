
SELECT task_id as 任务id,
    full_name as 创建人,
    shop_count as 预计触达门店数,
    fail_count as 触达失败门店数,
    offline_fail_count as 离线导致的触达失败门店数
FROM (
         SELECT detail.task_id,
                admin.full_name,
                count(distinct shop_id) as shop_count,
                count(distinct case when detail_status = 3 then shop_id else null end ) as fail_count,
                count(distinct case when detail_status = 3 and fail_type IN (3,6,10) then shop_id else null end ) as offline_fail_count
         FROM t_touch_task_detail detail
                  INNER JOIN t_touch_task task ON detail.task_id = task.id
                  LEFT JOIN yt_ustone.t_user_admin admin ON task.creator = admin.user_id
         WHERE detail.task_id > 479
         group by detail.task_id
     ) temp
WHERE fail_count !=0
order by task_id