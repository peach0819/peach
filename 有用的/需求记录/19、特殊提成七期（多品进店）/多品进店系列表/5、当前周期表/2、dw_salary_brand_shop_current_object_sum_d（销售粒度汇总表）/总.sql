use ytdw;

with plan as (
    SELECT no,
           replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.valid_brand_line'),'$.value'),'\"',''),'[',''),']','') as valid_brand_line
    FROM dw_bounty_plan_schedule_d
    WHERE dayid = '$v_date'
    AND bounty_rule_type = 4
),

detail as (
    SELECT planno,
           plan_month,
           order_id,
           pay_date,
           rfd_date,
           gmv_less_refund,
           shop_id,
           shop_name,
           brand_id,
           brand_name,
           grant_object_user_id,
           current_total_gmv_less_refund
    FROM dw_salary_brand_shop_current_public_d
    WHERE dayid = '$v_date'
    AND pltype = 'cur'
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
           detail.grant_object_user_id,
           sum(detail.gmv_less_refund) as total_gmv_less_refund,
           min(if(detail.current_total_gmv_less_refund > plan.valid_brand_line, detail.pay_date, null)) as first_valid_date,
           plan.valid_brand_line
    FROM detail
    INNER JOIN plan ON detail.planno = plan.no
    group by detail.planno,
             detail.plan_month,
             detail.shop_id,
             detail.shop_name,
             detail.brand_id,
             detail.brand_name,
             detail.grant_object_user_id,
             plan.valid_brand_line
)

insert overwrite table dw_salary_brand_shop_current_object_sum_d partition (dayid='$v_date', pltype='cur')
SELECT planno,
       plan_month,
       update_time,
       update_month,
       shop_id,
       shop_name,
       brand_id,
       brand_name,
       grant_object_user_id,
       total_gmv_less_refund,
       if(total_gmv_less_refund>valid_brand_line, 1, 0) as is_valid_brand,
       first_valid_date
FROM cur