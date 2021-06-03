CREATE TABLE IF NOT EXISTS ads_salary_biz_frozen_pure_gmv_d (
  service_user_id string COMMENT '服务人员id',
  commission_summary decimal(11,2) COMMENT '提成总和',
  milk_commission_summary decimal(11,2) COMMENT '奶粉提成',
  diaper_commission_summary decimal(11,2) COMMENT '尿不湿提成',
  shampoo_commission_summary decimal(11,2) COMMENT '洗衣液提成',
  other_commission_summary decimal(11,2) COMMENT '其他提成',
  num01_pure_b_pay_amount decimal(18,2) COMMENT '分类01 提成',
  num02_pure_b_pay_amount decimal(18,2) COMMENT '分类02 提成',
  num03_pure_b_pay_amount decimal(18,2) COMMENT '分类03 提成',
  num04_pure_b_pay_amount decimal(18,2) COMMENT '分类04 提成',
  num05_pure_b_pay_amount decimal(18,2) COMMENT '分类05 提成',
  num06_pure_b_pay_amount decimal(18,2) COMMENT '分类06 提成',
  num07_pure_b_pay_amount decimal(18,2) COMMENT '分类07 提成',
  num08_pure_b_pay_amount decimal(18,2) COMMENT '分类08 提成',
  pickup_card_commission_summary decimal(18,2) COMMENT '提货卡充值提成总和',
  goods_commission_summary decimal(18,2) COMMENT '实货支付提成总和',
  num01_pure_b_pay_name string COMMENT '分类01提成名称',
  num02_pure_b_pay_name string COMMENT '分类02提成名称',
  num03_pure_b_pay_name string COMMENT '分类03提成名称',
  num04_pure_b_pay_name string COMMENT '分类04提成名称',
  num05_pure_b_pay_name string COMMENT '分类05提成名称',
  num06_pure_b_pay_name string COMMENT '分类06提成名称',
  num07_pure_b_pay_name string COMMENT '分类07提成名称',
  num08_pure_b_pay_name string COMMENT '分类08提成名称',
  num09_pure_b_pay_amount decimal(18,2) COMMENT '分类09 提成',
  num09_pure_b_pay_name string COMMENT '分类09提成名称'
)
comment '销售汇总数据'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;