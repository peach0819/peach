v_date=$1

source ../sql_variable.sh $v_date
source ../yarn_variable.sh dw_salary_brand_shop_compare_shop_sum_d '肥桃'

spark-sql $spark_yarn_job_name_conf $spark_yarn_queue_name_conf --master yarn --executor-memory 4G --num-executors 4 -v -e "
use ytdw;

with plan as (
    SELECT no,
           replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.valid_brand_line'),'$.value'),'\"',''),'[',''),']','') as valid_brand_line,
           replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.compare_date'),'$.value'),',')[1],']',''),'\"',''),'-','') as calculate_date_value_end
    FROM dw_bounty_plan_schedule_d
    WHERE bounty_rule_type = 4
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
    FROM dw_salary_brand_shop_compare_public_d
    WHERE dayid = '$v_date'
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

insert overwrite table dw_salary_brand_shop_compare_shop_sum_d partition (dayid='$v_date')
SELECT planno,
       plan_month,
       update_time,
       update_month,
       shop_id,
       shop_name,
       brand_id,
       brand_name,
       total_gmv_less_refund,
       if(total_gmv_less_refund > valid_brand_line, 1, 0) as is_valid_brand
FROM cur
" &&

exit 0