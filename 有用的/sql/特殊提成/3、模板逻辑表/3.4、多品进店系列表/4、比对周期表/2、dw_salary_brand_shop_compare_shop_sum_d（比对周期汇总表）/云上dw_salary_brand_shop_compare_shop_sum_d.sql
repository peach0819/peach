with plan as (
    SELECT no,
           replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.valid_brand_line'),'$.value'),'\"',''),'[',''),']','') as valid_brand_line,
           replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.compare_date'),'$.value'),',')[1],']',''),'\"',''),'-','') as calculate_date_value_end
    FROM yt_crm.dw_bounty_plan_schedule_d
    WHERE bounty_rule_type = 4
    AND array_contains(split(forward_date, ','), '${v_date}')
    AND ('@@{supply_mode}' = 'not_supply' OR array_contains(split(supply_date, ','), '${supply_date}'))
),

detail as (
    SELECT planno,
           plan_month,
           order_id,
           pay_date,
           rfd_date,
           gmv,
           refund,
           gmv_less_refund,
           shop_id,
           shop_name,
           brand_id,
           brand_name
    FROM yt_crm.dw_salary_brand_shop_compare_public_d
    WHERE dayid = '${v_date}'
),

cur as (
    SELECT from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
           from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,
           detail.planno,
           detail.plan_month,
           detail.shop_id,
           detail.shop_name,
           detail.brand_id,
           detail.brand_name,
           sum(detail.gmv_less_refund) as total_gmv_less_refund,
           plan.valid_brand_line
    FROM detail
    INNER JOIN plan ON detail.planno = plan.no
    group by detail.planno,
             detail.plan_month,
             detail.shop_id,
             detail.shop_name,
             detail.brand_id,
             detail.brand_name,
             plan.valid_brand_line
)

insert overwrite table dw_salary_brand_shop_compare_shop_sum_d partition (dayid='${v_date}')
SELECT planno,
       plan_month,
       update_time,
       update_month,
       shop_id,
       shop_name,
       brand_id,
       brand_name,
       total_gmv_less_refund,
       if(total_gmv_less_refund >= valid_brand_line, 1, 0) as is_valid_brand
FROM cur

UNION ALL

SELECT planno,
       plan_month,
       update_time,
       update_month,
       shop_id,
       shop_name,
       brand_id,
       brand_name,
       total_gmv_less_refund,
       is_valid_brand
FROM (
    SELECT *
    FROM yt_crm.dw_salary_brand_shop_compare_shop_sum_d
    WHERE dayid = '${v_date}'
) history
LEFT JOIN (
    SELECT no FROM plan
) cur_plan ON history.planno = cur_plan.no
WHERE cur_plan.no is null