--主管数据汇总信息
with manager_summary as (
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
),

--用户信息（部门）
user_info as (
    select user_id,
           user_real_name,
           dept_name
    from dim_usr_user_d
    where dayid ='$v_date'
),

--销售系数表格上传（云图人工配置） user_name -> 系数信息
sales_coefficient as (
    select sales_user_name as user_name,coefficient
    from dwd_salary_sales_coefficient_d
    where dayid ='$v_cur_month'
    and data_month ='$v_op_month'  --当月
    and is_valid=1 --有效系数
    group by sales_user_name,coefficient
),

--当月设置系数（crm设置的考核设置） user_id -> 用户本月的考核目标
--每个user_id本月设置的第一个目标
sales_kpi as (
    select user_id,
           target,
           row_number() over(partition by user_id order by create_time) as rn
    from dwd_kpi_indicator_target_d
    where dayid = '$v_date'
    and is_deleted = 0
    and substr(create_time,1,6)='$v_cur_month'
),
user_target as (
    select user_id, target
    from sales_kpi
    where rn = 1
)

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
from manager_summary
left join user_info on user_info.user_id = manager_summary.user_id
left join sales_coefficient on sales_coefficient.user_name = user_info.user_real_name
left join user_target on user_target.user_id = manager_summary.user_id