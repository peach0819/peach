v_date=$1
supply_date=$4
supply_mode='not_supply'

if [[ $supply_date != "" ]]
then
  supply_mode='supply'
fi

source ../sql_variable.sh $v_date
source ../yarn_variable.sh dw_salary_backward_plan_sum_d '肥桃'

spark-sql $spark_yarn_job_name_conf $spark_yarn_queue_name_conf --master yarn --executor-memory 4G --num-executors 4 -v -e "
use ytdw;

with plan as (
    SELECT no,
           max(need_supply_date) as pre_date
    FROM dw_bounty_plan_schedule_d
    lateral view explode(split(backward_date,',')) temp as need_supply_date
    WHERE need_supply_date < '$v_date'
    AND array_contains(split(backward_date, ','), '$v_date')
    AND ('$supply_mode' = 'not_supply' OR array_contains(split(supply_date, ','), '$supply_date'))
    group by no
),

pre as (
    select *
    from dw_salary_backward_plan_sum_mid_d
),

today as (
    select *
    from dw_salary_backward_plan_sum_mid_d
    where dayid ='$v_date'
),

ever_rank as (
    SELECT ever.planno,
           ever.grant_object_user_id,
           min(cast(ever.commission_reward as decimal)) as min_comission_reward
    from plan
    INNER JOIN dw_salary_backward_plan_sum_mid_d ever ON ever.planno = plan.no
    WHERE ever.commission_plan_type = '排名返现'
    AND ever.dayid != '$v_date'
    group by ever.planno, ever.grant_object_user_id
),

cur as (
    SELECT from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
           from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,

           --方案基础信息,
           pre.plan_month,
           pre.plan_pay_time,
           pre.planno as plan_no,
           pre.plan_name,
           pre.plan_group_id,
           pre.plan_group_name,
           pre.grant_object_type,
           pre.grant_object_user_id,
           pre.grant_object_user_name,
           pre.grant_object_user_dep_id,
           pre.grant_object_user_dep_name,
           pre.leave_time,

           --统计指标
           pre.sts_target_name,
           today.sts_target,
           today.real_coefficient_goal_rate,
           pre.commission_cap,
           pre.commission_plan_type,
           pre.commission_reward_type,
           if(pre.commission_plan_type='排名返现', least(ever_rank.min_comission_reward, cast(today.commission_reward as decimal)), today.commission_reward) as cur_commission_reward,
           if(pre.commission_plan_type='排名返现', ever_rank.min_comission_reward, pre.commission_reward) as pre_commission_reward,
           case when pre.commission_reward_type='金额'
                then round(
                         if(pre.commission_plan_type='排名返现', least(ever_rank.min_comission_reward, cast(today.commission_reward as decimal)), today.commission_reward)
                         - if(pre.commission_plan_type='排名返现', ever_rank.min_comission_reward, pre.commission_reward),
                         2
                     )
                when pre.commission_reward_type='实物' and today.commission_reward != pre.commission_reward
                then concat_ws('-', today.commission_reward, pre.commission_reward)
                end as commission_reward_change,
           pre.plan_no as planno
    FROM plan
    INNER JOIN pre ON plan.pre_date = pre.dayid and pre.planno = plan.no
    LEFT JOIN ever_rank ON ever_rank.planno = plan.no and ever_rank.grant_object_user_id = pre.grant_object_user_id
    LEFT JOIN today ON today.planno = plan.no and pre.grant_object_user_id = today.grant_object_user_id
)

insert overwrite table dw_salary_backward_plan_sum_d partition (dayid='$v_date')
SELECT update_time,
       update_month,
       plan_month,
       plan_pay_time,
       plan_no,
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
       cur_commission_reward,
       pre_commission_reward,
       commission_reward_change,
       planno
FROM cur

UNION ALL

SELECT update_time,
       update_month,
       plan_month,
       plan_pay_time,
       plan_no,
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
       cur_commission_reward,
       pre_commission_reward,
       commission_reward_change,
       planno
FROM (
    SELECT *
    FROM dw_salary_backward_plan_sum_d
    WHERE dayid = '$v_date'
) history
LEFT JOIN (
    SELECT no FROM plan
) cur_plan ON history.planno = cur_plan.no
WHERE cur_plan.no is null
" &&

exit 0