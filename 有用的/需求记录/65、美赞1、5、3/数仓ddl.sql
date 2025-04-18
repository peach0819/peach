CREATE TABLE IF NOT EXISTS ads_crm_visit_user_indicator_detail_d
(
  data_month STRING COMMENT '目标月份',
  user_id STRING COMMENT '用户id',
  indicator_code STRING COMMENT '指标code',
  service_obj_id STRING COMMENT '拜访对象id',
  service_obj_name STRING COMMENT '拜访对象名称',
  biz_value STRING COMMENT '业务数据json'
) PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_visit_user_indicator_v2_d(
    data_month STRING COMMENT '指标月份',
    user_id STRING COMMENT '用户id',
    tab_type INT COMMENT '指标类型， 0我自己的 1我团队的 2我下属的',
    biz_value STRING COMMENT '业务数据json'
)
PARTITIONED BY (dayid STRING);

CREATE TABLE IF NOT EXISTS ads_crm_visit_user_indicator_visible_d(
    user_id STRING COMMENT '用户id',
    visible_config STRING COMMENT '可见性配置'
)
PARTITIONED BY (dayid STRING);