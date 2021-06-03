
create table if not exists ads_salary_biz_kn_pure_gmv_d (
  service_user_id string COMMENT '服务人员id',
  coefficient_summary decimal(11,2) COMMENT '系数总和',
  a_coefficient_summary decimal(11,2) COMMENT 'a类系数总和',
  b_coefficient_summary decimal(11,2) COMMENT 'b类系统总和',
  a_target_finish decimal(11,2) COMMENT 'a类目标完成',
  b_target_finish decimal(11,2) COMMENT 'b类目标完成',
  pickup_card_coefficient_summary decimal(18,2) COMMENT '提货卡充值系数总和',
  goods_coefficient_summary decimal(18,2) COMMENT '实货支付系数总和'
)
comment '库内净GMV'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;