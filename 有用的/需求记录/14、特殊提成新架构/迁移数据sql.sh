v_date=$1
v_date2=$2

source ../sql_variable.sh $v_date
source ../yarn_variable.sh dw_salary_forward_plan_sum_new_migration '黄飞8837'

spark-sql $spark_yarn_job_name_conf $spark_yarn_queue_name_conf --master yarn --executor-memory 4G --num-executors 4 -v -e "

use ytdw;

CREATE TABLE if not exists ytdw.dw_salary_forward_plan_sum_new_d(
  update_time                string        COMMENT '更新时间',
  update_month               string        COMMENT '执行月份',
  plan_month                 string        COMMENT '方案月份',
  plan_pay_time              string        COMMENT '方案时间',
  plan_no                    int           COMMENT '方案编号',
  plan_name                  string        COMMENT '方案名称',
  plan_group_id              string        COMMENT '归属业务组id',
  plan_group_name            string        COMMENT '归属业务组',
  grant_object_type          string        COMMENT '发放对象类型',
  grant_object_user_id       string        COMMENT '发放对象ID',
  grant_object_user_name     string        COMMENT '发放对象名称',
  grant_object_user_dep_id   string        COMMENT '发放对象部门ID',
  grant_object_user_dep_name string        COMMENT '发放对象部门',
  leave_time                 string        COMMENT '发放对象离职时间',
  sts_target_name            string        COMMENT '统计指标名称',
  sts_target                 decimal(18,2) COMMENT '统计指标数值',
  real_coefficient_goal_rate string        COMMENT '发放对象的当月系数',
  commission_cap             string        COMMENT '提成上限',
  commission_plan_type       string        COMMENT '提成方案类型',
  commission_reward_type     string        COMMENT '提成奖品类型 金额/实物',
  commission_reward          string        COMMENT '提成奖品',
  planno                     int           COMMENT '方案编号'
)
COMMENT '正向方案汇总表'
PARTITIONED BY (dayid string,bounty_rule_type int)
stored as orc;

set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions=5000;
set hive.exec.max.dynamic.partitions.pernode=5000;

insert overwrite table dw_salary_forward_plan_sum_new_d partition(dayid,bounty_rule_type)
select
  a.update_time                ,
  a.update_month               ,
  a.plan_month                 ,
  a.plan_pay_time              ,
  a.plan_no                    ,
  a.plan_name                  ,
  a.plan_group_id              ,
  a.plan_group_name            ,
  a.grant_object_type          ,
  a.grant_object_user_id       ,
  a.grant_object_user_name     ,
  a.grant_object_user_dep_id   ,
  a.grant_object_user_dep_name ,
  a.leave_time                 ,
  a.sts_target_name            ,
  a.sts_target                 ,
  a.real_coefficient_goal_rate ,
  a.commission_cap             ,
  a.commission_plan_type       ,
  a.commission_reward_type     ,
  a.commission_reward          ,
  a.planno                     ,
  a.dayid                      ,
  b.bounty_rule_type
from (select * from dw_salary_forward_plan_sum_d where dayid = '$v_date2') a
inner join (select * from dwd_bounty_plan_d where dayid='$v_date') b
on a.planno = b.no

" &&

exit 0