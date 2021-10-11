create table if not exists dwd_bounty_plan_d
(
    id bigint comment '',
    no string comment '方案编号',
    name string comment '方案名称',
    remark string comment '方案备注',
    biz_group_id bigint comment '业务组ID',
    biz_group_name string comment '业务组名称',
    month string comment '方案月份，格式：2019-12',
    bounty_payout_object_id bigint comment '发放对象ID',
    bounty_rule_type tinyint comment '模板规则，枚举：1为存量GMV',
    bounty_indicator_id bigint comment '统计指标ID',
    filter_config_json string comment '过滤条件',
    payout_rule_type tinyint comment '提成类型，枚举：1返现、2返点、3返物',
    payout_config_json string comment '提成系数及规则',
    coefficient_config_json string comment '提成系数及规则',
    payout_upper_limit decimal comment '提成上限',
    last_edit_time string comment '最后修改时间',
    creator string comment '创建人ID',
    editor string comment '修改人ID',
    create_time string comment '创建时间',
    edit_time string comment '修改时间',
    is_deleted tinyint comment '',
    subject_id  bigint comment '方案对应的P0项目id',
    owner_type tinyint comment '方案归属类型：1业务组 2销售部'
    )
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc
location '/dw/ytdw/dwd/dwd_bounty_plan_d';