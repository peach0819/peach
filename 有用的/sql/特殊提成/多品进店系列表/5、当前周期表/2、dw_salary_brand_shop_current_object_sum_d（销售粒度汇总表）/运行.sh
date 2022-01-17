v_date=$1
supply_date=$4
supply_mode='not_supply'
pltype=$5

if [[ $pltype = "" ]]
then
	pltype='cur'
fi

if [[ $supply_date != "" ]]
then
  supply_mode='supply'
fi

source ../sql_variable.sh $v_date
source ../yarn_variable.sh dw_salary_brand_shop_current_object_sum_d '肥桃'

spark-sql $spark_yarn_job_name_conf $spark_yarn_queue_name_conf --master yarn --executor-memory 4G --num-executors 4 -v -e "
use ytdw;

with plan as (
    SELECT no,
           replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.valid_brand_line'),'$.value'),'\"',''),'[',''),']','') as valid_brand_line
    FROM dw_bounty_plan_schedule_d
    WHERE bounty_rule_type = 4
    AND array_contains(split(if('$pltype' = 'cur', forward_date, backward_date), ','), '$v_date')
    AND ('$supply_mode' = 'not_supply' OR array_contains(split(supply_date, ','), '$supply_date'))
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
    AND pltype = '$pltype'
    AND grant_object_user_id is not null
    AND grant_object_user_id != ''
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

insert overwrite table dw_salary_brand_shop_current_object_sum_d partition (dayid='$v_date', pltype='$pltype')
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
       is_valid_brand,
       first_valid_date
FROM (
    SELECT *
    FROM dw_salary_brand_shop_current_object_sum_d
    WHERE dayid = '$v_date'
    AND pltype = '$pltype'
) history
LEFT JOIN (
    SELECT no FROM plan
) cur_plan ON history.planno = cur_plan.no
WHERE cur_plan.no is null
;
" &&

exit 0