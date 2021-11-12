v_date=$1

# 是否开启补数模式，开启1，不开启空
supply_data_mode=$4
# 特殊提成补数方案 where语句
supply_data_where_condition=$(cat "$5")

# 变量：特殊提成方案表，在补数和非补数情况下，方案表不同
# 1. 补数情况：当补数脚本 dw_salary_supply_data_all 运行时会传补数 where 条件
# 2. 正常情况：用自己的 bounty_plan_payout 表
bounty_plan_table='bounty_plan'

if [[ $supply_data_mode != "" ]]
then
	bounty_plan_table='bounty_plan_supply_data'
else
	supply_data_where_condition='0 = 1'
	bounty_plan_table='bounty_plan'
fi

source ../sql_variable.sh $v_date
source ../yarn_variable.sh dw_salary_backward_plan_sum_d '肥桃'

spark-sql $spark_yarn_job_name_conf $spark_yarn_queue_name_conf --master yarn --executor-memory 4G --num-executors 4 -v -e "
use ytdw;

with
-- 补数情况下使用的表
bounty_plan_supply_data as
(select no
  from dw_bounty_plan_d t1
  where ${supply_data_where_condition}
),
-- 正常方案表
bounty_plan as
(select no from dw_bounty_plan_d
   where dayid =replace(date_add(from_unixtime(unix_timestamp(),'yyyy-MM-dd'),-1),'-','')
   and is_deleted =0
   and status =1
),
-- 补数业务逻辑相关
-- 计算的是不参与补数的计算结果数据
without_supply_data_plan as (
select
	  t1.update_time,
      t1.update_month,
      t1.plan_month,
      t1.plan_pay_time,
      t1.plan_no,
      t1.plan_name,
      t1.plan_group_id,
      t1.plan_group_name,
      t1.grant_object_type,
      t1.grant_object_user_id,
      t1.grant_object_user_name,
      t1.grant_object_user_dep_id,
      t1.grant_object_user_dep_name,
      t1.leave_time,
      t1.sts_target_name,
      t1.sts_target,
      t1.real_coefficient_goal_rate,
      t1.commission_cap,
      t1.commission_plan_type,
      t1.commission_reward_type,
      t1.cur_commission_reward,
      t1.pre_commission_reward,
      t1.commission_reward_change,
      t1.planno
from (
    select
      *
    from dw_salary_backward_plan_sum_new_d
    where dayid = '$v_date'
  ) t1 left join (
  	select no
    from dw_bounty_plan_d t1
    where ${supply_data_where_condition}
  ) plan
  on t1.planno = plan.no
  -- 关联不上的，就是不参与补数据
  where plan.no is null
  -- 非补数模式下自动跳过
  and 1='${supply_data_mode}'
)
insert overwrite table dw_salary_backward_plan_sum_new_d partition (dayid='$v_date')
select
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,--更新时间
    from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,--执行月份
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
    case when pre_plan.commission_plan_type='排名返现' and cur_plan.commission_reward>pre_plan.commission_reward
    then pre_plan.commission_reward else cur_plan.commission_reward end as cur_commission_reward,--当前统计的提成奖品
	pre_plan.commission_reward as pre_commission_reward,--上一月份的提成奖品
    case when pre_plan.commission_reward_type='金额' then
         round(case when pre_plan.commission_plan_type='排名返现'
                     and cur_plan.commission_reward>pre_plan.commission_reward
                    then pre_plan.commission_reward
                    else cur_plan.commission_reward end -
               pre_plan.commission_reward, 2)
    when pre_plan.commission_reward_type='实物'
        and cur_plan.commission_reward!= pre_plan.commission_reward
        then concat_ws('-',cur_plan.commission_reward,pre_plan.commission_reward)
	else null end as commission_reward_change ,--提成奖品变化
	pre_plan.plan_no
 from
 (
   select  * from dw_salary_backward_plan_sum_mid_new_d
    where dayid ='$v_pre_month_last_day'
      and plan_month < '$v_cur_month'
      and plan_month>=replace(add_months('$v_op_month',-11),'-','')
      --最近12个月内的方案月份
	) pre_plan

left join
	( select * from dw_salary_backward_plan_sum_mid_new_d
     where dayid ='$v_date'
	) cur_plan on pre_plan.plan_no=cur_plan.plan_no
    and pre_plan.grant_object_user_id=cur_plan.grant_object_user_id
left join
--根据dw_bounty_plan_d最新dayid数据中的有效方案编号进行过滤
   ${bounty_plan_table}  bounty
  on pre_plan.plan_no = bounty.no
where bounty.no is not null

union all
	select * from without_supply_data_plan;
" &&

exit 0