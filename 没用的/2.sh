function run(){
hive -v -e "
use ytdw;

CREATE TABLE if not exists st_p0_subject_plan_sum_d (
  plan_no_user_id string COMMENT '方案编号_发放对象id',
  subject_id string comment '项目id',
  plan_no	string comment '方案编号',
  grant_object_type	string comment '发放对象类型 如：【岗位】BD',
  grant_object_user_id	string comment '发放对象id',
  grant_object_user_dep_id	string comment '发放对象所属部门',
  war_zone_dep_id	string comment '对象所属战区部门id',
  area_manager_dep_id	string comment '对象所属大区部门id',
  bd_manager_dep_id	string comment '对象所属主管部门id',
  sts_target_name	string comment '统计指标名称',
  sts_target	string comment '统计指标数值',
  real_coefficient_goal_rate	string comment '发放对象的当月系数 （暂不用）',
  commission_cap	string comment '提成上限（暂不用）',
  commission_plan_type	string comment '提成方案类型 如：累计阶梯返现',
  commission_reward_type	string comment '提成方案类型 金额/实物',
  commission_reward	string comment '提成奖品'
)
comment '销售项目方案提成汇总'
partitioned by (dayid string)
stored as orc;

insert overwrite table ytdw.st_p0_subject_plan_sum_d partition (dayid='$2')
select concat(salary_sum.plan_no, '_', salary_sum.grant_object_user_id) as plan_no_user_id,
  plan.subject_id, salary_sum.plan_no,salary_sum.grant_object_type,salary_sum.grant_object_user_id,salary_sum.grant_object_user_dep_id,
  nvl(area_dept.parent_id,0) as war_zone_dep_id,nvl(area_dept.id,0) as area_manager_dep_id,nvl(bd_dept.id,0) as bd_manager_dep_id,
  sts_target_name,sts_target,real_coefficient_goal_rate,commission_cap,commission_plan_type,commission_reward_type,commission_reward
from
(
  select plan_no,grant_object_type,grant_object_user_id,grant_object_user_dep_id,sts_target_name,sts_target,real_coefficient_goal_rate,commission_cap,commission_plan_type,commission_reward_type,commission_reward,dayid
  from dw_salary_forward_plan_sum_d
  where dayid='$2'
  and nvl(grant_object_user_dep_id, '')<>''
) salary_sum
join(
  select no, subject_id from dw_bounty_plan_schedule_d where nvl(subject_id,0)<>0 AND name not like '%测试%'
) plan
on plan.no=salary_sum.plan_no
left join
(
  select id,parent_id
    from dwd_department_d
    where dayid='$2'
) bd_dept
on salary_sum.grant_object_user_dep_id=bd_dept.id
left join
(
  select id,parent_id
    from dwd_department_d
    where dayid='$2'
) area_dept
on bd_dept.parent_id=area_dept.id
"
}

source ../sql_variable.sh $v_date
v_date=$1
#本月1号
v_first_day=$(date -d"$1" +%Y%m01)
#上月最后一天
v_pre_month_last_day=$(date -d"$v_first_day -1 day" +%Y%m%d)
#上月1号
v_pre_month_first_day=$(date -d"$1 -1 month" +%Y%m01)
#上上月最后一天
v_pre_2_month_last_day=$(date -d"$v_pre_month_first_day -1 day" +%Y%m%d)

run $v_date $v_date &&
run $v_date $v_pre_month_last_day &&
run $v_date $v_pre_2_month_last_day &&
exit 0