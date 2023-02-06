use ytdw;

create table if not exists ads_touch_task_disturb_d
(
    task_date              string comment '门店id',
    total_count            bigint comment '门店名',
    distinct_disturb_count bigint comment '联系人id',
    success_disturb_count  bigint comment '联系人名',
    total_disturb_count    bigint comment '客户微信昵称'
) comment '触达中心会话免打扰统计表'
partitioned by (dayid string)
stored as orc;

insert overwrite table ads_touch_task_disturb_d partition(dayid='$v_date')
SELECT task_date,
       count(distinct batch_id) as total_count,
       count(distinct case when get_json_object(split_fail_reason, '$.failType') = 30 then batch_id else null end) as distinct_disturb_count,
       count(distinct case when get_json_object(split_fail_reason, '$.failType') = 30  AND detail_status = 2 then batch_id else null end) as success_disturb_count,
       count(case when get_json_object(split_fail_reason, '$.failType') = 30 then 1 else null end) as total_disturb_count
FROM (
    SELECT detail_id, batch_id, detail_status, fail_type, split_fail_reason, task_instance_id, retry_num, task_date
    FROM (
        SELECT d.id as detail_id, d.batch_id, d.detail_status, d.fail_type, d.fail_reason, d.task_instance_id, d.retry_num, substr(i.start_time, 0,8) as task_date
        FROM dwd_touch_task_detail_d d
        INNER JOIN dwd_touch_task_instance_d i ON d.task_instance_id = i.id AND i.dayid = '$v_date' AND substr(i.start_time, 0,8) > '$v_7_days_ago'
        WHERE d.dayid = '$v_date'
        AND i.dayid > '0'
    ) data2
    lateral view explode(split(fail_reason,';')) temp as split_fail_reason
) data1
group by task_date