v_date=$1

source ../sql_variable.sh $v_date

apache-spark-sql -e "
use ytdw;
create table if not exists dw_bounty_plan_d
(
    id                      bigint comment '',
    no                      string comment '方案编号',
    name                    string comment '方案名称',
    remark                  string comment '方案备注',
    biz_group_id            bigint comment '业务组ID',
    biz_group_name          string comment '业务组名称',
    month                   string comment '方案月份，格式：2019-12',
    bounty_payout_object_id bigint comment '发放对象ID',
    bounty_rule_type        tinyint comment '模板规则，枚举：1为存量GMV',
    bounty_indicator_id     bigint comment '统计指标ID',
    payout_rule_type        tinyint comment '提成类型，枚举：1返现、2返点、3返物',
    payout_config_json      string comment '提成系数及规则',
    coefficient_config_json string comment '提成系数及规则',
    payout_upper_limit      decimal comment '提成上限',
    last_edit_time          string comment '最后修改时间',
    creator                 string comment '创建人ID',
    editor                  string comment '修改人ID',
    create_time             string comment '创建时间',
    edit_time               string comment '修改时间',
    is_deleted              tinyint comment '',
    subject_id              bigint comment '方案对应的P0项目id',
    owner_type              tinyint comment '方案归属类型：1业务组 2销售部',
    filter_config_json      string comment '过滤条件',
    status					        string comment '方案状态 1开启，9废弃',
    time_type               tinyint comment '方案时间类型'
)
comment '特殊提成方案加工表'
partitioned by (dayid string)
stored as orc;

WITH detail as (
    SELECT id,
           no,
           name,
           remark,
           biz_group_id,
           biz_group_name,
           month,
           bounty_payout_object_id,
           bounty_rule_type,
           bounty_indicator_id,
           filter_config_json,
           payout_rule_type,
           payout_config_json,
           coefficient_config_json,
           payout_upper_limit,
           last_edit_time,
           status,
           creator,
           editor,
           create_time,
           edit_time,
           is_deleted,
           subject_id,
           owner_type,
           time_type,
           get_json_object(filter_config, '$.id') as filter_id,
           get_json_object(filter_config, '$.operator') as filter_operator,
           get_json_object(filter_config, '$.values') as filter_values
    FROM (
        SELECT *
        FROM dwd_bounty_plan_d
        lateral view explode(split(regexp_replace(substr(filter_config_json, 2, length(filter_config_json) - 2), '\\\}\\\,\\\{\\\"id','\\\}\\\;\\\{\\\"id'), '\;')) tmp as filter_config
        WHERE dayid = '$v_date'
    ) temp
),

filter as (
    SELECT id as filter_id,
           key as filter_key
    FROM dwd_bounty_filter_d
    WHERE dayid = '$v_date'
),

mid as (
    SELECT detail.id,
           detail.no,
           detail.name,
           detail.remark,
           detail.biz_group_id,
           detail.biz_group_name,
           detail.month,
           detail.status,
           detail.bounty_payout_object_id,
           detail.bounty_rule_type,
           detail.bounty_indicator_id,
           detail.payout_rule_type,
           detail.payout_config_json,
           detail.coefficient_config_json,
           detail.payout_upper_limit,
           detail.last_edit_time,
           detail.creator,
           detail.editor,
           detail.create_time,
           detail.edit_time,
           detail.is_deleted,
           detail.subject_id,
           detail.owner_type,
           filter.filter_key,
           detail.filter_operator,
           detail.filter_values,
           detail.time_type,
           to_json(named_struct('operator', detail.filter_operator, 'value', detail.filter_values)) as filter_struct,
           to_json(map(filter.filter_key, to_json(named_struct('operator', detail.filter_operator, 'value', detail.filter_values)))) as filter_value_json
    FROM detail
    INNER JOIN filter ON detail.filter_id = filter.filter_id
)

insert overwrite table dw_bounty_plan_d partition(dayid='$v_date')
SELECT id,
       no,
       name,
       remark,
       biz_group_id,
       biz_group_name,
       month,
       bounty_payout_object_id,
       bounty_rule_type,
       bounty_indicator_id,
       payout_rule_type,
       payout_config_json,
       coefficient_config_json,
       payout_upper_limit,
       last_edit_time,
       creator,
       editor,
       create_time,
       edit_time,
       is_deleted,
       subject_id,
       owner_type,
       concat('{',concat_ws(',', collect_list(substr(filter_value_json, 2, length(filter_value_json) - 2))),'}') as filter_config_json,
       status,
       time_type
FROM mid
group by id,
         no,
         name,
         remark,
         biz_group_id,
         biz_group_name,
         month,
         status,
         bounty_payout_object_id,
         bounty_rule_type,
         bounty_indicator_id,
         payout_rule_type,
         payout_config_json,
         coefficient_config_json,
         payout_upper_limit,
         last_edit_time,
         creator,
         editor,
         create_time,
         edit_time,
         is_deleted,
         subject_id,
         owner_type,
         time_type
"