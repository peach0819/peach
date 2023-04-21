with plan as (
    SELECT *,
           get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value') as calculate_date_value,
           get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.operator') as calculate_date_operator,
           get_json_object(get_json_object(filter_config_json,'$.item_style'),'$.value') as item_style_value,
           get_json_object(get_json_object(filter_config_json,'$.item_style'),'$.operator') as item_style_operator,
           get_json_object(get_json_object(filter_config_json,'$.bigbd_shop_flag'),'$.value') as bigbd_shop_flag_value,
           get_json_object(get_json_object(filter_config_json,'$.bigbd_shop_flag'),'$.operator') as bigbd_shop_flag_operator,
           get_json_object(get_json_object(filter_config_json,'$.sp_order_flag'),'$.value') as sp_order_flag_value,
           get_json_object(get_json_object(filter_config_json,'$.sp_order_flag'),'$.operator') as sp_order_flag_operator,
           get_json_object(get_json_object(filter_config_json,'$.special_order_flag'),'$.value') as special_order_flag_value,
           get_json_object(get_json_object(filter_config_json,'$.special_order_flag'),'$.operator') as special_order_flag_operator,
           get_json_object(get_json_object(filter_config_json,'$.category_first'),'$.value') as category_first_value,
           get_json_object(get_json_object(filter_config_json,'$.category_first'),'$.operator') as category_first_operator,
           get_json_object(get_json_object(filter_config_json,'$.category_second'),'$.value') as category_second_value,
           get_json_object(get_json_object(filter_config_json,'$.category_second'),'$.operator') as category_second_operator,
           get_json_object(get_json_object(filter_config_json,'$.brand'),'$.value') as brand_value,
           get_json_object(get_json_object(filter_config_json,'$.brand'),'$.operator') as brand_operator,
           get_json_object(get_json_object(filter_config_json,'$.item'),'$.value') as item_value,
           get_json_object(get_json_object(filter_config_json,'$.item'),'$.operator') as item_operator,
           get_json_object(get_json_object(filter_config_json,'$.shop'),'$.value') as shop_value,
           get_json_object(get_json_object(filter_config_json,'$.shop'),'$.operator') as shop_operator,
           get_json_object(get_json_object(filter_config_json,'$.store_type'),'$.value') as store_type_value,
           get_json_object(get_json_object(filter_config_json,'$.store_type'),'$.operator') as store_type_operator,
           get_json_object(get_json_object(filter_config_json,'$.war_area'),'$.value') as war_area_value,
           get_json_object(get_json_object(filter_config_json,'$.war_area'),'$.operator') as war_area_operator,
           get_json_object(get_json_object(filter_config_json,'$.bd_area'),'$.value') as bd_area_value,
           get_json_object(get_json_object(filter_config_json,'$.bd_area'),'$.operator') as bd_area_operator,
           get_json_object(get_json_object(filter_config_json,'$.manage_area'),'$.value') as manage_area_value,
           get_json_object(get_json_object(filter_config_json,'$.manage_area'),'$.operator') as manage_area_operator,
           get_json_object(get_json_object(filter_config_json,'$.new_sign_line'),'$.value') as new_sign_line_value,
           get_json_object(get_json_object(filter_config_json,'$.new_sign_line'),'$.operator') as new_sign_line_operator,
           get_json_object(get_json_object(filter_config_json,'$.freeze_sales_team'),'$.value') as freeze_sales_team_value,
           get_json_object(get_json_object(filter_config_json,'$.freeze_sales_team'),'$.operator') as freeze_sales_team_operator,
           get_json_object(get_json_object(filter_config_json,'$.sales_team'),'$.value') as sales_team_value,
           get_json_object(get_json_object(filter_config_json,'$.sales_team'),'$.operator') as sales_team_operator,
           get_json_object(get_json_object(filter_config_json,'$.shop_group'),'$.value') as shop_group_value,
           get_json_object(get_json_object(filter_config_json,'$.shop_group'),'$.operator') as shop_group_operator,
           replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),',')[0],'[',''),'\"',''),'-','') as calculate_date_value_start,
           replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),',')[1],']',''),'\"',''),'-','') as calculate_date_value_end,
           replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.new_sign_line'),'$.value'),'\"',''),'[',''),']','') as new_sign_line,
           replace(replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),']',''),'\"',''),'[',''),',','~') as plan_pay_time,
           get_json_object(get_json_object(filter_config_json,'$.filter_user'),'$.value') as filter_user_value,
           get_json_object(get_json_object(filter_config_json,'$.filter_user'),'$.operator') as filter_user_operator,
           replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.grant_user'),'$.value'),'\"',''),'[',''),']','') as grant_user,
           get_json_object(get_json_object(filter_config_json,'$.dept'),'$.value') as dept_value,
           get_json_object(get_json_object(filter_config_json,'$.dept'),'$.operator') as dept_operator
    FROM yt_crm.dw_bounty_plan_schedule_d
    WHERE array_contains(split(forward_date, ','), '${v_date}')
    AND ('@@{supply_mode}' = 'not_supply' OR array_contains(split(supply_date, ','), '${supply_date}'))
    AND bounty_rule_type = 2
),

--门店分组表
shop_group_mapping as (
    SELECT shop_id as group_shop_id,
           concat_ws(',' , sort_array(collect_set(cast(group_id as string)))) as shop_group
    FROM ytdw.ads_dmp_group_data_d
    WHERE dayid='${v_date}'
    group by shop_id
),

sign as (
    select /*+ mapjoin(plan) */
           plan.no as plan_no,
           item_id,
           item_name,
           brand_id,
           brand_name,
           item_style,
           item_style_name,
           shop_id,
           shop_name,
           store_type,
           store_type_name,
           war_zone_id,
           war_zone_name,
           war_zone_dep_id,
           war_zone_dep_name,
           area_manager_id,
           area_manager_name,
           area_manager_dep_id,
           area_manager_dep_name,
           bd_manager_id,
           bd_manager_name,
           bd_manager_dep_id,
           bd_manager_dep_name,
           service_user_id_freezed,
           service_department_id_freezed,
           service_user_name_freezed,
           service_feature_name_freezed,
           service_job_name_freezed,
           service_department_name_freezed,
           min(pay_time) as new_sign_time,
           min(pay_day) as new_sign_day,          --新签日期
           shop_item_sign_day,--门店商品新签时间
           sum(gmv_less_refund) as gmv_less_refund,       --实货gmv-退款
           sum(gmv) as gmv,--实货gmv,
           sum(pay_amount) as pay_amount,--实货支付金额
           sum(pay_amount_less_refund) as pay_amount_less_refund,--实货支付金额-退款
           sum(refund_actual_amount) as refund_actual_amount,--实货退款
           sum(refund_retreat_amount) as refund_retreat_amount,--实货清退金额
           case when sum(gmv_less_refund) >= new_sign_line then '是' else '否' end as is_over_sign_line--是否满足新签门槛
    from (select * from yt_crm.dw_salary_sign_rule_public_mid_v2_d where dayid = '${v_date}') ord
    cross join plan ON 1 = 1
    LEFT JOIN shop_group_mapping ON ord.shop_id = shop_group_mapping.group_shop_id
    where shop_item_sign_day between calculate_date_value_start and calculate_date_value_end
    and pay_day <= calculate_date_value_end
    and ytdw.simple_expr(sale_team_id, 'in', sales_team_value) = (case when sales_team_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(item_style_name, 'in', item_style_value) = (case when item_style_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(category_id_first, 'in', category_first_value) = (case when category_first_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(category_id_second, 'in', category_second_value) = (case when category_second_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(brand_id, 'in', brand_value) = (case when brand_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(item_id, 'in', item_value) = (case when item_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(war_zone_dep_id, 'in', war_area_value) = (case when war_area_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(area_manager_dep_id, 'in', bd_area_value) = (case when bd_area_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(bd_manager_dep_id, 'in', manage_area_value) = (case when manage_area_operator = '=' then 1 else 0 end)
    and if(shop_group_mapping.shop_group = '' OR plan.shop_group_value = '', 0, ytdw.simple_expr(substr(plan.shop_group_value, 2, length(plan.shop_group_value) - 2), 'in', concat('[', shop_group_mapping.shop_group, ']'))) = (case when shop_group_operator = '=' then 1 else 0 end)
    group by plan.no,
             item_id,
             item_name,
             brand_id,
             brand_name,
             item_style,
             item_style_name,
             shop_id,
             shop_name,
             store_type,
             store_type_name,
             war_zone_id,
             war_zone_name,
             war_zone_dep_id,
             war_zone_dep_name,
             area_manager_id,
             area_manager_name,
             area_manager_dep_id,
             area_manager_dep_name,
             bd_manager_id,
             bd_manager_name,
             bd_manager_dep_id,
             bd_manager_dep_name,
             service_user_id_freezed,
             service_department_id_freezed,
             service_user_name_freezed,
             service_feature_name_freezed,
             service_job_name_freezed,
             service_department_name_freezed,
             shop_item_sign_day,
             plan.new_sign_line
),

big_bd_manager as (
    select dept_id,
           user_id,
           user_real_name,
           row_number() over(partition by dept_id order by create_time desc) as rn
    from ytdw.dim_usr_user_d
    where dayid='${v_date}'
    AND dept_id is not null
    AND user_status = 1
    AND job_id = 128
),

user_admin as (
    select user_id,
           user_real_name,
           dept_id,
           substr(leave_time,1,8) as leave_time
    from ytdw.dim_usr_user_d
    where dayid='${v_date}'
),

before_cur as (
    select from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
           from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,

           --方案信息
           '当月方案' as plan_type,
           plan.month as plan_month,
           plan.plan_pay_time,
           plan.name as plan_name,
           plan.biz_group_id as plan_group_id,
           plan.biz_group_name as plan_group_name,
           plan.bounty_indicator_name as sts_target_name,

           --数据信息
           item_id,
           item_name,
           brand_id,
           brand_name,
           item_style,
           item_style_name,
           shop_id,
           shop_name,
           store_type,
           store_type_name,
           war_zone_id,
           war_zone_name,
           war_zone_dep_id,
           war_zone_dep_name,
           area_manager_id,
           area_manager_name,
           area_manager_dep_id,
           area_manager_dep_name,
           bd_manager_id,
           bd_manager_name,
           bd_manager_dep_id,
           bd_manager_dep_name,
           service_user_id_freezed,
           service_department_id_freezed,
           service_user_name_freezed,
           service_feature_name_freezed,
           service_job_name_freezed,
           service_department_name_freezed,
           new_sign_time,
           new_sign_day,
           row_number() over (partition by plan_no,shop_id,item_id,is_over_sign_line order by new_sign_time) as new_sign_rn, --新签时间排名达成
           shop_item_sign_day,
           gmv_less_refund,
           gmv,
           pay_amount,
           pay_amount_less_refund,
           refund_actual_amount,
           refund_retreat_amount,
           new_sign_line,
           is_over_sign_line,
           plan_no,

           --方案信息
           plan.bounty_payout_object_name as grant_object_type,--发放对象类型
           plan.bounty_payout_object_code,
           case when plan.bounty_payout_object_code = 'WAR_ZONE_MANAGE' then war_zone_id
                when plan.bounty_payout_object_code = 'AREA_MANAGER' then area_manager_id
                when plan.bounty_payout_object_code = 'BD_MANAGER' then bd_manager_id
                when plan.bounty_payout_object_code  in('BD','BIG_BD')  then service_user_id_freezed
                when plan.bounty_payout_object_code = 'GRANT_USER' then plan.grant_user
                when plan.bounty_payout_object_code = 'BIG_BD_AREA_MANAGER' then big_bd_manager.user_id
                end as grant_object_user_id,                                                                      --发放对象ID
           case when plan.bounty_payout_object_code = 'WAR_ZONE_MANAGE' then war_zone_name
                when plan.bounty_payout_object_code = 'AREA_MANAGER' then area_manager_name
                when plan.bounty_payout_object_code = 'BD_MANAGER' then bd_manager_name
                when plan.bounty_payout_object_code  in('BD','BIG_BD')  then service_user_name_freezed
                when plan.bounty_payout_object_code = 'GRANT_USER' then null
                when plan.bounty_payout_object_code = 'BIG_BD_AREA_MANAGER' then big_bd_manager.user_real_name
                end as grant_object_user_name,                                                                       --发放对象名称
           case when plan.bounty_payout_object_code = 'WAR_ZONE_MANAGE' then war_zone_dep_id
                when plan.bounty_payout_object_code = 'AREA_MANAGER' then area_manager_dep_id
                when plan.bounty_payout_object_code = 'BD_MANAGER' then bd_manager_dep_id
                when plan.bounty_payout_object_code  in('BD','BIG_BD')  then service_department_id_freezed
                when plan.bounty_payout_object_code = 'GRANT_USER' then null
                when plan.bounty_payout_object_code = 'BIG_BD_AREA_MANAGER' then service_department_id_freezed
                end as grant_object_user_dep_id,                                                                      --发放对象部门ID
           case when plan.bounty_payout_object_code = 'WAR_ZONE_MANAGE' then war_zone_dep_name
                when plan.bounty_payout_object_code = 'AREA_MANAGER' then area_manager_dep_name
                when plan.bounty_payout_object_code = 'BD_MANAGER' then bd_manager_dep_name
                when plan.bounty_payout_object_code  in('BD','BIG_BD')  then service_department_name_freezed
                when plan.bounty_payout_object_code = 'GRANT_USER' then null
                when plan.bounty_payout_object_code = 'BIG_BD_AREA_MANAGER' then service_department_name_freezed
                end as grant_object_user_dep_name,

           plan.filter_user_value,
           plan.filter_user_operator,
           plan.dept_value,
           plan.dept_operator
    FROM sign
    INNER JOIN plan ON sign.plan_no = plan.no
    LEFT JOIN big_bd_manager ON sign.service_department_id_freezed = big_bd_manager.dept_id AND big_bd_manager.rn = 1
),

cur as (
    SELECT *
    FROM before_cur
    WHERE ytdw.simple_expr(grant_object_user_id, 'in', filter_user_value) = (case when filter_user_operator = '=' then 1 else 0 end)
    AND ytdw.simple_expr(grant_object_user_dep_id, 'in', dept_value) = (case when dept_operator = '=' then 1 else 0 end)
)

insert overwrite table dw_salary_sign_item_rule_public_d partition (dayid='${v_date}',pltype='cur')
SELECT update_time,
       update_month,
       plan_type,
       plan_month,
       plan_pay_time,
       plan_name,
       plan_group_id,
       plan_group_name,
       item_id,
       item_name,
       brand_id,
       brand_name,
       item_style,
       item_style_name,
       shop_id,
       shop_name,
       store_type,
       store_type_name,
       war_zone_id,
       war_zone_name,
       war_zone_dep_id,
       war_zone_dep_name,
       area_manager_id,
       area_manager_name,
       area_manager_dep_id,
       area_manager_dep_name,
       bd_manager_id,
       bd_manager_name,
       bd_manager_dep_id,
       bd_manager_dep_name,
       service_user_id_freezed,
       service_department_id_freezed,
       service_user_name_freezed,
       service_feature_name_freezed,
       service_job_name_freezed,
       service_department_name_freezed,
       new_sign_time,
       new_sign_day,
       new_sign_rn,
       shop_item_sign_day,
       gmv_less_refund,
       gmv,
       pay_amount,
       pay_amount_less_refund,
       refund_actual_amount,
       refund_retreat_amount,
       new_sign_line,
       is_over_sign_line,
       if(new_sign_rn = 1, '是', '否') as is_first_sign,--是否首次达成
       if(gmv_less_refund >= new_sign_line and new_sign_rn = 1, '是', '否') as is_succ_sign,--是否新签成功
       grant_object_type,
       grant_object_user_id,
       nvl(cur.grant_object_user_name, user_admin.user_real_name),
       nvl(cur.grant_object_user_dep_id, user_admin.dept_id),
       grant_object_user_dep_name,
       user_admin.leave_time as leave_time,
       if(user_admin.leave_time is not null and new_sign_day > user_admin.leave_time, '是', '否') as is_leave,
       sts_target_name,
       plan_no
FROM cur
LEFT JOIN user_admin on cur.grant_object_user_id = user_admin.user_id
WHERE cur.grant_object_user_id is not null

UNION ALL

SELECT update_time,
       update_month,
       plan_type,
       plan_month,
       plan_pay_time,
       plan_name,
       plan_group_id,
       plan_group_name,
       item_id,
       item_name,
       brand_id,
       brand_name,
       item_style,
       item_style_name,
       shop_id,
       shop_name,
       store_type,
       store_type_name,
       war_zone_id,
       war_zone_name,
       war_zone_dep_id,
       war_zone_dep_name,
       area_manager_id,
       area_manager_name,
       area_manager_dep_id,
       area_manager_dep_name,
       bd_manager_id,
       bd_manager_name,
       bd_manager_dep_id,
       bd_manager_dep_name,
       service_user_id_freezed,
       service_department_id_freezed,
       service_user_name_freezed,
       service_feature_name_freezed,
       service_job_name_freezed,
       service_department_name_freezed,
       new_sign_time,
       new_sign_day,
       new_sign_rn,
       shop_item_sign_day,
       gmv_less_refund,
       gmv,
       pay_amount,
       pay_amount_less_refund,
       refund_actual_amount,
       refund_retreat_amount,
       new_sign_line,
       is_over_sign_line,
       is_first_sign,
       is_succ_sign,
       grant_object_type,
       grant_object_user_id,
       grant_object_user_name,
       grant_object_user_dep_id,
       grant_object_user_dep_name,
       leave_time,
       is_leave,
       sts_target_name,
       planno
FROM (
    SELECT *
    FROM yt_crm.dw_salary_sign_item_rule_public_d
    WHERE dayid = '${v_date}'
    AND pltype='cur'
) history
LEFT JOIN (
    SELECT no FROM plan
) cur_plan ON history.planno = cur_plan.no
WHERE cur_plan.no is null