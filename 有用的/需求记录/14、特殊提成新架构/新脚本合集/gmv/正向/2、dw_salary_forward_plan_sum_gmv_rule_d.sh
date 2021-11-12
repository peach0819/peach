v_date=$1

# 是否开启补数模式，开启1，不开启空
supply_data_mode=$4
# 特殊提成补数方案 where语句
supply_data_where_condition=$(cat "$5")

# 变量：特殊提成方案表，在补数和非补数情况下，方案表不同
# 1. 补数情况：当补数脚本 dw_salary_supply_data_all 运行时会传补数 where 条件
# 2. 正常情况：用自己的 bounty_plan_payout 表
bounty_plan_table='bounty_plan_payout'

if [ $supply_data_mode ]; then
	bounty_plan_table='bounty_plan_payout_supply_data'
else
	supply_data_where_condition='1 = 0'
	bounty_plan_table='bounty_plan_payout'
fi

source ../sql_variable.sh $v_date
source ../yarn_variable.sh dw_salary_forward_gmv_rule_plan_sum_d '肥桃'

spark-sql $spark_yarn_job_name_conf $spark_yarn_queue_name_conf --master yarn --executor-memory 4G --num-executors 4 -v -e "
use ytdw;
--奖励类型 dw_bounty_plan_d.payout_rule_type, 业绩目标计算（原来的sts_target）, 提成上限 dw_bounty_plan_d.payout_upper_limit, 奖励配置 dw_bounty_plan_d.payout_config_json
--ytdw.bounty_payout(Integer payoutRuleTypeCode, String target, Double upperLimit, String payoutJson)

set hivevar:bounty_columns=t1.no,
        t1.bounty_rule_type,
        t1.payout_rule_type,
        t1.payout_upper_limit,
        t1.payout_config_json,
        t1.bounty_payout_object_id,
        case when t1.payout_rule_type = 1 then '累计阶梯返现'
             when t1.payout_rule_type = 2 then '累计阶梯返点'
             when t1.payout_rule_type = 3 then '累计阶梯返实物'
             when t1.payout_rule_type = 4 then '累计阶梯单价返点'
             when t1.payout_rule_type = 5 then '排名返现'
             end as commission_plan_type;

with
-- 补数情况下使用的表
bounty_plan_payout_supply_data as
(select \${bounty_columns}
   from dw_bounty_plan_d t1
  where ${supply_data_where_condition}
),
-- 正常方案表
bounty_plan_payout as
(select \${bounty_columns}
   from dw_bounty_plan_d t1
  where dayid ='$v_date'
    and is_deleted =0
    and t1.bounty_rule_type =1
    and month=concat(substr('$v_date',1,4),'-',substr('$v_date',5,2))
),
-- 补数业务逻辑相关
-- 计算的是不参与补数的计算结果数据
without_supply_data_plan as (
select
gmv.update_time,
      gmv.update_month,
      gmv.plan_month,
      gmv.plan_pay_time,
      gmv.plan_no,
      gmv.plan_name,
      gmv.plan_group_id,
      gmv.plan_group_name,
      gmv.grant_object_type,
      gmv.grant_object_user_id,
      gmv.grant_object_user_name,
      gmv.grant_object_user_dep_id,
      gmv.grant_object_user_dep_name,
      gmv.leave_time,
      gmv.sts_target_name,
      gmv.sts_target,
      gmv.real_coefficient_goal_rate,
      gmv.commission_cap,
      gmv.commission_plan_type,
      gmv.commission_reward_type,
      gmv.commission_reward,
      gmv.planno
from (
    select
      *
    from dw_salary_forward_plan_sum_new_d
    where dayid = '$v_date' and bounty_rule_type=1
  ) gmv left join (
  	select no
    from dw_bounty_plan_d t1
    where ${supply_data_where_condition}
  ) plan
  on gmv.planno = plan.no
  -- 关联不上的，就是不参与补数据
  where plan.no is null
  -- 非补数模式下自动跳过
  and 1='${supply_data_mode}'
)

insert overwrite table dw_salary_forward_plan_sum_new_d partition (dayid='$v_date',bounty_rule_type=1)
select
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,--更新时间
    from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,--执行月份
    --方案基础信息
    plan_month,--方案月份
    plan_pay_time,--方案时间
	planno,--方案编号
    plan_name,--方案名称
    plan_group_id,--归属业务组ID
    plan_group_name,--归属业务组
     ---以下为个性化的配置信息---
    grant_object_type,--发放对象类型
    grant_object_user_id, --发放对象ID
    grant_object_user_name,--发放对象名称
	grant_object_user_dep_id,--发放对象部门ID
    grant_object_user_dep_name,--发放对象部门
    leave_time,--发放对象离职时间
    sts_target_name, --统计指标名称
	sts_target,--统计指标数值
    concat('grant_object_rk:',
            nvl(case when commission_plan_type ='排名返现' then grant_object_rk else null end,''),
            '\;',
            'grant_object_underling_cnt:',
            '') as real_coefficient_goal_rate,--方案扩展字段
    payout_upper_limit as commission_cap,
    commission_plan_type as commission_plan_type,--提成方案类型
    case when payout_rule_type=3 then '实物' else '金额' end  as commission_reward_type,--提成奖品类型
    case when payout_rule_type=5 and grant_object_rk is null then 0
    else ytdw.bounty_payout(payout_rule_type,
                       case when payout_rule_type=1 then sts_target
                            when payout_rule_type=2 then sts_target
                            when payout_rule_type=3 then sts_target
                            when payout_rule_type=5 then grant_object_rk
                            end ,
                       payout_upper_limit,
                       payout_config_json) end as commission_reward, --提成奖品
    planno
--payout_rule_type, grant_object_rk, payout_upper_limit,payout_config_json
             from
 (
    select
        --方案基础信息,
        plan_month,--方案月份
        plan_pay_time,--方案时间
        planno,--方案编号
        plan_name,--方案名称
        plan_group_id,--归属业务组ID
        plan_group_name,--归属业务组
        ---以下为个性化的配置信息---
        grant_object_type,--发放对象类型
        grant_object_user_id, --发放对象ID
        grant_object_user_name,--发放对象名称
        grant_object_user_dep_id,--发放对象部门ID
        grant_object_user_dep_name,--发放对象部门
        leave_time,--发放对象离职时间
        --统计指标名称
        sts_target_name,
        --发放对象的当月系数
        sts_target,
        payout_rule_type,
        payout_upper_limit,
        payout_config_json,
        commission_plan_type,
        if(sts_target>0,rank()over(partition by planno order by sts_target desc ),null) as grant_object_rk
    from (
        select
            --方案基础信息,
            plan_month,--方案月份
            plan_pay_time,--方案时间
            planno,--方案编号
            plan_name,--方案名称
            plan_group_id,--归属业务组ID
            plan_group_name,--归属业务组
             ---以下为个性化的配置信息---
            grant_object_type,--发放对象类型
            grant_object_user_id, --发放对象ID
            grant_object_user_name,--发放对象名称
            grant_object_user_dep_id,--发放对象部门ID
            grant_object_user_dep_name,--发放对象部门
            leave_time,--发放对象离职时间
            --统计指标名称
            sts_target_name,
            --发放对象的当月系数
            sum(sts_target) as sts_target,
            payout_rule_type,
            payout_upper_limit,
            payout_config_json,
            commission_plan_type
        from (select * from dw_salary_gmv_rule_public_new_d where dayid ='$v_date' and pltype='cur') t1
        inner join ${bounty_plan_table} t2
          on t1.planno = t2.no
        group by
            plan_month,--方案月份
            plan_pay_time,--方案时间
            planno,--方案编号
            plan_name,--方案名称
            plan_group_id,--归属业务组ID
            plan_group_name,--归属业务组
             ---以下为个性化的配置信息---
            grant_object_type,--发放对象类型
            grant_object_user_id, --发放对象ID
            grant_object_user_name,--发放对象名称,
            grant_object_user_dep_id,--发放对象部门ID
            grant_object_user_dep_name,--发放对象部门
            leave_time,--发放对象离职时间
            --统计指标名称
            sts_target_name,
            payout_rule_type,
            payout_upper_limit,
            payout_config_json,
            commission_plan_type
         ) forward_plan_tmp
	) forward_plan

    union all

  	select * from without_supply_data_plan
;
" &&

exit 0