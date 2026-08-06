--@exclude_input=prod_mdson_dev.inf_mdson_white_list_empno
--@exclude_input=prod_mdson.inf_mdson_vacation_np
--odps sql
--********************************************************************--
--author:hipac_shuai.wu12190
--create time:2026-07-05 23:04:42
--********************************************************************--
-- 20260705：系统人员目标表v2
WITH user_info as (
    SELECT user_id,
           user_real_name,
           job_id,
           job_name,
           channel_name,
           department_charger_id,
           department_charger_name,
           channel_id
    FROM dim_user_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
    AND user_status = 1
),

visit_target_info as (
    SELECT id,
           role_id,
           channel_id,
           service_obj_type,
           chain_id,
           data_month,
           indicator_id,
           replace(data_month, "-", "") as data_month_id
    FROM dwd_crm_visit_target_d
    WHERE dayid = '${v_date}'
    AND inuse = 0
    AND is_deleted = 0
),

visit_indicator_info as (
    SELECT id,
           indicator_name
    FROM dwd_crm_visit_indicator_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
),

visit_target_content_info as (
    SELECT target_id,
           indicator_value
    FROM (
        SELECT target_id,
               indicator_value,
               create_time,
               row_number() OVER (PARTITION BY target_id ORDER BY create_time DESC)flag
        FROM dwd_crm_visit_target_content_d
        WHERE dayid = '${v_date}'
        AND is_deleted = 0
    )
    WHERE flag = 1
),

work_day_info as (
    SELECT day_id,
           is_work_day
    FROM dwd_work_day_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
),

work_day_count as (
    SELECT substr(day_id, 1, 6) as month_id,
           sum(if(is_work_day = 1, 1, 0)) as work_day_num
    FROM work_day_info
    GROUP BY substr(day_id, 1, 6)
),

vacation_info as (
    SELECT user_id,
           vacation_begin_time,
           vacation_end_time
    FROM dwd_crm_vacation_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
    AND vacation_status != 2
),

udaf as (
    SELECT user_id,
           vacation_begin_time,
           vacation_end_time,
           t.vacation_date as mid_date
    FROM vacation_info LATERAL VIEW yt_date_flat_map(vacation_begin_time, vacation_end_time) t as vacation_date
),

vacation_work_day_base as (
    SELECT user_id,
           mid_date,
           is_work_day,
           substr(mid_date, 1, 6) as month_id -- 预防跨月请假
    FROM (
        SELECT user_id,
               replace(mid_date, '-', '') mid_date
        FROM udaf
    ) tmp
    LEFT JOIN work_day_info ON tmp.mid_date = work_day_info.day_id
),

vacation_work_day_collect as (
    SELECT user_id,
           month_id,
           sum(if(is_work_day = 1, 1, 0)) data_month_vacation_days
    FROM vacation_work_day_base
    GROUP BY user_id,
             month_id
) -- 20260622：增加节假日及休假折算部分
-- 节假日
,

vacation_info_1 as ( -- 节假日
    SELECT year_month,
           total_days,
           work_days,
           vacation_days
    FROM prod_mdson.inf_mdson_vacation_np
) -- 休假
,

leave_info as ( -- 系统请假信息
    SELECT user_id,
           vacation_begin_time,
           vacation_end_time
    FROM prod_mdson.dwd_crm_vacation_d
    WHERE dayid = '${v_date}'
    AND is_deleted = 0
    AND vacation_status != 2
),

udaf_1 as ( -- 请假明细日期
    SELECT user_id,
           vacation_begin_time,
           vacation_end_time,
           t.vacation_date as mid_date
    FROM leave_info LATERAL VIEW yt_date_flat_map(vacation_begin_time, vacation_end_time) t as vacation_date
),

user_leave as ( -- 用户请假汇总
    SELECT user_id,
           substr(mid_date, 1, 7) as year_month,
           count(DISTINCT mid_date) leave_days
    FROM udaf_1
    GROUP BY user_id,
             substr(mid_date, 1, 7)
) -- 20260623：增加人员白名单部分
,

white_list_empno as ( -- 人员白名单
    SELECT concat(substr(year_month, 1, 4), '-', substr(year_month, 5, 6)) as year_month,
           t1.empno,
           t2.user_id,
           change_indicator,
           change_target
    FROM prod_mdson_dev.inf_mdson_white_list_empno t1
    LEFT JOIN ( -- 关联人员ID
        SELECT user_id,
       (        CASE WHEN instr(empno, '-') > 0 THEN split(empno, '-')[1] ELSE empno END) as empno
        FROM prod_mdson.dim_user_d
        WHERE dayid = '${v_date}'
        AND account_type = 1 -- 员工账号
        AND is_deleted = 0 -- 未删除
        AND dismiss_status = 0 -- 未离职
    ) t2 ON t1.empno = t2.empno
    WHERE change_indicator = '每月门店/经销商/客户/服务商拜访总频次'
) -- 主查询


INSERT OVERWRITE TABLE ads_crm_user_visit_target_d_v2 PARTITION (dayid = '${v_month}')
SELECT user_info.user_id as user_id,
       user_info.user_real_name as user_name,
       user_info.job_name as job_name,
       user_info.channel_name as channel_name,
       user_info.department_charger_id as department_charger_id,
       user_info.department_charger_name as department_charger_name,
       visit_target_info.service_obj_type as service_obj_type,
       visit_target_info.chain_id as chain_id,
       visit_target_info.data_month as data_month,
       visit_target_info.indicator_id as indicator_id,
       visit_indicator_info.indicator_name as indicator_name,
       visit_target_content_info.indicator_value as indicator_value,
       work_day_count.work_day_num as data_month_work_days,
       nvl(vacation_info_1.vacation_days, 0) as data_month_vacation_days,
       CASE WHEN nvl(vacation_work_day_collect.data_month_vacation_days, 0) = 0 AND data_month = '2025-10' THEN if(visit_target_content_info.indicator_value > 1, ceil(visit_target_content_info.indicator_value * (31 - 8) / 31), round(visit_target_content_info.indicator_value, 4))
            WHEN nvl(vacation_work_day_collect.data_month_vacation_days, 0) = 0 THEN if(visit_target_content_info.indicator_value > 1, ceil(visit_target_content_info.indicator_value), round(visit_target_content_info.indicator_value, 4))
            WHEN nvl(vacation_work_day_collect.data_month_vacation_days, 0) > 0 THEN if((visit_target_content_info.indicator_value * (work_day_count.work_day_num - nvl(vacation_work_day_collect.data_month_vacation_days, 0)) / work_day_count.work_day_num) > 1, ceil(visit_target_content_info.indicator_value * (work_day_count.work_day_num - nvl(vacation_work_day_collect.data_month_vacation_days, 0)) / work_day_count.work_day_num), round(visit_target_content_info.indicator_value * (work_day_count.work_day_num - nvl(vacation_work_day_collect.data_month_vacation_days, 0)) / work_day_count.work_day_num, 4)) END as actual_indicator_value,
       round(coalesce(white_list_empno.change_target, visit_target_content_info.indicator_value) * (if(vacation_info_1.total_days - vacation_info_1.vacation_days - coalesce(user_leave.leave_days, 0) < 0, 0, vacation_info_1.total_days - vacation_info_1.vacation_days - coalesce(user_leave.leave_days, 0)) / nullif(vacation_info_1.total_days, 0)), 0) as actual_indicator_value_1,
       if(vacation_info_1.total_days - vacation_info_1.vacation_days - coalesce(user_leave.leave_days, 0) < 0, 0, vacation_info_1.total_days - vacation_info_1.vacation_days - coalesce(user_leave.leave_days, 0)) / nullif(vacation_info_1.total_days, 0) as discount_rate
FROM user_info
JOIN visit_target_info ON user_info.channel_id = visit_target_info.channel_id AND user_info.job_id = visit_target_info.role_id
LEFT JOIN visit_indicator_info ON visit_target_info.indicator_id = visit_indicator_info.id
LEFT JOIN visit_target_content_info ON visit_target_info.id = visit_target_content_info.target_id
LEFT JOIN work_day_count ON visit_target_info.data_month_id = work_day_count.month_id
LEFT JOIN vacation_work_day_collect ON user_info.user_id = vacation_work_day_collect.user_id AND visit_target_info.data_month_id = vacation_work_day_collect.month_id
LEFT JOIN vacation_info_1 ON visit_target_info.data_month = vacation_info_1.year_month
LEFT JOIN user_leave ON visit_target_info.data_month = user_leave.year_month AND user_info.user_id = user_leave.user_id
LEFT JOIN white_list_empno ON visit_target_info.data_month = white_list_empno.year_month AND user_info.user_id = white_list_empno.user_id;