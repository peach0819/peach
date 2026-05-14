WITH qw_tmp as (
    SELECT a.*,
           row_number() OVER (PARTITION BY admin_chat_id, shop_chat_id, adjust_content, substr(msg_time, 1, 8) ORDER BY msg_time, id) as qw_same_msg_row
    FROM (
        SELECT id,
               admin_chat_id,
               shop_chat_id,
               replace(replace(content, '[', ''), ']', '') as content,
               msg_time,
               CASE WHEN msg_type = 'weapp' THEN get_json_object(meta_data, '$.weapp.title') ELSE replace(replace(content, '[', ''), ']', '') END as adjust_content
        FROM dwd_crm_chat_msg_qw_d
        WHERE dayid = '${v_date}'
        AND is_deleted = 0
        AND substr(create_time, 1, 8) <= '${v_date}'
        AND direction = 1
    ) a
)

INSERT OVERWRITE TABLE dw_ytj_sel_touch_task_detail_d PARTITION (dayid = '${v_date}')
SELECT a.id as touch_task_detail_id,
       a.task_id as touch_task_id,
       b.touch_task_name as touch_task_name,
       a.batch_id as touch_task_detail_batch_id,
       a.detail_status as touch_task_detail_status,
       a.shop_id as shop_id,
       a.linker_id,
       a.strategy_result,
       a.admin_chat_id,
       a.shop_chat_id,
       a.content_type,
       a.content,
       a.pkl,
       a.tuse_opt_ser_no,
       a.tuse_msg_time,
       a.fail_type,
       a.fail_reason,
       a.tuse_msg_num,
       a.second_push as is_second_push,
       a.start_time as touch_task_detail_start_time,
       a.fail_time as touch_task_detail_fail_time,
       a.create_time as touch_task_detail_create_time,
       a.edit_time as touch_task_detail_edit_time,
       b.touch_task_create_time,
       cast(j.id as string) as qw_msg_id,
       a.ab_test_group as touch_task_detail_ab_test_group,
       a.ab_test_group_id as touch_task_detail_ab_test_group_id,
       task_instance_id,
       file_name
FROM (
    SELECT *,
           row_number() OVER (PARTITION BY admin_chat_id, shop_chat_id, detail_status, content, nvl(substr(tuse_msg_time, 1, 8), substr(qw_msg_time, 1, 8)) ORDER BY tuse_msg_time, id) as same_msg_row,
           row_number() OVER (PARTITION BY admin_chat_id, shop_chat_id, detail_status, file_title, file_path, nvl(substr(tuse_msg_time, 1, 8), substr(qw_msg_time, 1, 8)) ORDER BY tuse_msg_time, id) as xcx_same_msg_row,
           replace(replace(t1.content, '[', ''), ']', '') as content_join
    FROM (
        SELECT *,
               get_json_object(get_json_object(file_name, '$.material.content'), '$.id') as file_id,
               get_json_object(file_name, '$.miniProgramTitle') as file_title,
               get_json_object(file_name, '$.miniProgramPath') as file_path
        FROM dwd_touch_task_detail_d
        WHERE dayid = '${v_date}'
        AND is_deleted = 0
        AND substr(create_time, 1, 8) <= '${v_date}'
    ) t1
) a
LEFT JOIN (
    SELECT *
    FROM dim_ytj_sel_touch_task_d
    WHERE dayid = '${v_date}'
) b ON a.task_id = b.touch_task_id
LEFT JOIN qw_tmp j ON a.admin_chat_id = j.admin_chat_id AND a.shop_chat_id = j.shop_chat_id
                   AND a.content_join = j.adjust_content AND abs(yt_date_diff(nvl(a.qw_msg_time, a.tuse_msg_time), j.msg_time, 'seconds')) <= 300 --间隔时间在两分钟内
                   AND nvl(substr(a.qw_msg_time, 1, 8), substr(a.tuse_msg_time, 1, 8)) = substr(j.msg_time, 1, 8) -- 同一天的
                   AND a.same_msg_row = j.qw_same_msg_row AND a.detail_status = 2 -- 发送成功
DISTRIBUTE BY if(a.content IS NULL OR a.content = '今日好货，进入小程序直达！', cast(rand()* 100 as BIGINT), a.content)
SORT BY a.content