v_date=$1

source ../sql_variable.sh $v_date

apache-spark-sql -e "
use ytdw;
create table if not exists dw_bounty_plan_schedule_d
(
    id                        bigint comment '',
    no                        string comment '方案编号',
    name                      string comment '方案名称',
    remark                    string comment '方案备注',
    biz_group_id              bigint comment '业务组ID',
    biz_group_name            string comment '业务组名称',
    time_type                 tinyint comment '方案时间类型 1月度方案 2季度方案',
    month                     string comment '方案月份，格式：2019-12',
    bounty_payout_object_id   bigint comment '发放对象ID',
    bounty_payout_object_code string comment '发放对象code',
    bounty_payout_object_name string comment '发放对象名',
    bounty_rule_type          tinyint comment '模板规则，枚举：1为存量GMV',
    bounty_indicator_id       bigint comment '统计指标ID',
    bounty_indicator_code     string comment '统计指标code',
    bounty_indicator_name     string comment '统计指标名',
    payout_rule_type          tinyint comment '提成类型，枚举：1返现、2返点、3返物',
    payout_config_json        string comment '提成系数及规则',
    payout_upper_limit        decimal comment '提成上限',
    creator                   string comment '创建人ID',
    create_time               string comment '创建时间',
    subject_id                bigint comment '方案对应的P0项目id',
    owner_type                tinyint comment '方案归属类型：1业务组 2销售部',
    filter_config_json        string comment '过滤条件',
    forward_date              string comment '需要跑正向的日期',
    backward_date             string comment '需要跑逆向的日期',
    supply_date               string comment '需要补数的日期'
)
comment '特殊提成方案调度表'
partitioned by (dayid string)
stored as orc;

insert overwrite table dw_bounty_plan_d partition(dayid='$v_date')
SELECT plan.id,
       plan.no,
       plan.name,
       plan.remark,
       plan.biz_group_id,
       plan.biz_group_name,
       1 as time_type,
       plan.month,

       plan.bounty_payout_object_id,
       object.code as bounty_payout_object_code,
       object.name as bounty_payout_object_name,

       plan.bounty_rule_type,

       plan.bounty_indicator_id,
       indicator.code as bounty_indicator_code,
       indicator.title as bounty_indicator_name,

       plan.payout_rule_type,
       plan.payout_config_json,
       plan.payout_upper_limit,
       plan.creator,
       plan.create_time,
       plan.subject_id,
       plan.owner_type,
       plan.filter_config_json,

       ytdw.plan_schedule_time(plan.month, plan.create_time, 1, 1) as forward_date,
       ytdw.plan_schedule_time(plan.month, plan.create_time, 1, 2) as backward_date,
       ytdw.plan_schedule_time(plan.month, plan.create_time, 1, 3) as supply_date
FROM (
    SELECT *
    FROM dw_bounty_plan_d
    WHERE dayid = '$v_date'
    AND is_deleted = 0
    AND status = 1
) plan

LEFT JOIN (
    select * from dwd_bounty_payout_object_d where dayid='$v_date'
) object ON plan.bounty_payout_object_id = object.id

LEFT JOIN (
    select * from dwd_bounty_indicator_d where dayid='$v_date'
) indicator ON plan.bounty_indicator_id = indicator.id
"