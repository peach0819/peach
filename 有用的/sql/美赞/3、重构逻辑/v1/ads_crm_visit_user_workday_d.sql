--@exclude_input=prod_mdson.inf_mdson_vacation_np
WITH user as (
    SELECT user_id
    FROM prod_mdson.dim_user_d
    WHERE dayid = '${v_date}'
    AND user_status = 1 --启用
),

data_month as (
    SELECT substr(add_months(DATETRUNC(TO_DATE('${v_date}', 'yyyymmdd'), 'quarter'), 0), 1, 7) as data_month
    UNION ALL
    SELECT substr(add_months(DATETRUNC(TO_DATE('${v_date}', 'yyyymmdd'), 'quarter'), 1), 1, 7) as data_month
    UNION ALL
    SELECT substr(add_months(DATETRUNC(TO_DATE('${v_date}', 'yyyymmdd'), 'quarter'), 2), 1, 7) as data_month
),

--人员请假信息
vacation as (
    SELECT user_id,
           substr(vacation_date, 1, 7) as data_month,
           count(distinct vacation_date) as vacation_day_num
    FROM (
        SELECT user_id,
               vacation_date
        FROM prod_mdson.dwd_crm_vacation_d
        LATERAL VIEW yt_date_flat_map(vacation_begin_time, vacation_end_time) t as vacation_date
        WHERE dayid = '${v_date}'
        AND is_deleted = 0
        AND vacation_status != 2
    ) t
    group by user_id,
             substr(vacation_date, 1, 7)
),

--美赞提供的天数定义
day_info as (
    SELECT year_month as data_month,
           total_days as total_day_num,   --总天数
           vacation_days as holiday_day_num   --节假日天数
    FROM prod_mdson.inf_mdson_vacation_np
)

-- 休假折算逻辑
-- 当月总天数 - 当月节假日天数 - 当月请假天数 / 当月总天数
INSERT OVERWRITE TABLE ads_crm_visit_user_workday_d PARTITION (dayid = '${v_date}')
SELECT /*+ mapjoin(user) */
       user.user_id,
       data_month.data_month,
       nvl(day_info.total_day_num, 0) as total_day_num,
       nvl(day_info.holiday_day_num, 0) as holiday_day_num,
       nvl(vacation.vacation_day_num, 0) as vacation_day_num,
       GREATEST(nvl(day_info.total_day_num, 0) - nvl(day_info.holiday_day_num, 0) - nvl(vacation.vacation_day_num, 0), 0) as actual_day_num
FROM user
CROSS JOIN data_month ON 1 = 1
LEFT JOIN day_info ON data_month.data_month = day_info.data_month
LEFT JOIN vacation ON user.user_id = vacation.user_id AND data_month.data_month = vacation.data_month