SELECT task.task_id,  --任务id
       task.max_time,  --任务的结束时间
       task.min_time,  --任务的开始时间
       task.shop_count, --任务涉及门店数
       task.scene_name, --任务涉及场景
       TIMESTAMPDIFF(SECOND, task.min_time, task.max_time) as diff, --任务秒数
       group_concat(task1.task_id) as concurrent_task_id, --并发任务信息
       count(task1.task_id) as concurrent_count --任务并发数（除去当前任务之外的任务数）
FROM (
         SELECT task_id,
                max(r.create_time) as max_time,
                min(r.create_time) as min_time,
                count(distinct shop_id) as shop_count,
                group_concat(distinct s.show_name) as scene_name
         FROM t_match_touch_result r
                  INNER JOIN t_touch_scene s ON r.scene_id = s.scene_id
         WHERE task_id IN (
             SELECT distinct task_id
             FROM t_match_touch_result
             WHERE create_time > '20220401'
         )
         group by task_id
     ) task
         INNER JOIN (
    SELECT task_id,
           max(create_time) as max_time,
           min(create_time) as min_time
    FROM t_match_touch_result
    WHERE task_id IN (
        SELECT distinct task_id
        FROM t_match_touch_result
        WHERE create_time > '20220401'
    )
    group by task_id
) task1 ON task.task_id != task1.task_id AND task.min_time <= task1.max_time AND task.max_time >= task1.min_time
group by task.task_id,
         task.max_time,
         task.min_time,
         task.shop_count,
         task.scene_name,
         TIMESTAMPDIFF(SECOND, task.min_time, task.max_time);