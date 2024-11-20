CREATE TABLE IF NOT EXISTS ads_crm_visit_user_d(
	user_id STRING COMMENT '用户id',
    user_real_name STRING COMMENT '用户名',
    user_dept_root_key STRING COMMENT '用户部门rootkey',
    user_root_key STRING COMMENT '用户人员rootkey',
    user_name_root_key STRING COMMENT '用户名人员rootkey',
    user_parent_root_key STRING COMMENT '用户父级人员rootkey',
    user_name_parent_root_key STRING COMMENT '用户名父级人员rootkey'
)
PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_visit_user_indicator_d(
    data_month STRING COMMENT '指标月份',
    user_id STRING COMMENT '用户id',
    tab_type INT COMMENT '指标类型， 0我自己的 1我团队的 2我下属的',
    biz_value STRING COMMENT '业务数据json'
)
PARTITIONED BY (dayid STRING);

