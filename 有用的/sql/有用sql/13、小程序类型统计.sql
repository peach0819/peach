SELECT count(distinct task_id) as task_count,
       count(case when mini_program_id = 1 then 1 else null end) as price_tab_count,
       count(case when mini_program_id = 2 then 1 else null end) as item_detail_count,
       count(case when mini_program_id = 3 then 1 else null end) as ytms_count
FROM (
    SELECT task_id, get_json_object(file_name, '$.miniProgramId') as mini_program_id
    FROM dwd_touch_task_detail_d
    WHERE dayid = '$v_date'
      AND content_type = 6
      AND task_id > 7000
      AND detail_status = 2
) t