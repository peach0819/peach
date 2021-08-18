

--修改记录  20190722  zhangzhiwei 新增a,b目标完成字段
--20190930新增分类净支付金额1
--202011月需求版本 silu

CREATE TABLE IF NOT EXISTS dw_salary_summary_data_d(
  service_user_id string COMMENT '服务人员id',
  service_user_name string COMMENT '服务人员名称',
  service_department_id string COMMENT '服务人员部门id',
  service_department_name string COMMENT '服务人员部门名称',
  is_split string COMMENT '销售是否拆分',
  is_coefficient string COMMENT '是否有系数',
  unknown_scene_count int COMMENT '无法计算场景的数量',
  leave_time string COMMENT '离职时间',
  coefficient_goal bigint COMMENT '系数目标',
  coefficient_summary decimal(11,2) COMMENT '系数总和',
  commission_summary decimal(11,2) COMMENT '提成总和',
  milk_commission_summary decimal(11,2) COMMENT '奶粉提成',
  diaper_commission_summary decimal(11,2) COMMENT '尿不湿提成',
  shampoo_commission_summary decimal(11,2) COMMENT '洗衣液提成',
  other_commission_summary decimal(11,2) COMMENT '其他提成',
  new_sign_shop_count int COMMENT '有效新开门店数',
  shop_count int COMMENT '库内门店数',
  reach_shop_goal int COMMENT '达标门店目标',
  reach_shop_count int COMMENT '达标门店数',
  reach_shop_coefficient decimal(11,2) COMMENT '达标门店系数',
  a_coefficient_summary decimal(11,2) COMMENT 'a类系数总和',
  b_coefficient_summary decimal(11,2) COMMENT 'b类系统总和',
  update_time string COMMENT '更新时间',
  a_target_finish decimal(11,2) COMMENT 'a类目标完成',
  b_target_finish decimal(11,2) COMMENT 'b类目标完成',
  cnt_silent_shop bigint COMMENT '静默激活门店数',
  cnt_brand_shop bigint COMMENT '多品进店门店数',
  num01_pure_b_pay_amount decimal(18,2) COMMENT '分类01 提成',
  num02_pure_b_pay_amount decimal(18,2) COMMENT '分类02 提成',
  num03_pure_b_pay_amount decimal(18,2) COMMENT '分类03 提成',
  num04_pure_b_pay_amount decimal(18,2) COMMENT '分类04 提成',
  num05_pure_b_pay_amount decimal(18,2) COMMENT '分类05 提成',
  num06_pure_b_pay_amount decimal(18,2) COMMENT '分类06 提成',

  class_number_info string COMMENT '分类信息',
  pickup_card_coefficient_summary decimal(18,2) COMMENT '提货卡充值系数总和',
  goods_coefficient_summary decimal(18,2) COMMENT '实货支付系数总和',
  pickup_card_commission_summary decimal(18,2) COMMENT '提货卡充值提成总和',
  goods_commission_summary decimal(18,2) COMMENT '实货支付提成总和',
  coefficient_goal_rate string comment '系统计算目标完成率',
  upload_coefficient string comment '当月手动上传完成率',
  real_coefficient_goal_rate string comment '理论目标完成率',
  num07_pure_b_pay_amount decimal(18,2) COMMENT '分类07 提成',
  num08_pure_b_pay_amount decimal(18,2) COMMENT '分类08 提成',

  num01_pure_b_pay_name string COMMENT '分类01提成名称',
  num02_pure_b_pay_name string COMMENT '分类02提成名称',
  num03_pure_b_pay_name string COMMENT '分类03提成名称',
  num04_pure_b_pay_name string COMMENT '分类04提成名称',
  num05_pure_b_pay_name string COMMENT '分类05提成名称',
  num06_pure_b_pay_name string COMMENT '分类06提成名称',
  num07_pure_b_pay_name string COMMENT '分类07提成名称',
  num08_pure_b_pay_name string COMMENT '分类08提成名称',
  province_dept string COMMENT '省区',
  zone_dept string COMMENT '战区',
  theoretical_commission_amt decimal(18,2) COMMENT '提成金额',
  new_sign_commission_amt decimal(18,2) COMMENT '有效新开门店奖励',
  kn_valid_visit_shop_cnt bigint COMMENT '库内品控有效拜访门店数',
  num09_pure_b_pay_amount decimal(18,2) COMMENT '分类09 提成',
  num09_pure_b_pay_name string COMMENT '分类09提成名称'
)
comment '销售汇总数据'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;

set hive.execution.engine=mr;

insert overwrite table ytdw.dw_salary_summary_data_d partition(dayid='$v_date')

select
  service_user_id,
  service_user_name,
  service_department_id,
  service_department_name,
  is_split,
  is_coefficient,
  unknown_scene_count,
  leave_time,
  coefficient_goal, --系数目标
  coefficient_summary,
  commission_summary,
  milk_commission_summary,
  diaper_commission_summary,
  shampoo_commission_summary,
  other_commission_summary,
  new_sign_shop_count,
  shop_count,
  reach_shop_goal,
  reach_shop_count,
  reach_shop_coefficient,
  a_coefficient_summary,
  b_coefficient_summary,
  update_time,
  a_target_finish,
  b_target_finish,
  cnt_silent_shop,
  cnt_brand_shop,
  num01_pure_b_pay_amount,
  num02_pure_b_pay_amount,
  num03_pure_b_pay_amount,
  num04_pure_b_pay_amount,
  num05_pure_b_pay_amount,
  num06_pure_b_pay_amount,
  class_number_info,
  pickup_card_coefficient_summary,--提货卡充值系数总和
  goods_coefficient_summary,--实货支付系数总和
  pickup_card_commission_summary,--提货卡充值提成总和
  goods_commission_summary,--实货支付提成总和
  coefficient_goal_rate,--系统计算目标完成率
  upload_coefficient,--当月手动上传完成率
  nvl(upload_coefficient,coefficient_goal_rate) as real_coefficient_goal_rate, --理论目标完成率
  num07_pure_b_pay_amount,
  num08_pure_b_pay_amount,
  num01_pure_b_pay_name,
  num02_pure_b_pay_name,
  num03_pure_b_pay_name,
  num04_pure_b_pay_name,
  num05_pure_b_pay_name,
  num06_pure_b_pay_name,
  num07_pure_b_pay_name,
  num08_pure_b_pay_name,
  province_dept,--省区
  zone_dept,--战区
  theoretical_commission_amt, --理论提成金额
  new_sign_commission_amt, --有效门店理论提成金额
  null as kn_valid_visit_shop_cnt, --库内品控有效拜访门店数
  num09_pure_b_pay_amount,
  num09_pure_b_pay_name
 from
 (
select
  table1.service_user_id,
  table1.service_user_name,
  table1.service_department_id,
  table1.service_department_name,
  table1.is_split,
  table1.is_coefficient,
  table1.unknown_scene_count,
  from_unixtime(unix_timestamp(user.leave_time,'yyyyMMddHHmmss')) as leave_time,
  user_target.target as coefficient_goal, --系数目标
  table1.coefficient_summary,
  table1.commission_summary,
  table1.milk_commission_summary,
  table1.diaper_commission_summary,
  table1.shampoo_commission_summary,
  table1.other_commission_summary,
  table3.new_sign_shop_count,
  table2.kn_shop_count as shop_count,
  null as reach_shop_goal,
  table4.da_gmv_biao_shop_count as reach_shop_count,
  null as reach_shop_coefficient,
  table1.a_coefficient_summary,
  table1.b_coefficient_summary,
  from_unixtime(unix_timestamp()) as update_time,
  table1.a_target_finish,
  table1.b_target_finish,
  cnt_silent_shop,
  cnt_brand_shop,
  num01_pure_b_pay_amount,
  num02_pure_b_pay_amount,
  num03_pure_b_pay_amount,
  num04_pure_b_pay_amount,
  num05_pure_b_pay_amount,
  num06_pure_b_pay_amount,
  case
    when is_split='BD' then '分类01：低端和超低端尿不湿，洗衣液，干湿纸巾，BuffX品牌（元） \；分类02：营养品，用品玩具，服纺，洗护（元）\；分类03奶粉及面包/蛋糕(元)\；分类04：中端和高端尿不湿，辅食，其他品类(元) \；分类09：纽瑞优系列(元)；,佑伉力'
    when is_split='大BD' then '分类01：低端和超低端尿不湿，洗衣液，干湿纸巾，BuffX品牌（通用品）（元）\；分类02：营养品，用品玩具，服纺，洗护（通用品）\；分类03奶粉及面包/蛋糕(元)（通用品）\；分类04：中端和高端尿不湿，辅食，其他品类（通用品）\；分类05：低端和超低端尿不湿，洗衣液，干湿纸巾（大BD专供品）\；分类06：营养品，用品玩具，服纺，洗护 （大BD专供品）\；分类07：奶粉及面包/蛋糕(元)（大BD专供品）\；分类08：中端和高端尿不湿，辅食，其他品类（大BD专供品）\；分类09：纽瑞优系列(元）,佑伉力'
  else '' end as class_number_info,
  pickup_card_coefficient_summary,--提货卡充值系数总和
  goods_coefficient_summary,--实货支付系数总和
  pickup_card_commission_summary,--提货卡充值提成总和
  goods_commission_summary,--实货支付提成总和
  --20201123_silu
  case when nvl(table1.coefficient_summary,0) !=0 and nvl(user_target.target,0) !=0
  then round(table1.coefficient_summary/user_target.target,4) else null end as coefficient_goal_rate,--系统计算目标完成率
  round(sales_coefficient.coefficient,4) as upload_coefficient,--当月手动上传完成率
  num07_pure_b_pay_amount,
  num08_pure_b_pay_amount,
  num09_pure_b_pay_amount,
  --20200724
  table1.num01_pure_b_pay_name,
  table1.num02_pure_b_pay_name,
  table1.num03_pure_b_pay_name,
  table1.num04_pure_b_pay_name,
  table1.num05_pure_b_pay_name,
  table1.num06_pure_b_pay_name,
  table1.num07_pure_b_pay_name,
  table1.num08_pure_b_pay_name,
  table1.num09_pure_b_pay_name,
  --20200826
  --省区
  case when table1.is_split='BD' then dept.dep_2name else '' end   as province_dept,
  --战区
  case when table1.is_split='BD' then dept.dep_3name else '' end   as zone_dept,
  --提成金额 20201123_silu
  case  when table1.is_split='大BD' or table1.is_split='BD'
        then nvl(num01_pure_b_pay_amount,0)*0.03
            +nvl(num02_pure_b_pay_amount,0)*0.05
            +nvl(num03_pure_b_pay_amount,0)*0.025
            +nvl(num04_pure_b_pay_amount,0)*0.04
            +nvl(num05_pure_b_pay_amount,0)*0.03
            +nvl(num06_pure_b_pay_amount,0)*0.05
            +nvl(num07_pure_b_pay_amount,0)*0.025
            +nvl(num08_pure_b_pay_amount,0)*0.04
            +nvl(num09_pure_b_pay_amount,0)*0.01
        else null end  as theoretical_commission_amt,
  --版本一：北部战区，有效新开门店奖励 当  (静默激活门店数 + 有效新开门店数) >=10时,则（(静默激活门店数 + 有效新开门店数)-10） * 100+10*50 , 否则, (静默激活门店数 + 有效新开门店数)  * 50
  --20201014：全国BD，有效新开门店数* 50
  case when table1.is_split='BD' --and trim(dept.dep_3name)='北部战区'
       then  nvl(table3.new_sign_shop_count,0)*50
           --(case when (nvl(table3.new_sign_shop_count,0)+nvl(silent_shop.cnt_silent_shop,0))>=10
              --            then ((nvl(table3.new_sign_shop_count,0)+nvl(silent_shop.cnt_silent_shop,0)-10)*100+500)
              --            else (nvl(table3.new_sign_shop_count,0)+nvl(silent_shop.cnt_silent_shop,0))*50 end)
       else null end  as  new_sign_commission_amt
  --当月品控合格有效拜访门店数
  -- qc_vaild_visit.kn_valid_visit_shop_cnt
from
(
select
  service_user_id,
  service_user_name,
  service_department_id,
  service_department_name,
  is_split,
  is_coefficient,
  count(distinct case when reason='不存在于订单场景' then
  concat_ws(',',is_split,service_feature_names,service_feature_name)
  else null end) as unknown_scene_count,
  sum(coefficient_actual_amount) as coefficient_summary,
  sum(commission_actual_amount) as commission_summary,
  sum(case when category_id_first_name='奶粉' then commission_actual_amount else 0 end) as milk_commission_summary,
  sum(case when category_id_first_name='尿不湿' then commission_actual_amount else 0 end) as diaper_commission_summary,
  sum(case when category_id_second_name in ('衣物清洁护理','纸巾') then commission_actual_amount else 0 end) as shampoo_commission_summary,
  sum(case when category_id_first_name not in ('奶粉','尿不湿') and nvl(category_id_second_name,'未知') not in ('衣物清洁护理','纸巾') then commission_actual_amount else 0 end) as other_commission_summary,
  sum(case when item_style_name='A' then coefficient_actual_amount else 0 end) as a_coefficient_summary,
  sum(case when item_style_name='B' then coefficient_actual_amount else 0 end) as b_coefficient_summary,
  sum(case when item_style_name='A' and coefficient_actual_amount>0 then coefficient_actual_amount else a_pure_gmv end) as a_target_finish,
  sum(case when item_style_name='B' and coefficient_actual_amount>0 then coefficient_actual_amount else b_pure_gmv end) as b_target_finish,
  sum(case when class_number='分类01'  then commission_actual_amount else 0 end) as num01_pure_b_pay_amount,
  sum(case when class_number='分类02'  then commission_actual_amount else 0 end) as num02_pure_b_pay_amount,
  sum(case when class_number='分类03'  then commission_actual_amount else 0 end) as num03_pure_b_pay_amount,
  sum(case when class_number='分类04'  then commission_actual_amount else 0 end) as num04_pure_b_pay_amount,
  sum(case when class_number='分类05'  then commission_actual_amount else 0 end) as num05_pure_b_pay_amount,
  sum(case when class_number='分类06'  then commission_actual_amount else 0 end) as num06_pure_b_pay_amount,
  sum(case when class_number='分类07'  then commission_actual_amount else 0 end) as num07_pure_b_pay_amount,
  sum(case when class_number='分类08'  then commission_actual_amount else 0 end) as num08_pure_b_pay_amount,
  sum(case when class_number='分类09'  then commission_actual_amount else 0 end) as num09_pure_b_pay_amount,
  sum(case when is_pickup_recharge_order_name='是' then coefficient_actual_amount else 0 end) as pickup_card_coefficient_summary,--提货卡充值系数总和
  sum(case when is_pickup_recharge_order_name='否' then coefficient_actual_amount else 0 end) as goods_coefficient_summary,--实货支付系数总和
  sum(case when is_pickup_recharge_order_name='是' then commission_actual_amount else 0 end) as pickup_card_commission_summary,--提货卡充值提成总和
  sum(case when is_pickup_recharge_order_name='否' then commission_actual_amount else 0 end) as goods_commission_summary,--实货支付提成总和
  max(case when class_number='分类01' then num01_pure_b_pay_name else '' end)  as num01_pure_b_pay_name,
  max(case when class_number='分类02' then num01_pure_b_pay_name else '' end)  as num02_pure_b_pay_name,
  max(case when class_number='分类03' then num01_pure_b_pay_name else '' end)  as num03_pure_b_pay_name,
  max(case when class_number='分类04' then num01_pure_b_pay_name else '' end)  as num04_pure_b_pay_name,
  max(case when class_number='分类05' then num01_pure_b_pay_name else '' end)  as num05_pure_b_pay_name,
  max(case when class_number='分类06' then num01_pure_b_pay_name else '' end)  as num06_pure_b_pay_name,
  max(case when class_number='分类07' then num01_pure_b_pay_name else '' end)  as num07_pure_b_pay_name,
  max(case when class_number='分类08' then num01_pure_b_pay_name else '' end)  as num08_pure_b_pay_name,
  max(case when class_number='分类09' then num01_pure_b_pay_name else '' end)  as num09_pure_b_pay_name

from ytdw.dw_salary_base_data_d where dayid='$v_date'
group by  service_user_id,
  service_user_name,
  service_department_id,
  service_department_name,
  is_split,
  is_coefficient
) table1

--库内
left join
(
select
  ytdw.get_service_info('service_type:销售',bd_service_info,'service_user_id') as service_user_id,
  ytdw.get_service_info('service_type:销售',bd_service_info,'service_user_name') as service_user_name,
  ytdw.get_service_info('service_type:销售',bd_service_info,'service_department_id') as service_department_id,
  ytdw.get_service_info('service_type:销售',bd_service_info,'service_department_name') as service_department_name,
  ytdw.get_service_info('service_type:销售',bd_service_info,'service_job_id') as service_job_id,
  ytdw.get_service_info('service_type:销售',bd_service_info,'service_job_name') as service_job_name,
  concat_ws(',',collect_set(ytdw.get_service_info('service_type:销售',bd_service_info,'service_feature_id'))) as service_feature_ids,
  concat_ws(',',collect_set(ytdw.get_service_info('service_type:销售',bd_service_info,'service_feature_name'))) as service_feature_names,
  count(distinct shop_id) kn_shop_count
from (
select *
from ytdw.dw_shop_base_d
lateral view explode(split(regexp_replace(ytdw.get_service_info('service_type:销售',service_info),'\}\,','\}\;'),'\;')) tmp as bd_service_info
where dayid='$v_date'
and bu_id=0
--20200505
and store_type not in (9,10,11)
and shop_status in (1,2,3,4,5)
) tbl group by
ytdw.get_service_info('service_type:销售',bd_service_info,'service_user_id'),
  ytdw.get_service_info('service_type:销售',bd_service_info,'service_user_name'),
  ytdw.get_service_info('service_type:销售',bd_service_info,'service_department_id'),
  ytdw.get_service_info('service_type:销售',bd_service_info,'service_department_name'),
  ytdw.get_service_info('service_type:销售',bd_service_info,'service_job_id'),
  ytdw.get_service_info('service_type:销售',bd_service_info,'service_job_name')
) table2 on table2.service_user_id=table1.service_user_id

--有效新开
--20200525新增approve_status_name：'真实性认证成功'
left join
(
select
  service_user_id,
  count(shop_id) as new_sign_shop_count --有效新开门店数
from ytdw.dw_salary_shop_data_d where dayid='$v_date' and substr(new_sign_pay_day,1,6)='$v_cur_month' and approve_status_name in ('审核成功','审核成功（无资质）','真实性认证成功') and min_pay_month='$v_cur_month'
group by service_user_id
) table3 on table3.service_user_id=table1.service_user_id

--达标门店数
left join
(
    select
  service_user_id,
  count(case when cur_month_is_reach='达标' then shop_id else null end) da_gmv_biao_shop_count
   from ytdw.dm_shop_d
   lateral view explode(split(bd_user_ids,',')) tmp as service_user_id
   where dayid='$v_date'
   group by service_user_id
) table4 on table4.service_user_id=table1.service_user_id

--离职时间
left join
(
select user_id,leave_time from ytdw.dim_usr_user_d where dayid='$v_date' and diz_type like '%old%'
) user on user.user_id=table1.service_user_id
--激活门店数
left join
( select is_silent_service_user_id,count(distinct shop_id) as cnt_silent_shop from ytdw.dm_shop_d where dayid ='$v_date'
    group by is_silent_service_user_id
) silent_shop on silent_shop.is_silent_service_user_id=table1.service_user_id
left join
--多品进店数
( select is_brand_service_user_id ,count(distinct shop_id) as cnt_brand_shop from ytdw.dm_shop_d where dayid ='$v_date'
    group by is_brand_service_user_id
) brand_shop on brand_shop.is_brand_service_user_id=table1.service_user_id
left join
--人工上传系数
( select sales_user_name as user_name,coefficient from dwd_salary_sales_coefficient_d
    where dayid ='$v_date'
        group by sales_user_name,coefficient
) sales_coefficient on sales_coefficient.user_name=table1.service_user_name
left join
--当月设置系数
(
select user_id,target
 from
 ( select user_id,target,row_number()over(partition by user_id order by create_time) as rn
   from dwd_kpi_indicator_target_d
   where dayid = '$v_date'
   and is_deleted=0
   and substr(create_time,1,6)='$v_cur_month'
) sales_coefficient
where rn=1
) user_target on user_target.user_id=table1.service_user_id
--取dep_2name省区和dep_3name战区
left join
 (select user_id,dep_id,dep_1name,dep_2name,dep_3name
   from dim_employee_dep_d
   where dayid='$v_date'
   group by user_id,dep_id,dep_1name,dep_2name,dep_3name
 ) dept on table1.service_user_id = dept.user_id
--left join
--(--当月品控合格有效拜访门店数
--  select visitor_id,count(distinct shop_id) as kn_valid_visit_shop_cnt
--  from ytdw.nrt_report_crm_bd_visit_history
--  where dayid='$v_date'
--  and qc_vaild_visit_status ='合格'
--  group by visitor_id
--) qc_vaild_visit on table1.service_user_id = qc_vaild_visit.visitor_id
) salary_summary

