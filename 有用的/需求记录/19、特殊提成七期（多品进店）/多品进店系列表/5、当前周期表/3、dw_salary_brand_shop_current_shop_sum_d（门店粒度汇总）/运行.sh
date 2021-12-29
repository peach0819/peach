v_date=$1
pltype=$2

if [[ $pltype = "" ]]
then
	pltype='cur'
fi

source ../sql_variable.sh $v_date
source ../yarn_variable.sh dw_salary_brand_shop_current_shop_sum_d '肥桃'

spark-sql $spark_yarn_job_name_conf $spark_yarn_queue_name_conf --master yarn --executor-memory 4G --num-executors 4 -v -e "
use ytdw;

with cur as (
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
    FROM dw_salary_brand_shop_current_object_sum_d
    WHERE dayid = '$v_date'
    AND pltype = '$pltype'
    AND is_valid_brand = 1
    HAVING rank = 1
)

insert overwrite table dw_salary_brand_shop_current_shop_sum_d partition (dayid='$v_date', pltype='$pltype')
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
;
" &&

exit 0