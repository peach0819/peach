with plan as (
    SELECT no
    FROM yt_crm.dw_bounty_plan_schedule_d
    WHERE bounty_rule_type = 4
    AND array_contains(split(if('@@{pltype}' = 'cur', forward_date, backward_date), ','), '${v_date}')
    AND ('@@{supply_mode}' = 'not_supply' OR array_contains(split(supply_date, ','), '${supply_date}'))
),

cur as (
    SELECT from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
           from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,
           planno,
           plan_month,
           shop_id,
           shop_name,
           brand_id,
           brand_name,
           grant_object_user_id,
           total_gmv_less_refund,
           first_valid_date,
           row_number() over(partition by planno, shop_id, brand_id order by first_valid_date) as rank
    FROM yt_crm.dw_salary_brand_shop_current_object_sum_d detail
    INNER JOIN plan ON detail.planno = plan.no
    WHERE dayid = '${v_date}'
    AND pltype = '@@{pltype}'
    AND is_valid_brand = 1
)

insert overwrite table dw_salary_brand_shop_current_shop_sum_d partition (dayid='${v_date}', pltype='@@{pltype}')
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
       first_valid_date
FROM cur
WHERE rank = 1

UNION ALL

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
       first_valid_date
FROM (
    SELECT *
    FROM yt_crm.dw_salary_brand_shop_current_shop_sum_d
    WHERE dayid = '${v_date}'
    AND pltype = '@@{pltype}'
) history
LEFT JOIN (
    SELECT no FROM plan
) cur_plan ON history.planno = cur_plan.no
WHERE cur_plan.no is null