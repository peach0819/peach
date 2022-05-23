v_date=$1
supply_date=$4
supply_mode='not_supply'

if [[ $supply_date != "" ]]
then
  supply_mode='supply'
fi

source ../sql_variable.sh $v_date

apache-spark-sql -e "
use ytdw;

with plan as (
    SELECT *,
           get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value') as calculate_date_value,
           get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.operator') as calculate_date_operator,
           get_json_object(get_json_object(filter_config_json,'$.freeze_sales_team'),'$.value') as freeze_sales_team_value,
           get_json_object(get_json_object(filter_config_json,'$.freeze_sales_team'),'$.operator') as freeze_sales_team_operator,
           get_json_object(get_json_object(filter_config_json,'$.item_style'),'$.value') as item_style_value,
           get_json_object(get_json_object(filter_config_json,'$.item_style'),'$.operator') as item_style_operator,
           get_json_object(get_json_object(filter_config_json,'$.category_first'),'$.value') as category_first_value,
           get_json_object(get_json_object(filter_config_json,'$.category_first'),'$.operator') as category_first_operator,
           get_json_object(get_json_object(filter_config_json,'$.category_second'),'$.value') as category_second_value,
           get_json_object(get_json_object(filter_config_json,'$.category_second'),'$.operator') as category_second_operator,
           get_json_object(get_json_object(filter_config_json,'$.brand'),'$.value') as brand_value,
           get_json_object(get_json_object(filter_config_json,'$.brand'),'$.operator') as brand_operator,
           get_json_object(get_json_object(filter_config_json,'$.item'),'$.value') as item_value,
           get_json_object(get_json_object(filter_config_json,'$.item'),'$.operator') as item_operator,
           get_json_object(get_json_object(filter_config_json,'$.war_area'),'$.value') as war_area_value,
           get_json_object(get_json_object(filter_config_json,'$.war_area'),'$.operator') as war_area_operator,
           get_json_object(get_json_object(filter_config_json,'$.bd_area'),'$.value') as bd_area_value,
           get_json_object(get_json_object(filter_config_json,'$.bd_area'),'$.operator') as bd_area_operator,
           get_json_object(get_json_object(filter_config_json,'$.manage_area'),'$.value') as manage_area_value,
           get_json_object(get_json_object(filter_config_json,'$.manage_area'),'$.operator') as manage_area_operator,
           get_json_object(get_json_object(filter_config_json,'$.shop_group'),'$.value') as shop_group_value,
           get_json_object(get_json_object(filter_config_json,'$.shop_group'),'$.operator') as shop_group_operator,
           replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),',')[0],'[',''),'\"',''),'-','') as calculate_date_value_start,
           replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),',')[1],']',''),'\"',''),'-','') as calculate_date_value_end,
           replace(replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),']',''),'\"',''),'[',''),',','~') as plan_pay_time,
           get_json_object(get_json_object(filter_config_json,'$.filter_user'),'$.value') as filter_user_value,
           get_json_object(get_json_object(filter_config_json,'$.filter_user'),'$.operator') as filter_user_operator,
           replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.grant_user'),'$.value'),',')[0],'[',''),'\"',''),'-','') as grant_user
    FROM dw_bounty_plan_schedule_d
    WHERE array_contains(split(forward_date, ','), '$v_date')
    AND ('$supply_mode' = 'not_supply' OR array_contains(split(supply_date, ','), '$supply_date'))
    AND bounty_rule_type = 1
),

ord as (
    SELECT pay_day,
           business_unit,
           category_id_first,
           category_id_second,
           category_id_first_name,
           category_id_second_name,
           brand_id,
           brand_name,
           item_id,
           item_name,
           item_style,
           item_style_name,
           is_sp_shop,
           is_bigbd_shop,
           is_spec_order,
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
           sp_id,
           sp_name,
           sp_operator_name,
           service_user_names_freezed,
           service_feature_names_freezed,
           service_job_names_freezed,
           service_department_names_freezed,
           service_info_freezed,
           service_info,
           shop_group,
           sale_team_freezed_id,

           sum(gmv_less_refund) as gmv_less_refund,
           sum(gmv) as gmv,
           sum(pay_amount) as pay_amount,
           sum(pay_amount_less_refund) as pay_amount_less_refund,
           sum(refund_actual_amount) as refund_actual_amount,
           sum(refund_retreat_amount) as refund_retreat_amount,
           sum(pickup_pay_gmv) as pickup_pay_gmv,
           sum(pickup_pay_pay_amount) as pickup_pay_pay_amount,
           sum(pickup_recharge_gmv) as pickup_recharge_gmv,
           sum(pickup_recharge_pay_amount) as pickup_recharge_pay_amount,
           sum(pickup_pay_gmv_less_refund) as pickup_pay_gmv_less_refund,
           sum(pickup_pay_pay_amount_less_refund) as pickup_pay_pay_amount_less_refund,
           sum(pickup_recharge_gmv_less_refund) as pickup_recharge_gmv_less_refund,
           sum(pickup_recharge_pay_amount_less_refund) as pickup_recharge_pay_amount_less_refund
    FROM dw_salary_gmv_rule_public_mid_v2_d
    where dayid ='$v_date'
    group by pay_day,
             business_unit,
             category_id_first,
             category_id_second,
             category_id_first_name,
             category_id_second_name,
             brand_id,
             brand_name,
             item_id,
             item_name,
             item_style,
             item_style_name,
             is_sp_shop,
             is_bigbd_shop,
             is_spec_order,
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
             sp_id,
             sp_name,
             sp_operator_name,
             service_user_names_freezed,
             service_feature_names_freezed,
             service_job_names_freezed,
             service_department_names_freezed,
             service_info_freezed,
             service_info,
             shop_group,
             sale_team_freezed_id
),

user_admin as (
    select user_id,
           user_real_name,
           dept_id,
           substr(leave_time,1,8) as leave_time
    from dwd_user_admin_d
    where dayid='$v_date'
),

cur as (
    SELECT from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
           from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,
           '当月方案' as plan_type,

           --方案基础信息,
           plan.month as plan_month,
           plan.plan_pay_time,
           plan.name as plan_name,
           plan.biz_group_id as plan_group_id,
           plan.biz_group_name as plan_group_name,

           --订单信息,
           ord.business_unit,
           ord.category_id_first,
           ord.category_id_second,
           ord.category_id_first_name,
           ord.category_id_second_name,
           ord.brand_id,
           ord.brand_name,
           ord.item_id,
           ord.item_name,
           ord.item_style,
           ord.item_style_name,
           ord.is_sp_shop,
           ord.is_bigbd_shop,
           ord.is_spec_order,
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
           ord.sp_id,
           ord.sp_name,
           ord.sp_operator_name,
           ord.service_user_names_freezed,
           ord.service_feature_names_freezed,
           ord.service_job_names_freezed,
           ord.service_department_names_freezed,
           ord.service_info_freezed,
           ord.service_info,
           ord.gmv_less_refund,
           ord.gmv,
           ord.pay_amount,
           ord.pay_amount_less_refund,
           ord.refund_actual_amount,
           ord.refund_retreat_amount,

           --发放对象--
           plan.bounty_payout_object_name as grant_object_type,

           --发放对象ID
           case  when plan.bounty_payout_object_code = 'WAR_ZONE_MANAGE' then war_zone_id
                 when plan.bounty_payout_object_code = 'AREA_MANAGER' then area_manager_id
                 when plan.bounty_payout_object_code = 'BD_MANAGER' then bd_manager_id
                 when plan.bounty_payout_object_code = 'BD' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_user_id')
                 when plan.bounty_payout_object_code = 'BIG_BD' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_user_id')
                 when plan.bounty_payout_object_code = 'GRANT_USER' then plan.grant_user
                 end as grant_object_user_id,

           --发放对象名称
           case when plan.bounty_payout_object_code = 'WAR_ZONE_MANAGE' then war_zone_name
                when plan.bounty_payout_object_code = 'AREA_MANAGER' then area_manager_name
                when plan.bounty_payout_object_code = 'BD_MANAGER' then bd_manager_name
                when plan.bounty_payout_object_code = 'BD' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_user_name')
                when plan.bounty_payout_object_code = 'BIG_BD' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_user_name')
                when plan.bounty_payout_object_code = 'GRANT_USER' then null
                end as grant_object_user_name,

           --发放对象部门ID
           case when plan.bounty_payout_object_code = 'WAR_ZONE_MANAGE' then war_zone_dep_id
                when plan.bounty_payout_object_code = 'AREA_MANAGER' then area_manager_dep_id
                when plan.bounty_payout_object_code = 'BD_MANAGER' then bd_manager_dep_id
                when plan.bounty_payout_object_code = 'BD' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_department_id')
                when plan.bounty_payout_object_code = 'BIG_BD' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_department_id')
                when plan.bounty_payout_object_code = 'GRANT_USER' then null
                end as grant_object_user_dep_id,

           --发放对象部门
           case when plan.bounty_payout_object_code = 'WAR_ZONE_MANAGE' then war_zone_dep_name
                when plan.bounty_payout_object_code = 'AREA_MANAGER' then area_manager_dep_name
                when plan.bounty_payout_object_code = 'BD_MANAGER' then bd_manager_dep_name
                when plan.bounty_payout_object_code = 'BD' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_department_name')
                when plan.bounty_payout_object_code = 'BIG_BD' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_department_name')
                when plan.bounty_payout_object_code = 'GRANT_USER' then null
                end as grant_object_user_dep_name,

           ---统计指标----
           plan.bounty_indicator_name as sts_target_name,
           case when plan.bounty_indicator_code in ('STOCK_GMV_1_GOODS_GMV_MINUS_REFUND', 'STOCK_GMV_AVG_GOODS_GMV_MINUS_REFUND') then ord.gmv_less_refund --实货GMV(去退款)
                when plan.bounty_indicator_code in ('STOCK_GMV_1_GOODS_PAY_AMT_MINUS_COUNPONS_MINUS_REF', 'STOCK_GMV_AVG_GOODS_PAY_AMT_MINUS_COUNPONS_REF') then ord.pay_amount_less_refund  --实货支付金额(去优惠券去退款)
                when plan.bounty_indicator_code in ('PICKUP_PAY_GMV_LESS_REFUND', 'AVG_PICKUP_PAY_GMV_LESS_REFUND') then ord.pickup_pay_gmv_less_refund  --提货卡口径GMV(去退款)
                when plan.bounty_indicator_code in ('PICKUP_PAY_AMT_LESS_COUPON_REFUND', 'AVG_PICKUP_PAY_AMT_LESS_COUPON_REFUND') then ord.pickup_pay_pay_amount_less_refund  --提货卡口径支付金额(去优惠券去退款)
                when plan.bounty_indicator_code in ('PICKUP_RECHARGE_GMV_LESS_REFUND', 'AVG_PICKUP_RECHARGE_GMV_LESS_REFUND') then ord.pickup_recharge_gmv_less_refund  --提货卡充值GMV(去退款)
                when plan.bounty_indicator_code in ('PICKUP_RECHARGE_AMT_LESS_COUPON_REFUND', 'AVG_PICKUP_RECHARGE_AMT_LESS_COUPON_REFUND') then ord.pickup_recharge_pay_amount_less_refund  --提货卡充值支付金额(去优惠券去退款)
                end as sts_target,

           ord.pay_day,
           plan.no as planno,

           plan.filter_user_value,
           plan.filter_user_operator,

           --冗余字段
           to_json(named_struct(
               'gmv_less_refund', ord.gmv_less_refund,
               'gmv', ord.gmv,
               'pay_amount', ord.pay_amount,
               'pay_amount_less_refund', ord.pay_amount_less_refund,
               'refund_actual_amount', ord.refund_actual_amount,
               'refund_retreat_amount', ord.refund_retreat_amount,
               'pickup_pay_gmv', ord.pickup_pay_gmv,
               'pickup_pay_pay_amount', ord.pickup_pay_pay_amount,
               'pickup_recharge_gmv', ord.pickup_recharge_gmv,
               'pickup_recharge_pay_amount', ord.pickup_recharge_pay_amount,
               'pickup_pay_gmv_less_refund', ord.pickup_pay_gmv_less_refund,
               'pickup_pay_pay_amount_less_refund', ord.pickup_pay_pay_amount_less_refund,
               'pickup_recharge_gmv_less_refund', ord.pickup_recharge_gmv_less_refund,
               'pickup_recharge_pay_amount_less_refund', ord.pickup_recharge_pay_amount_less_refund
           )) as extra
    FROM plan
    CROSS JOIN ord ON 1 = 1
    where ord.pay_day between calculate_date_value_start and calculate_date_value_end
    and ytdw.simple_expr(ord.sale_team_freezed_id, 'in', freeze_sales_team_value) = (case when freeze_sales_team_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(item_style_name, 'in', item_style_value) = (case when item_style_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(category_id_first, 'in', category_first_value) = (case when category_first_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(category_id_second, 'in', category_second_value) = (case when category_second_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(brand_id, 'in', brand_value) = (case when brand_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(item_id, 'in', item_value) = (case when item_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(war_zone_dep_id, 'in', war_area_value) = (case when war_area_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(area_manager_dep_id, 'in', bd_area_value) = (case when bd_area_operator = '=' then 1 else 0 end)
    and ytdw.simple_expr(bd_manager_dep_id, 'in', manage_area_value) = (case when manage_area_operator = '=' then 1 else 0 end)
    and if(ord.shop_group = '' OR plan.shop_group_value = '', 0, ytdw.simple_expr(substr(plan.shop_group_value, 2, length(plan.shop_group_value) - 2), 'in', concat('[', ord.shop_group, ']'))) = (case when shop_group_operator ='=' then 1 else 0 end)
    HAVING ytdw.simple_expr(grant_object_user_id, 'in', filter_user_value) = (case when filter_user_operator = '=' then 1 else 0 end)
)

insert overwrite table dw_salary_gmv_rule_public_d partition (dayid='$v_date',pltype='cur')
SELECT cur.update_time,
       cur.update_month,
       cur.plan_type,
       cur.plan_month,
       cur.plan_pay_time,
       cur.plan_name,
       cur.plan_group_id,
       cur.plan_group_name,
       cur.business_unit,
       cur.category_id_first,
       cur.category_id_second,
       cur.category_id_first_name,
       cur.category_id_second_name,
       cur.brand_id,
       cur.brand_name,
       cur.item_id,
       cur.item_name,
       cur.item_style,
       cur.item_style_name,
       cur.is_sp_shop,
       cur.is_bigbd_shop,
       cur.is_spec_order,
       cur.shop_id,
       cur.shop_name,
       cur.store_type,
       cur.store_type_name,
       cur.war_zone_id,
       cur.war_zone_name,
       cur.war_zone_dep_id,
       cur.war_zone_dep_name,
       cur.area_manager_id,
       cur.area_manager_name,
       cur.area_manager_dep_id,
       cur.area_manager_dep_name,
       cur.bd_manager_id,
       cur.bd_manager_name,
       cur.bd_manager_dep_id,
       cur.bd_manager_dep_name,
       cur.sp_id,
       cur.sp_name,
       cur.sp_operator_name,
       cur.service_user_names_freezed,
       cur.service_feature_names_freezed,
       cur.service_job_names_freezed,
       cur.service_department_names_freezed,
       cur.service_info_freezed,
       cur.service_info,
       cur.gmv_less_refund,
       cur.gmv,
       cur.pay_amount,
       cur.pay_amount_less_refund,
       cur.refund_actual_amount,
       cur.refund_retreat_amount,
       cur.grant_object_type,
       cur.grant_object_user_id,
       nvl(cur.grant_object_user_name, user_admin.user_real_name),
       nvl(cur.grant_object_user_dep_id, user_admin.dept_id),
       cur.grant_object_user_dep_name,
       user_admin.leave_time as leave_time,
       if(user_admin.leave_time is not null and cur.pay_day > user_admin.leave_time, '是', '否') as is_leave,
       cur.sts_target_name,
       if(user_admin.leave_time is not null and cur.pay_day > user_admin.leave_time, 0, cur.sts_target) as sts_target,
       cur.pay_day,
       cur.planno,
       cur.extra
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
       business_unit,
       category_id_first,
       category_id_second,
       category_id_first_name,
       category_id_second_name,
       brand_id,
       brand_name,
       item_id,
       item_name,
       item_style,
       item_style_name,
       is_sp_shop,
       is_bigbd_shop,
       is_spec_order,
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
       sp_id,
       sp_name,
       sp_operator_name,
       service_user_names_freezed,
       service_feature_names_freezed,
       service_job_names_freezed,
       service_department_names_freezed,
       service_info_freezed,
       service_info,
       gmv_less_refund,
       gmv,
       pay_amount,
       pay_amount_less_refund,
       refund_actual_amount,
       refund_retreat_amount,
       grant_object_type,
       grant_object_user_id,
       grant_object_user_name,
       grant_object_user_dep_id,
       grant_object_user_dep_name,
       leave_time,
       is_leave,
       sts_target_name,
       sts_target,
       pay_day,
       planno,
       extra
FROM (
    SELECT *
    FROM dw_salary_gmv_rule_public_d
    WHERE dayid = '$v_date'
    AND pltype='cur'
) history
LEFT JOIN (
    SELECT no FROM plan
) cur_plan ON history.planno = cur_plan.no
WHERE cur_plan.no is null
;
" &&

exit 0