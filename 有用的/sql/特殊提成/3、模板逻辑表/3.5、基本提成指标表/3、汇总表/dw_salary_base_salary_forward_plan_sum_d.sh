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
           if(payout_rule_type = 3, '实物', '金额') as commission_reward_type,
           case when payout_rule_type = 1 then '累计阶梯返现'
                when payout_rule_type = 2 then '累计阶梯返点'
                when payout_rule_type = 3 then '累计阶梯返实物'
                when payout_rule_type = 4 then '累计阶梯单价返点'
                when payout_rule_type = 5 then '排名返现'
                end as commission_plan_type,
           replace(replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),']',''),'\"',''),'[',''),',','~') as plan_pay_time
    FROM dw_bounty_plan_schedule_d
    WHERE array_contains(split(forward_date, ','), '$v_date')
    AND ('$supply_mode' = 'not_supply' OR array_contains(split(supply_date, ','), '$supply_date'))
    AND bounty_rule_type = 1
),

detail as (
    SELECT planno,
           grant_object_user_id,
           grant_object_user_name,
           grant_object_dept_id,
           grant_object_dept_name,
           leave_time,
           sts_target
    FROM dw_salary_base_salary_public_d
    WHERE dayid = '$v_date'
    AND pltype = 'cur'
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
           plan.commission_reward_type,
           plan.commission_plan_type,

           --方案数据
           detail.grant_object_user_id,
           detail.grant_object_user_name,
           detail.grant_object_dept_id,
           detail.grant_object_dept_name,
           detail.leave_time,

           --统计指标
           1 as grant_object_underling_cnt,
           detail.sts_target,

           --排名
           row_number() over(partition by plan.no order by sts_target desc) as grant_object_rk
    from plan
    INNER JOIN detail ON plan.no = detail.planno
)

insert overwrite table dw_salary_forward_plan_sum_d partition (dayid='$v_date', bounty_rule_type=5)
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
       grant_object_dept_id,
       grant_object_dept_name,
       leave_time,
       sts_target_name,
       sts_target,
       concat('grant_object_rk:', if(commission_plan_type ='排名返现', grant_object_rk, ''), '\;grant_object_underling_cnt:', grant_object_underling_cnt) as real_coefficient_goal_rate,
       commission_cap,
       commission_plan_type,
       commission_reward_type,
       if(
          payout_rule_type=5 and (sts_target <= 0 OR (commission_cap is not null AND sts_target < commission_cap)),
          0,
          ytdw.bounty_payout(payout_rule_type, if(payout_rule_type IN (1,2,3,4), sts_target, grant_object_rk), commission_cap, payout_config_json)
       ) as commission_reward,
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
       commission_reward,
       planno
FROM (
    SELECT *
    FROM dw_salary_forward_plan_sum_d
    WHERE dayid = '$v_date'
    AND bounty_rule_type=5
) history
LEFT JOIN (
    SELECT no FROM plan
) cur_plan ON history.planno = cur_plan.no
WHERE cur_plan.no is null
;
" &&

exit 0