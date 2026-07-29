--@exclude_input=prod_mdson_dev.inf_mdson_white_list_empno
WITH user as (
    SELECT user_id,
           user_real_name,
           job_id,
           job_name,
           channel_id,
           channel_name,
           empno,
           substr(nvl(join_time, create_time), 1, 7) as join_month
    FROM prod_mdson.dim_user_d
    WHERE dayid = '${v_date}'
    AND account_type = 1
    AND is_deleted = 0
    AND dismiss_status = 0
    AND substr(nvl(join_time, create_time), 1, 7) <= '${v_opt_month}'
),

--实际工作天数
workday as (
    SELECT user_id,
           sum(if(data_month = '${v_opt_month}', actual_day_num, 0)) as month_actual_day_num,
           sum(if(data_month = '${v_opt_month}', actual_day_num, 0)) / sum(if(data_month = '${v_opt_month}', total_day_num, 0)) as month_discount_rate,
           sum(actual_day_num) as quarter_actual_day_num
    FROM prod_mdson.ads_crm_visit_user_workday_d
    WHERE dayid = '${v_date}'
    group by user_id
),

--包含非GT的渠道门店的服务人员 ，认定为多渠道
user_channel_cnt as (
    SELECT distinct freeze_server_id as user_id
    FROM prod_mdson.ads_crm_visit_service_obj_d
    WHERE dayid = '${v_date}'
    AND service_obj_type = 1 --仅统计门店
    AND freeze_server_id is not null --有所有人的门店
    AND channel_type != 'GT'
),

--当月目标拜访店次
target as (
    SELECT user.user_id,

           --门店拜访总频次
           nvl(round(nvl(white_list.change_target, target_content.indicator_value) * workday.month_discount_rate, 0), 0) as month_visit_target,

           --门店拜访总门店数
           nvl(white_list1.change_target, 40) * workday.month_discount_rate as month_visit_obj_target
    FROM user
    LEFT JOIN workday ON workday.user_id = user.user_id
    LEFT JOIN (
        SELECT id,
               role_id,
               channel_id
        FROM prod_mdson.dwd_crm_visit_target_d
        WHERE dayid = '${v_date}'
        AND inuse = 0
        AND is_deleted = 0
        AND data_month = '${v_opt_month}'
        AND indicator_id = 2
        AND service_obj_type = 1
    ) target ON user.channel_id = target.channel_id AND user.job_id = target.role_id
    LEFT JOIN (
        SELECT target_id,
               indicator_value
        FROM (
            SELECT target_id,
                   indicator_value,
                   create_time,
                   row_number() OVER (PARTITION BY target_id ORDER BY create_time DESC) flag
            FROM prod_mdson.dwd_crm_visit_target_content_d
            WHERE dayid = '${v_date}'
            AND is_deleted = 0
        )
        WHERE flag = 1
    ) target_content ON target.id = target_content.target_id
    LEFT JOIN (
        SELECT empno,
               change_target
        FROM prod_mdson_dev.inf_mdson_white_list_empno
        WHERE change_indicator = '每月门店/经销商/客户/服务商拜访总频次'
        AND year_month = '${v_cur_month}'
    ) white_list ON user.empno = white_list.empno
    LEFT JOIN (
        SELECT empno,
               change_target
        FROM prod_mdson_dev.inf_mdson_white_list_empno
        WHERE change_indicator = '每月拜访不重复门店/客户/经销商'
        AND year_month = '${v_cur_month}'
    ) white_list1 ON user.empno = white_list1.empno
),

--指标明细数据
detail as (
    SELECT user_id,
           to_json(map_from_entries(collect_list(NAMED_STRUCT('key', indicator_code, 'value', biz_value)))) as biz_value
    FROM (
        SELECT user_id,
               indicator_code,
               to_json(named_struct(
                   'reach_cnt', sum(if(reach = '达标', 1, 0)),
                   'total_cnt', sum(1),
                   'reach_sum', sum(if(reach = '达标', indicator, 0)),
                   'total_sum', sum(indicator)
               )) as biz_value
        FROM prod_mdson.ads_crm_visit_base_detail_d
        WHERE dayid = '${v_date}'
        group by user_id,
                 indicator_code
    ) t1
    group by user_id
),

visible as (
    SELECT user_id,
           visible_config
    FROM prod_mdson.ads_crm_visit_user_indicator_visible_d
    WHERE dayid = '${v_date}'
)

INSERT OVERWRITE TABLE ads_crm_visit_base_summary_d PARTITION (dayid = '${v_date}')
SELECT user.user_id,
       prod_mdson.mdson_indicator_aggregate(
           detail.biz_value,
           to_json(named_struct(
               'dayid', '${v_date}',
               'month_time_progress', 100 * DAYOFMONTH(TO_DATE('${v_date}', 'yyyymmdd')) / DAYOFMONTH(LAST_DAY(TO_DATE('${v_date}', 'yyyymmdd'))),
               'quarter_time_progress', 100 * DATEDIFF(TO_DATE('${v_date}', 'yyyymmdd'), DATETRUNC(TO_DATE('${v_date}', 'yyyymmdd'), 'quarter')) + 1 / DATEDIFF(DATEADD(DATETRUNC(TO_DATE('${v_date}', 'yyyymmdd'), 'quarter'), 3, 'mm'), DATETRUNC(TO_DATE('${v_date}', 'yyyymmdd'), 'quarter'), 'dd'),
               'job_name', if(user.user_real_name = '胡志伟', '城市群负责人', user.job_name),
               'join_month', join_month,  --入职月份
               'month_actual_day_num', workday.month_actual_day_num,  --本月实际工作日
               'quarter_actual_day_num', workday.quarter_actual_day_num,  --本季度实际工作日
               'month_visit_target', target.month_visit_target,         --当月目标拜访次数
               'month_visit_obj_target', target.month_visit_obj_target,   --当月目标拜访门店数
               'is_many_channel_type', if(user_channel_cnt.user_id is not null, 1, 0), --是否多渠道服务人员
               'visible', visible.visible_config
           ))
       ) as biz_value
FROM user
LEFT JOIN detail ON user.user_id = detail.user_id
LEFT JOIN workday ON user.user_id = workday.user_id
LEFT JOIN target ON user.user_id = target.user_id
LEFT JOIN user_channel_cnt ON user.user_id = user_channel_cnt.user_id
LEFT JOIN visible ON user.user_id = visible.user_id