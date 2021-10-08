insert overwrite table dw_salary_backward_plan_sum_d partition (dayid = '$v_date', planno = '13165')
select from_unixtime(unix_timestamp(), 'yyyy-MM-dd HH:mm:ss') as update_time,--更新时间
       from_unixtime(unix_timestamp(), 'yyyy-MM')             as update_month,--执行月份
       --方案基础信息,
       pre_plan.plan_month,--方案月份
       pre_plan.plan_pay_time,--方案时间
       pre_plan.planno,--方案编号
       pre_plan.plan_name,--方案名称
       ---以下为个性化的配置信息---
       pre_plan.plan_group_id,--归属业务组ID
       pre_plan.plan_group_name,--归属业务组
       pre_plan.grant_object_type,--发放对象类型
       pre_plan.grant_object_user_id, --发放对象ID
       pre_plan.grant_object_user_name,--发放对象名称,
       pre_plan.grant_object_user_dep_id,--发放对象部门ID
       pre_plan.grant_object_user_dep_name,--发放对象部门
       pre_plan.leave_time,--发放对象离职时间
       --统计指标名称
       pre_plan.sts_target_name,
       pre_plan.sts_target,--统计指标数值
       cur_plan.real_coefficient_goal_rate, --方案扩展字段
       pre_plan.commission_cap,--提成上限
       pre_plan.commission_plan_type,--提成方案类型
       pre_plan.commission_reward_type,--提成奖品类型
       case
           when pre_plan.commission_plan_type = '排名返现' and cur_plan.commission_reward > pre_plan.commission_reward
               then pre_plan.commission_reward
           else cur_plan.commission_reward end                as cur_commission_reward,--当前统计的提成奖品
       pre_plan.commission_reward                             as pre_commission_reward,--上一月份的提成奖品
       case
           when pre_plan.commission_reward_type = '金额' then round(case
                                                                      when pre_plan.commission_plan_type = '排名返现' and
                                                                           cur_plan.commission_reward > pre_plan.commission_reward
                                                                          then pre_plan.commission_reward
                                                                      else cur_plan.commission_reward end -
                                                                  pre_plan.commission_reward, 2)
           when pre_plan.commission_reward_type = '实物'
               and cur_plan.commission_reward != pre_plan.commission_reward
               then concat_ws('-', cur_plan.commission_reward, pre_plan.commission_reward)
           else null end                                      as commission_reward_change --提成奖品变化

from (
         select *
         from dw_salary_backward_plan_sum_mid_d
         where dayid = '$v_pre_month_last_day'
           and plan_no = '13165'
     ) pre_plan

left join
     (select *
      from dw_salary_backward_plan_sum_mid_d
      where dayid = '$v_date'
        and plan_no = '13165'
     ) cur_plan on pre_plan.plan_no = cur_plan.plan_no
         and pre_plan.grant_object_user_id = cur_plan.grant_object_user_id
;