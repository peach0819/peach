v_date=$1
supply_date=$2
supply_mode='not_supply'

if [[ $supply_date != "" ]]
then
  supply_mode='supply'
fi

source ../sql_variable.sh $v_date
source ../yarn_variable.sh dw_salary_forward_brand_shop_current_public_d '肥桃'

spark-sql $spark_yarn_job_name_conf $spark_yarn_queue_name_conf --master yarn --executor-memory 4G --num-executors 4 -v -e "
use ytdw;

with plan as (
    SELECT no,
           month,
           bounty_payout_object_code,
           backward_date,
           get_json_object(get_json_object(filter_config_json,'$.item_style'),'$.value') as item_style_value,
           get_json_object(get_json_object(filter_config_json,'$.item_style'),'$.operator') as item_style_operator,
           get_json_object(get_json_object(filter_config_json,'$.category_first'),'$.value') as category_first_value,
           get_json_object(get_json_object(filter_config_json,'$.category_first'),'$.operator') as category_first_operator,
           get_json_object(get_json_object(filter_config_json,'$.category_second'),'$.value') as category_second_value,
           get_json_object(get_json_object(filter_config_json,'$.category_second'),'$.operator') as category_second_operator,
           get_json_object(get_json_object(filter_config_json,'$.brand'),'$.value') as brand_value,
           get_json_object(get_json_object(filter_config_json,'$.brand'),'$.operator') as brand_operator,
           get_json_object(get_json_object(filter_config_json,'$.war_area'),'$.value') as war_area_value,
           get_json_object(get_json_object(filter_config_json,'$.war_area'),'$.operator') as war_area_operator,
           get_json_object(get_json_object(filter_config_json,'$.bd_area'),'$.value') as bd_area_value,
           get_json_object(get_json_object(filter_config_json,'$.bd_area'),'$.operator') as bd_area_operator,
           get_json_object(get_json_object(filter_config_json,'$.manage_area'),'$.value') as manage_area_value,
           get_json_object(get_json_object(filter_config_json,'$.manage_area'),'$.operator') as manage_area_operator,
           get_json_object(get_json_object(filter_config_json,'$.sales_team'),'$.value') as sales_team_value,
           get_json_object(get_json_object(filter_config_json,'$.sales_team'),'$.operator') as sales_team_operator,
           get_json_object(get_json_object(filter_config_json,'$.shop_group'),'$.value') as shop_group_value,
           get_json_object(get_json_object(filter_config_json,'$.shop_group'),'$.operator') as shop_group_operator,
           replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.calculate_date_quarter'),'$.value'),',')[0],'[',''),'\"',''),'-','') as calculate_date_value_start,
           replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.calculate_date_quarter'),'$.value'),',')[1],']',''),'\"',''),'-','') as calculate_date_value_end,
           replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.payout_object_type'),'$.value'),'\"',''),'[',''),']','') as payout_object_type
    FROM dw_bounty_plan_schedule_d
    WHERE dayid = '$v_date'
    AND array_contains(split(backward_date, ','), '$v_date')
    AND ('$supply_mode' = 'not_supply' OR array_contains(split(supply_date, ','), '$supply_date'))
    AND bounty_rule_type = 4
),

cur as (
    SELECT from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
           from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,
           plan.no as planno,
           plan.month as plan_month,
           ord.order_id,
           ord.trade_id,
           ord.pay_date,
           refund.rfd_date,
           sum(ord.gmv) as gmv,
           refund.refund_actual_amount as refund,
           sum(ord.gmv) - refund.refund_actual_amount as gmv_less_refund,
           ord.shop_id,
           ord.shop_name,
           ord.brand_id,
           ord.brand_name,
           ord.category_1st_id,
           ord.category_1st_name,
           ord.category_2nd_id,
           ord.category_2nd_name,
           ord.item_id,
           ord.item_name,
           ord.item_style,
           ord.item_style_name,
           case when plan.bounty_payout_object_code= 'WAR_ZONE_MANAGE' then war_zone_id
                when plan.bounty_payout_object_code= 'AREA_MANAGER' then area_manager_id
                when plan.bounty_payout_object_code= 'BD_MANAGER' then bd_manager_id
                when plan.bounty_payout_object_code= 'BD' then if(plan.payout_object_type = '冻结', ord.frozen_sale_user_id, ord.newest_sale_user_id)
           end as grant_object_user_id
    FROM plan
    CROSS JOIN (
        select *
        from dw_salary_brand_shop_rule_public_mid_v2_d
        where dayid IN (
            replace(last_day(add_months('$v_op_time', 0)), '-', ''),
            replace(last_day(add_months('$v_op_time', -1)), '-', ''),
            replace(last_day(add_months('$v_op_time', -2)), '-', ''),
            replace(last_day(add_months('$v_op_time', -3)), '-', ''),
            replace(last_day(add_months('$v_op_time', -4)), '-', ''),
            replace(last_day(add_months('$v_op_time', -5)), '-', ''),
            replace(last_day(add_months('$v_op_time', -6)), '-', ''),
            replace(last_day(add_months('$v_op_time', -7)), '-', ''),
            replace(last_day(add_months('$v_op_time', -8)), '-', ''),
            replace(last_day(add_months('$v_op_time', -9)), '-', ''),
            replace(last_day(add_months('$v_op_time', -10)), '-', ''),
            replace(last_day(add_months('$v_op_time', -11)), '-', '')
        )
    ) ord ON 1=1 and ord.dayid = split(plan.backward_date, ',')[0]
    LEFT JOIN (
        select order_id,
               sum(act_rfd_amt) as refund_actual_amount,
               max(substr(rfd_time,1,8)) as rfd_date
        from dw_hpc_trd_act_rfd_d
        where dayid ='$v_date'
        group by order_id
    ) refund ON ord.order_id = refund.order_id
    WHERE ord.pay_date between plan.calculate_date_value_start and plan.calculate_date_value_end
    AND ytdw.simple_expr(ord.item_style_name, 'in', plan.item_style_value) = if(plan.item_style_operator = '=', 1, 0)
    AND ytdw.simple_expr(ord.category_1st_id, 'in', plan.category_first_value) = if(plan.category_first_operator = '=', 1, 0)
    AND ytdw.simple_expr(ord.category_2nd_id, 'in', plan.category_second_value) = if(plan.category_second_operator = '=', 1, 0)
    AND ytdw.simple_expr(ord.brand_id, 'in', plan.brand_value) = if(plan.brand_operator = '=', 1, 0)
    AND ytdw.simple_expr(ord.war_zone_dep_id, 'in', plan.war_area_value) = if(plan.war_area_operator = '=', 1, 0)
    AND ytdw.simple_expr(ord.area_manager_dep_id, 'in', plan.bd_area_value) = if(plan.bd_area_operator = '=', 1, 0)
    AND ytdw.simple_expr(ord.bd_manager_dep_id, 'in', plan.manage_area_value) = if(plan.manage_area_operator = '=', 1, 0)
    AND ytdw.simple_expr(if(plan.payout_object_type = '冻结', ord.sale_team_freezed_id, ord.sale_team_id), 'in', plan.sales_team_value) = if(plan.sales_team_operator = '=', 1, 0)
    AND if(ord.shop_group = '' OR plan.shop_group_value = '', 0, ytdw.simple_expr(substr(plan.shop_group_value, 2, length(plan.shop_group_value) - 2), 'in', concat('[', ord.shop_group, ']'))) = if(plan.shop_group_operator = '=', 1, 0)
    GROUP BY plan.no,
             plan.month,
             ord.order_id,
             ord.trade_id,
             ord.pay_date,
             refund.rfd_date,
             refund.refund_actual_amount,
             ord.shop_id,
             ord.shop_name,
             ord.brand_id,
             ord.brand_name,
             ord.category_1st_id,
             ord.category_1st_name,
             ord.category_2nd_id,
             ord.category_2nd_name,
             ord.item_id,
             ord.item_name,
             ord.item_style,
             ord.item_style_name,
             case when plan.bounty_payout_object_code= 'WAR_ZONE_MANAGE' then war_zone_id
                  when plan.bounty_payout_object_code= 'AREA_MANAGER' then area_manager_id
                  when plan.bounty_payout_object_code= 'BD_MANAGER' then bd_manager_id
                  when plan.bounty_payout_object_code= 'BD' then if(plan.payout_object_type = '冻结', ord.frozen_sale_user_id, ord.newest_sale_user_id)
             end
)

insert overwrite table dw_salary_brand_shop_current_public_d partition (dayid='$v_date', pltype='pre')
SELECT planno,
       plan_month,
       update_time,
       update_month,
       order_id,
       trade_id,
       pay_date,
       rfd_date,
       gmv,
       refund,
       gmv_less_refund,
       shop_id,
       shop_name,
       brand_id,
       brand_name,
       category_1st_id,
       category_1st_name,
       category_2nd_id,
       category_2nd_name,
       item_id,
       item_name,
       item_style,
       item_style_name,
       grant_object_user_id,
       sum(gmv_less_refund) over(partition by planno, shop_id, brand_id, grant_object_user_id order by pay_date) as current_total_gmv_less_refund
FROM cur

UNION ALL

SELECT planno,
       plan_month,
       update_time,
       update_month,
       order_id,
       trade_id,
       pay_date,
       rfd_date,
       gmv,
       refund,
       gmv_less_refund,
       shop_id,
       shop_name,
       brand_id,
       brand_name,
       category_1st_id,
       category_1st_name,
       category_2nd_id,
       category_2nd_name,
       item_id,
       item_name,
       item_style,
       item_style_name,
       grant_object_user_id,
       current_total_gmv_less_refund
FROM (
    SELECT *
    FROM dw_salary_brand_shop_current_public_d
    WHERE dayid = '$v_date'
    AND pltype='pre'
) history
LEFT JOIN (
    SELECT no FROM plan
) cur_plan ON history.planno = cur_plan.no
WHERE cur_plan.no is null
;
" &&

exit 0