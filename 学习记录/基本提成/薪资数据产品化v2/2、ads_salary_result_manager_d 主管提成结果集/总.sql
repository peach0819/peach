use ytdw;

create table if not exists ads_salary_result_manager_d (
  user_type_subdivide string comment '类型',
  user_id string  comment 'user_id',
  user_nick_name string comment 'realname',
  dept_name  string comment '部门',
  area_manager_dep_name string comment '归属大区',
  shop_cnt int comment '库内门店数',
  b_pay_shop_cnt int comment 'B类下单门店数 不含服务商',
  pure_b_gmv  decimal(11,2) comment 'B类净GMV 不含服务商',
  pure_b_pay_amount decimal(11,2)  comment 'B类净支付金额 不含服务商',
  pure_b_offline_refund decimal(11,2)  comment 'B类线下退款金额之和',
  pure_b_refund decimal(18,2)  comment 'B类线上退款金额之和',
  num01_pure_b_pay_amount decimal(11,2)  comment '分类01 净支付金额',
  num02_pure_b_pay_amount decimal(11,2)  comment '分类02 净支付金额',
  num03_pure_b_pay_amount decimal(11,2)  comment '分类03 净支付金额',
  num04_pure_b_pay_amount decimal(11,2)  comment '分类04 净支付金额',
  num05_pure_b_pay_amount decimal(11,2)  comment '分类05 净支付金额',
  num06_pure_b_pay_amount decimal(11,2)  comment '分类06 净支付金额',
  shop_cnt_not_bigbd int comment '库内门店数_非大BD门店',
  b_pay_shop_cnt_not_bigbd int comment 'B类下单门店数_非大BD门店 不含服务商',
  pure_b_gmv_not_bigbd  decimal(11,2) comment 'B类净GMV_非大BD门店 不含服务商',
  pure_b_pay_amount_not_bigbd decimal(11,2)  comment 'B类净支付金额_非大BD门店 不含服务商',
  pure_b_offline_refund_not_bigbd decimal(11,2)  comment 'B类线下退款金额之和_非大BD门店',
  pure_b_refund_not_bigbd decimal(18,2)  comment 'B类线上退款金额之和_非大BD门店',
  num01_pure_b_pay_amount_not_bigbd decimal(11,2)  comment '分类01 净支付金额_非大BD门店',
  num02_pure_b_pay_amount_not_bigbd decimal(11,2)  comment '分类02 净支付金额_非大BD门店',
  num03_pure_b_pay_amount_not_bigbd decimal(11,2)  comment '分类03 净支付金额_非大BD门店',
  num04_pure_b_pay_amount_not_bigbd decimal(11,2)  comment '分类04 净支付金额_非大BD门店',
  num05_pure_b_pay_amount_not_bigbd decimal(11,2)  comment '分类05 净支付金额_非大BD门店',
  num06_pure_b_pay_amount_not_bigbd decimal(11,2)  comment '分类06 净支付金额_非大BD门店',
  target bigint  comment 'B类基础目标',
  target_ensure double  comment 'B类保底目标',
  target_dash double  comment 'B类冲刺目标',
  class_number_info string comment '分类信息',
  update_time string comment '更新时间',
  war_zone_dep_name string comment '战区' ,
  coefficient_goal_rate string comment '系统计算目标完成率',
  upload_coefficient string comment '当月手动上传完成率',
  real_coefficient_goal_rate string comment '理论目标完成率' ,
  num07_pure_b_pay_amount decimal(11,2)  comment '分类07 净支付金额',
  num08_pure_b_pay_amount decimal(11,2)  comment '分类08 净支付金额',
  num07_pure_b_pay_amount_not_bigbd decimal(11,2)  comment '分类07 净支付金额',
  num08_pure_b_pay_amount_not_bigbd decimal(11,2)  comment '分类08 净支付金额',
  cur_b_gmv_shop_cnt	int comment '当月满500支付门店数'--当月满500支付门店数
)comment 'BD主管/大区经理薪资汇总表(不含服务商数据)'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;

insert overwrite table ads_salary_result_manager_d partition (dayid='$v_date')

select
  manager_summary.user_type_subdivide,
  manager_summary.user_id,
  user_real_name as  user_nick_name,
  dept_name,
  area_manager_dep_name,
  shop_cnt,
  b_pay_shop_cnt,
  pure_b_gmv,
  pure_b_pay_amount,
  pure_b_offline_refund,
  pure_b_refund,
  num01_pure_b_pay_amount,
  num02_pure_b_pay_amount,
  num03_pure_b_pay_amount,
  num04_pure_b_pay_amount,
  num05_pure_b_pay_amount,
  num06_pure_b_pay_amount,
  shop_cnt_not_bigbd,
  b_pay_shop_cnt_not_bigbd,
  pure_b_gmv_not_bigbd,
  pure_b_pay_amount_not_bigbd,
  pure_b_offline_refund_not_bigbd,
  pure_b_refund_not_bigbd,
  num01_pure_b_pay_amount_not_bigbd,
  num02_pure_b_pay_amount_not_bigbd,
  num03_pure_b_pay_amount_not_bigbd,
  num04_pure_b_pay_amount_not_bigbd,
  num05_pure_b_pay_amount_not_bigbd,
  num06_pure_b_pay_amount_not_bigbd,
  target,--系统目标
  null as target_ensure,
  null as target_dash,
  class_number_info,
  from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,
  war_zone_dep_name,
  null as coefficient_goal_rate,--系统计算目标完成率
  round(sales_coefficient.coefficient,2) as upload_coefficient,--当月手动上传完成率
  round(sales_coefficient.coefficient,2) as real_coefficient_goal_rate, --理论目标完成率
  num07_pure_b_pay_amount,
  num08_pure_b_pay_amount,
  num07_pure_b_pay_amount_not_bigbd,
  num08_pure_b_pay_amount_not_bigbd,
  cur_b_gmv_shop_cnt	--当月满500支付门店数
from
(
  select
    user_type_subdivide,
    user_id,
    area_manager_dep_name,--归属大区
    shop_cnt,--库内门店数
    b_pay_shop_cnt ,--B类下单门店数  不含服务商
    pure_b_gmv,--B类净GMV  不含服务商
    pure_b_pay_amount,--B类净支付金额  不含服务商
    pure_b_offline_refund,--B类线下退款金额之和    指单独的那张线下退款的表的金额
    pure_b_refund ,--B类线上退款金额之和   指线上的订单表里的退款金额,
    num01_pure_b_pay_amount,
    num02_pure_b_pay_amount,
    num03_pure_b_pay_amount,
    num04_pure_b_pay_amount,
    num05_pure_b_pay_amount,
    num06_pure_b_pay_amount,
    shop_cnt_not_bigbd,--库内门店数
    b_pay_shop_cnt_not_bigbd ,--B类下单门店数 不含服务商
    pure_b_gmv_not_bigbd,--B类净GMV    不含服务商
    pure_b_pay_amount_not_bigbd,--B类净支付金额  不含服务商
    pure_b_offline_refund_not_bigbd,--B类线下退款金额之和  指单独的那张线下退款的表的金额
    pure_b_refund_not_bigbd, --B类线上退款金额之和 指线上的订单表里的退款金额,
    num01_pure_b_pay_amount_not_bigbd,
    num02_pure_b_pay_amount_not_bigbd,
    num03_pure_b_pay_amount_not_bigbd,
    num04_pure_b_pay_amount_not_bigbd,
    num05_pure_b_pay_amount_not_bigbd,
    num06_pure_b_pay_amount_not_bigbd,
    class_number_info,
    war_zone_dep_name,--战区
    num07_pure_b_pay_amount,
    num08_pure_b_pay_amount,
    num07_pure_b_pay_amount_not_bigbd,
    num08_pure_b_pay_amount_not_bigbd,
    cur_b_gmv_shop_cnt
  from ads_salary_biz_manager_d
  where dayid ='$v_date'
) manager_summary
--部门
left join
(
  select
    user_id,
    user_real_name,
    dept_name
  from dim_usr_user_d
  where dayid ='$v_date'
) user_info on user_info.user_id=manager_summary.user_id
left join
--人工上传系数
(
  select
    sales_user_name as user_name,coefficient
  from dwd_salary_sales_coefficient_d
  where dayid ='$v_cur_month'
  and data_month ='$v_op_month'  --当月
  and is_valid=1 --有效系数
  group by sales_user_name,coefficient
) sales_coefficient on sales_coefficient.user_name=user_info.user_real_name
left join
--当月设置系数
(
  select
    user_id,
    target
  from
  (
    select
      user_id,
      target,
      row_number()over(partition by user_id order by create_time) as rn
    from dwd_kpi_indicator_target_d
    where dayid = '$v_date'
          and is_deleted=0
          and substr(create_time,1,6)='$v_cur_month'
  ) sales_kpi
  where rn=1
) user_target on user_target.user_id=manager_summary.user_id
