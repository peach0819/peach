with plan as (
    SELECT *,
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
           get_json_object(get_json_object(filter_config_json,'$.category_third'),'$.value') as category_third_value,
           get_json_object(get_json_object(filter_config_json,'$.category_third'),'$.operator') as category_third_operator,
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
           get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value') as calculate_date,
           yt_crm.plan_calculate_date(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'), 'max') as calculate_date_value_end,
           replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.new_sign_line'),'$.value'),'\"',''),'[',''),']','') as new_sign_line,
           get_json_object(get_json_object(filter_config_json,'$.filter_user'),'$.value') as filter_user_value,
           get_json_object(get_json_object(filter_config_json,'$.filter_user'),'$.operator') as filter_user_operator,
           replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.grant_user'),'$.value'),'\"',''),'[',''),']','') as grant_user,
           get_json_object(get_json_object(filter_config_json,'$.unback_brand'),'$.value') as unback_brand_value,
           get_json_object(get_json_object(filter_config_json,'$.unback_brand'),'$.operator') as unback_brand_operator,
           replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.merge_brand'),'$.value'),'\"',''),'[',''),']','') as merge_brand,
           get_json_object(get_json_object(filter_config_json,'$.dept'),'$.value') as dept_value,
           get_json_object(get_json_object(filter_config_json,'$.dept'),'$.operator') as dept_operator,
           get_json_object(get_json_object(filter_config_json,'$.brand_tag'),'$.value') as brand_tag_value,
           get_json_object(get_json_object(filter_config_json,'$.brand_tag'),'$.operator') as brand_tag_operator,
           get_json_object(get_json_object(filter_config_json,'$.brand_type'),'$.value') as brand_type_value,
           get_json_object(get_json_object(filter_config_json,'$.brand_type'),'$.operator') as brand_type_operator,
           get_json_object(get_json_object(filter_config_json,'$.brand_key'),'$.value') as brand_key_value,
           get_json_object(get_json_object(filter_config_json,'$.brand_key'),'$.operator') as brand_key_operator
    FROM yt_crm.dw_bounty_plan_schedule_d
    WHERE array_contains(split(backward_date, ','), '${v_date}')
    AND ('@@{supply_mode}' = 'not_supply' OR array_contains(split(supply_date, ','), '${supply_date}'))
    AND bounty_rule_type = 3
),

--门店分组表
shop_group_mapping as (
    SELECT shop_id as group_shop_id,
           concat_ws(',' , sort_array(collect_set(cast(group_id as string)))) as shop_group,
           dayid
    FROM ytdw.ads_dmp_group_data_d
    group by dayid, shop_id
),

ord as (
    select *,
           if(brand_series_id is null, brand_id, concat(brand_id, '_', brand_series_id)) as brand_key
    from yt_crm.dw_salary_sign_rule_public_mid_v2_d
),

refund as (
    select dayid,
           order_id,
           sum(refund_actual_amount) as refund_actual_amount,
           sum(case when multiple_refund = 10 then refund_actual_amount else 0 end) as refund_retreat_amount
    from ytdw.dw_afs_order_refund_new_d --（后期通过type识别清退金额）
    where refund_status=9
    group by order_id, dayid
),

before_sign as (
    select /*+ mapjoin(plan) */
           plan.*,
           ord.dayid,
           ord.item_style,
           ord.item_style_name,
           ord.shop_id,
           ord.shop_name,
           ord.store_type,
           ord.store_type_name,
           ord.war_zone_id,
           ord.war_zone_name,
           ord.war_zone_dep_id,
           ord.war_zone_dep_name,
           ord.area_manager_id,
           ord.area_manager_name,
           ord.area_manager_dep_id,
           ord.area_manager_dep_name,
           ord.bd_manager_id,
           ord.bd_manager_name,
           ord.bd_manager_dep_id,
           ord.bd_manager_dep_name,
           ord.service_user_id_freezed,
           ord.service_department_id_freezed,
           ord.service_user_name_freezed,
           ord.service_feature_name_freezed,
           ord.service_job_name_freezed,
           ord.service_department_name_freezed,
           ord.pay_time,
           ord.pay_day,
           ord.gmv - nvl(refund.refund_actual_amount, 0) as gmv_less_refund,
           ord.gmv,
           ord.pay_amount,
           ord.pay_amount - nvl(refund.refund_actual_amount, 0) as pay_amount_less_refund,
           nvl(refund.refund_actual_amount, 0) as refund_actual_amount,
           nvl(refund.refund_actual_amount, 0) as refund_retreat_amount,
           ord.sale_team_id,
           ord.category_id_first,
           ord.category_id_second,
           ord.category_id_third,
           ord.item_id,
           ord.brand_tag_code,
           ord.brand_type,
           nvl(shop_group_mapping.shop_group, ord.shop_group) as shop_group,

           --加工字段
           if(plan.merge_brand = '是', -1, brand_id) as brand_id,
           if(plan.merge_brand = '是', '-1', yt_crm.brand_series_match(brand_id, brand_series_id, plan.brand_key_value)) as brand_key,
           if(plan.merge_brand = '是', '合并品牌', brand_name) as brand_name,
           if(if(plan.merge_brand = '是', '-1', yt_crm.brand_series_match(brand_id, brand_series_id, plan.brand_key_value)) = ord.brand_key, nvl(shop_brand_series_sign_day, shop_brand_sign_day), shop_brand_sign_day) as shop_brand_sign_day
    FROM ord
    cross join plan ON ord.dayid = split(plan.backward_date, ',')[0]
    LEFT JOIN shop_group_mapping ON ord.shop_id = shop_group_mapping.group_shop_id AND ord.dayid = shop_group_mapping.dayid
    LEFT JOIN refund ON ord.order_id = refund.order_id AND refund.dayid = if(ytdw.simple_expr(brand_id, 'in', unback_brand_value) = (case when unback_brand_operator = '!=' then 0 else 1 end), ord.dayid, '${v_date}')
),

sign as (
    select dayid,
           no as planno,
           brand_id,
           brand_key,
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
           min(shop_brand_sign_day) as shop_brand_sign_day,  --门店品牌新签时间
           sum(gmv_less_refund) as gmv_less_refund,       --实货gmv-退款
           sum(gmv) as gmv,--实货gmv,
           sum(pay_amount) as pay_amount,--实货支付金额
           sum(pay_amount_less_refund) as pay_amount_less_refund,--实货支付金额-退款
           sum(refund_actual_amount) as refund_actual_amount,--实货退款
           sum(refund_retreat_amount) as refund_retreat_amount,--实货清退金额
           case when sum(gmv_less_refund) >= new_sign_line then '是' else '否' end as is_over_sign_line--是否满足新签门槛
    from before_sign
    where yt_crm.plan_calculate_date(calculate_date, 'between', shop_brand_sign_day) = 'true'
    and pay_day <= calculate_date_value_end
    and ytdw.simple_expr(sale_team_id, 'in', sales_team_value) = (case when sales_team_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(item_style_name, 'in', item_style_value) = (case when item_style_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(category_id_first, 'in', category_first_value) = (case when category_first_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(category_id_second, 'in', category_second_value) = (case when category_second_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(category_id_third, 'in', category_third_value) = (case when category_third_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(brand_id, 'in', brand_value) = (case when brand_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(item_id, 'in', item_value) = (case when item_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(war_zone_dep_id, 'in', war_area_value) = (case when war_area_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(area_manager_dep_id, 'in', bd_area_value) = (case when bd_area_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(bd_manager_dep_id, 'in', manage_area_value) = (case when manage_area_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(brand_tag_code, 'in', brand_tag_value) = (case when brand_tag_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(brand_type, 'in', brand_type_value) = (case when brand_type_operator = '=' then 1 else 0 end)
    and if(shop_group = '' OR shop_group_value = '', 0, ytdw.simple_expr(substr(shop_group_value, 2, length(shop_group_value) - 2), 'in', concat('[', shop_group, ']'))) = (case when shop_group_operator ='=' then 1 else 0 end)
    and (ytdw.simple_expr(brand_id, 'in', brand_key_value) = (case when brand_key_operator = '=' then 1 else 0 end) OR ytdw.simple_expr(brand_key, 'in', brand_key_value) = (case when brand_key_operator = '=' then 1 else 0 end))
    group by dayid,
             no,
             brand_id,
             brand_key,
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
             new_sign_line
),

big_bd_manager as (
    select dayid,
           dept_id,
           user_id,
           user_real_name,
           row_number() over(partition by dayid, dept_id order by create_time desc) as rn
    from ytdw.dim_usr_user_d
    where dept_id is not null
    AND user_status = 1
    AND job_id = 128
),

user_admin as (
    select user_id,
           user_real_name,
           dept_id,
           substr(leave_time,1,8) as leave_time,
           dayid
    from ytdw.dim_usr_user_d
),

before_cur as (
    select from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
           from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,

           --方案信息
           '历史方案' as plan_type,
           plan.month as plan_month,
           yt_crm.plan_calculate_date(plan.calculate_date, 'str') as plan_pay_time,
           plan.name as plan_name,
           plan.biz_group_id as plan_group_id,
           plan.biz_group_name as plan_group_name,
           plan.bounty_indicator_name as sts_target_name,

           --数据信息
           brand_id,
           brand_key,
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
           row_number() over (partition by planno, shop_id, brand_key, is_over_sign_line order by new_sign_time) as new_sign_rn, --新签时间排名达成
           shop_brand_sign_day,
           gmv_less_refund,
           gmv,
           pay_amount,
           pay_amount_less_refund,
           refund_actual_amount,
           refund_retreat_amount,
           new_sign_line,
           is_over_sign_line,
           planno,

           --方案信息
           plan.bounty_payout_object_name as grant_object_type,--发放对象类型
           plan.bounty_payout_object_code,
           case when plan.bounty_payout_object_code = 'WAR_ZONE_MANAGE' then war_zone_id
                when plan.bounty_payout_object_code = 'AREA_MANAGER' then area_manager_id
                when plan.bounty_payout_object_code = 'BD_MANAGER' then bd_manager_id
                when plan.bounty_payout_object_code  in('BD','BIG_BD', 'BD_BIG_BD')  then service_user_id_freezed
                when plan.bounty_payout_object_code = 'GRANT_USER' then plan.grant_user
                when plan.bounty_payout_object_code = 'BIG_BD_AREA_MANAGER' then big_bd_manager.user_id
                end as grant_object_user_id,                                                                      --发放对象ID
           case when plan.bounty_payout_object_code = 'WAR_ZONE_MANAGE' then war_zone_name
                when plan.bounty_payout_object_code = 'AREA_MANAGER' then area_manager_name
                when plan.bounty_payout_object_code = 'BD_MANAGER' then bd_manager_name
                when plan.bounty_payout_object_code  in('BD','BIG_BD', 'BD_BIG_BD')  then service_user_name_freezed
                when plan.bounty_payout_object_code = 'GRANT_USER' then null
                when plan.bounty_payout_object_code = 'BIG_BD_AREA_MANAGER' then big_bd_manager.user_real_name
                end as grant_object_user_name,                                                                       --发放对象名称
           case when plan.bounty_payout_object_code = 'WAR_ZONE_MANAGE' then war_zone_dep_id
                when plan.bounty_payout_object_code = 'AREA_MANAGER' then area_manager_dep_id
                when plan.bounty_payout_object_code = 'BD_MANAGER' then bd_manager_dep_id
                when plan.bounty_payout_object_code  in('BD','BIG_BD', 'BD_BIG_BD')  then service_department_id_freezed
                when plan.bounty_payout_object_code = 'GRANT_USER' then service_department_id_freezed
                when plan.bounty_payout_object_code = 'BIG_BD_AREA_MANAGER' then service_department_id_freezed
                end as grant_object_user_dep_id,                                                                      --发放对象部门ID
           case when plan.bounty_payout_object_code = 'WAR_ZONE_MANAGE' then war_zone_dep_name
                when plan.bounty_payout_object_code = 'AREA_MANAGER' then area_manager_dep_name
                when plan.bounty_payout_object_code = 'BD_MANAGER' then bd_manager_dep_name
                when plan.bounty_payout_object_code  in('BD','BIG_BD', 'BD_BIG_BD')  then service_department_name_freezed
                when plan.bounty_payout_object_code = 'GRANT_USER' then null
                when plan.bounty_payout_object_code = 'BIG_BD_AREA_MANAGER' then service_department_name_freezed
                end as grant_object_user_dep_name,
           sign.dayid,

           plan.filter_user_value,
           plan.filter_user_operator,
           plan.dept_value,
           plan.dept_operator
    FROM sign
    INNER JOIN plan ON sign.planno = plan.no
    LEFT JOIN big_bd_manager ON sign.service_department_id_freezed = big_bd_manager.dept_id AND sign.dayid = big_bd_manager.dayid AND big_bd_manager.rn = 1
),

cur as (
    SELECT *
    FROM before_cur
    WHERE ytdw.simple_expr(grant_object_user_id, 'in', filter_user_value) = (case when filter_user_operator = '=' then 1 else 0 end)
    AND ytdw.simple_expr(grant_object_user_dep_id, 'in', dept_value) = (case when dept_operator = '=' then 1 else 0 end)
)

insert overwrite table dw_salary_sign_brand_rule_public_d partition (dayid='${v_date}',pltype='pre')
SELECT update_time,
       update_month,
       plan_type,
       plan_month,
       plan_pay_time,
       plan_name,
       plan_group_id,
       plan_group_name,
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
       shop_brand_sign_day,
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
       planno,
       brand_key
FROM cur
LEFT JOIN user_admin on cur.grant_object_user_id = user_admin.user_id AND cur.dayid = user_admin.dayid
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
       shop_brand_sign_day,
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
       planno,
       brand_key
FROM (
    SELECT *
    FROM yt_crm.dw_salary_sign_brand_rule_public_d
    WHERE dayid = '${v_date}'
    AND pltype='pre'
) history
LEFT JOIN (
    SELECT no FROM plan
) cur_plan ON history.planno = cur_plan.no
WHERE cur_plan.no is null