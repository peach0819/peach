v_date=$1
supply_date=$4
supply_mode='not_supply'

if [[ $supply_date != "" ]]
then
  supply_mode='supply'
fi

source ../sql_variable.sh $v_date
source ../yarn_variable.sh dw_salary_backward_brand_shop_plan_sum_mid_d '肥桃'

spark-sql $spark_yarn_job_name_conf $spark_yarn_queue_name_conf --master yarn --executor-memory 4G --num-executors 4 -v -e "
use ytdw;

with plan as (
    SELECT no,
           month,
           name,
           biz_group_id,
           biz_group_name,
           bounty_payout_object_id,
           bounty_payout_object_code,
           bounty_payout_object_name,
           bounty_rule_type,
           bounty_indicator_id,
           bounty_indicator_code,
           bounty_indicator_name,
           payout_rule_type,
           payout_config_json,
           payout_upper_limit,
           replace(replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.calculate_date_quarter'),'$.value'),']',''),'\"',''),'[',''),',','~') as plan_pay_time,
           if('$pltype' = 'cur', '$v_date', split(backward_date, ',')[0]) as plan_date
    FROM dw_bounty_plan_schedule_d
    WHERE array_contains(split(backward_date, ','), '$v_date')
    AND ('$supply_mode' = 'not_supply' OR array_contains(split(supply_date, ','), '$supply_date'))
    AND bounty_rule_type = 4
),

detail as (
    SELECT planno,
           grant_object_user_id,
           sum(compare_brand_shop_num) as compare_brand_shop_num,
           sum(current_brand_shop_num) as current_brand_shop_num,
           sum(brand_shop_score) as brand_shop_score,
           sum(total_gmv_less_refund) as total_gmv_less_refund
    FROM dw_salary_brand_shop_sum_d
    WHERE dayid = '$v_date'
    AND pltype = 'pre'
    group by planno, grant_object_user_id
),

user_admin as (
    SELECT user_id,
           user_real_name,
           leave_time,
           dept_id,
           dept_name,
           start_time,
           end_time
    FROM dim_ytj_pub_user_admin_ds
),

cur as (
    select from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
           from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,

           --方案基础信息
           plan.month as plan_month,
           plan.plan_pay_time,
           plan.no as planno,
           plan.name as plan_name,
           plan.biz_group_id as plan_group_id,
           plan.biz_group_name as plan_group_name,
           plan.bounty_payout_object_name as grant_object_type,
           plan.bounty_indicator_name as sts_target_name,
           plan.payout_upper_limit as commission_cap,
           plan.payout_config_json,
           plan.payout_rule_type,
           if(plan.payout_rule_type = 3, '实物', '金额') as commission_reward_type,
           case when plan.payout_rule_type = 1 then '累计阶梯返现'
                when plan.payout_rule_type = 2 then '累计阶梯返点'
                when plan.payout_rule_type = 3 then '累计阶梯返实物'
                when plan.payout_rule_type = 4 then '累计阶梯单价返点'
                when plan.payout_rule_type = 5 then '排名返现'
           end as commission_plan_type,

           --方案数据
           detail.grant_object_user_id,
           user_admin.user_real_name as grant_object_user_name,
           user_admin.dept_id as grant_object_user_dep_id,
           user_admin.dept_name as grant_object_user_dep_name,
           user_admin.leave_time,
           case when plan.bounty_indicator_name = '有效品牌门店数变化' then detail.current_brand_shop_num - detail.compare_brand_shop_num
                when plan.bounty_indicator_name = '有效品牌门店数' then detail.current_brand_shop_num
                when plan.bounty_indicator_name = '多品在店积分' then detail.brand_shop_score
           end as sts_target,

           row_number() over(partition by plan.no order by (
                case when plan.bounty_indicator_name = '有效品牌门店数变化' then detail.current_brand_shop_num - detail.compare_brand_shop_num
                     when plan.bounty_indicator_name = '有效品牌门店数' then detail.current_brand_shop_num
                     when plan.bounty_indicator_name = '多品在店积分' then detail.brand_shop_score
                end
           ) desc, detail.total_gmv_less_refund desc) as grant_object_rk
    from plan
    INNER JOIN detail ON plan.no = detail.planno
    LEFT JOIN user_admin ON user_admin.user_id = detail.grant_object_user_id AND user_admin.start_time <= concat(plan.plan_date, '235959') AND user_admin.end_time >= concat(plan.plan_date, '235959')
)

insert overwrite table dw_salary_backward_plan_sum_mid_d partition (dayid='$v_date',bounty_rule_type=4)
SELECT update_time,
       update_month,
       plan_month,
       plan_pay_time,
       planno as plan_no,
       plan_name,
       plan_group_id,
       plan_group_name,
       grant_object_type,
       grant_object_user_id,
       grant_object_user_name,
       grant_object_user_dep_id,
       grant_object_user_dep_name,
       leave_time,
       sts_target_name,
       sts_target,
       concat('grant_object_rk:', if(commission_plan_type ='排名返现', if(sts_target > 0, grant_object_rk, ''), ''), '\;grant_object_underling_cnt:') as real_coefficient_goal_rate,
       commission_cap,
       commission_plan_type,
       commission_reward_type,
       if(
          payout_rule_type=5 and sts_target <= 0,
          0,
          ytdw.bounty_payout(payout_rule_type, if(payout_rule_type IN (1,3,4), sts_target, grant_object_rk), commission_cap, payout_config_json)
       ) as commission_reward,
       planno
FROM cur

UNION ALL

SELECT update_time,
       update_month,
       plan_month,
       plan_pay_time,
       planno as plan_no,
       plan_name,
       plan_group_id,
       plan_group_name,
       grant_object_type,
       grant_object_user_id,
       grant_object_user_name,
       grant_object_user_dep_id,
       grant_object_user_dep_name,
       leave_time,
       sts_target_name,
       sts_target,
       real_coefficient_goal_rate,
       commission_cap,
       commission_plan_type,
       commission_reward_type,
       commission_reward,
       planno
FROM (
    SELECT *
    FROM dw_salary_backward_plan_sum_mid_d
    WHERE dayid = '$v_date'
    AND bounty_rule_type=4
) history
LEFT JOIN (
    SELECT no FROM plan
) cur_plan ON history.planno = cur_plan.no
WHERE cur_plan.no is null
;
" &&

exit 0