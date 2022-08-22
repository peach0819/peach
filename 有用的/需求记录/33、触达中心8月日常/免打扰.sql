SELECT count(distinct batch_id) as distinct_count, count(distinct case when detail_status = 2 then batch_id else null end) as success_count, count(*) as total_count
FROM (
    SELECT detail_id, batch_id, detail_status, fail_type, split_fail_reason, task_instance_id, retry_num
    FROM (
        SELECT d.id as detail_id, d.batch_id, d.detail_status, d.fail_type, d.fail_reason, d.task_instance_id, d.retry_num
        FROM dwd_touch_task_detail_d d
        INNER JOIN dwd_touch_task_instance_d i ON d.task_instance_id = i.id AND i.dayid = '$v_date' AND substr(i.start_time, 0,8) > '$v_7_days_ago'
        WHERE d.dayid = '$v_date'
        AND i.dayid > '0'
    ) data
    lateral view explode(split(fail_reason,';')) temp as split_fail_reason
) data1
WHERE get_json_object(split_fail_reason, '$.failType') = 30