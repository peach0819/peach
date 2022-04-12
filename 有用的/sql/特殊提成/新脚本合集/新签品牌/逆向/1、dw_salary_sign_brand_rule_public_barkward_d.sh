v_date=$1

# 是否开启补数模式，开启1，不开启空
supply_data_mode=$4
# 特殊提成补数方案 where语句
supply_data_where_condition=$(cat "$5")

# 变量：特殊提成方案表，在补数和非补数情况下，方案表不同
# 1. 补数情况：当补数脚本 dw_salary_supply_data_all 运行时会传补数 where 条件
# 2. 正常情况：用自己的 bounty_plan_payout 表
bounty_plan_table='bounty_plan'

if [[ $supply_data_mode != "" ]]
then
    bounty_plan_table='bounty_plan_supply_data'
else
    supply_data_where_condition="dayid = '${v_date}' and 0 = '1'"
    bounty_plan_table='bounty_plan'
fi

source ../sql_variable.sh $v_date
source ../yarn_variable.sh dw_salary_sign_brand_rule_public_backward_d '肥桃'

spark-sql $spark_yarn_job_name_conf $spark_yarn_queue_name_conf --master yarn --executor-memory 4G --num-executors 4 -v -e "
use ytdw;

set hivevar:filter_expr_columns=get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value') as calculate_date_value,
       get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.operator') as calculate_date_operator,
       get_json_object(get_json_object(filter_config_json,'$.item_style'),'$.value') as item_style_value,
       get_json_object(get_json_object(filter_config_json,'$.item_style'),'$.operator') as item_style_operator,
       get_json_object(get_json_object(filter_config_json,'$.bigbd_shop_flag'),'$.value') as bigbd_shop_flag_value,
       get_json_object(get_json_object(filter_config_json,'$.bigbd_shop_flag'),'$.operator') as bigbd_shop_flag_operator,
       get_json_object(get_json_object(filter_config_json,'$.sp_order_flag'),'$.value') as sp_order_flag_value,
       get_json_object(get_json_object(filter_config_json,'$.sp_order_flag'),'$.operator') as sp_order_flag_operator,
       get_json_object(get_json_object(filter_config_json,'$.special_order_flag'),'$.value') as special_order_flag_value,
       get_json_object(get_json_object(filter_config_json,'$.special_order_flag'),'$.operator') as special_order_flag_operator,
       get_json_object(get_json_object(filter_config_json,'$.category_first'),'$.value') as category_first_value,
       get_json_object(get_json_object(filter_config_json,'$.category_first'),'$.operator') as category_first_operator,
       get_json_object(get_json_object(filter_config_json,'$.category_second'),'$.value') as category_second_value,
       get_json_object(get_json_object(filter_config_json,'$.category_second'),'$.operator') as category_second_operator,
       get_json_object(get_json_object(filter_config_json,'$.brand'),'$.value') as brand_value,
       get_json_object(get_json_object(filter_config_json,'$.brand'),'$.operator') as brand_operator,
       get_json_object(get_json_object(filter_config_json,'$.item'),'$.value') as item_value,
       get_json_object(get_json_object(filter_config_json,'$.item'),'$.operator') as item_operator,
       get_json_object(get_json_object(filter_config_json,'$.shop'),'$.value') as shop_value,
       get_json_object(get_json_object(filter_config_json,'$.shop'),'$.operator') as shop_operator,
       get_json_object(get_json_object(filter_config_json,'$.store_type'),'$.value') as store_type_value,
       get_json_object(get_json_object(filter_config_json,'$.store_type'),'$.operator') as store_type_operator,
       get_json_object(get_json_object(filter_config_json,'$.war_area'),'$.value') as war_area_value,
       get_json_object(get_json_object(filter_config_json,'$.war_area'),'$.operator') as war_area_operator,
       get_json_object(get_json_object(filter_config_json,'$.bd_area'),'$.value') as bd_area_value,
       get_json_object(get_json_object(filter_config_json,'$.bd_area'),'$.operator') as bd_area_operator,
       get_json_object(get_json_object(filter_config_json,'$.manage_area'),'$.value') as manage_area_value,
       get_json_object(get_json_object(filter_config_json,'$.manage_area'),'$.operator') as manage_area_operator,
       get_json_object(get_json_object(filter_config_json,'$.new_sign_line'),'$.value') as new_sign_line_value,
       get_json_object(get_json_object(filter_config_json,'$.new_sign_line'),'$.operator') as new_sign_line_operator,
       get_json_object(get_json_object(filter_config_json,'$.freeze_sales_team'),'$.value') as freeze_sales_team_value,
       get_json_object(get_json_object(filter_config_json,'$.freeze_sales_team'),'$.operator') as freeze_sales_team_operator,
       get_json_object(get_json_object(filter_config_json,'$.sales_team'),'$.value') as sales_team_value,
       get_json_object(get_json_object(filter_config_json,'$.sales_team'),'$.operator') as sales_team_operator,
       get_json_object(get_json_object(filter_config_json,'$.shop_group'),'$.value') as shop_group_value,
       get_json_object(get_json_object(filter_config_json,'$.shop_group'),'$.operator') as shop_group_operator,
       replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),',')[0],'[',''),'\"',''),'-','') as calculate_date_value_start,
       replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),',')[1],']',''),'\"',''),'-','') as calculate_date_value_end,
       replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.new_sign_line'),'$.value'),'\"',''),'[',''),']','') as new_sign_line,
       replace(replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),']',''),'\"',''),'[',''),',','~') as plan_pay_time;


with
-- 补数情况下使用的表
bounty_plan_supply_data as (
    select \${filter_expr_columns}, t1.*
    from dw_bounty_plan_d t1
    where ${supply_data_where_condition}
),
bounty_plan as
(select \${filter_expr_columns}, t1.*
 from dw_bounty_plan_d t1
where dayid =replace(date_add(from_unixtime(unix_timestamp(),'yyyy-MM-dd'),-1),'-','')-------用系统日期的前一天作为方案表的取dayid日期
  and is_deleted =0
  and bounty_rule_type=3--本任务仅为新签品牌
  and status=1
  and month >= substr(add_months('$v_op_month', -12), 1, 7)
  and day(date_add('$v_op_time', 1))=1 --传入日期加1天，如果为1号，则说明传入日期为月末日期，否则为非月末日期；如果是月末日期，则数据可以继续往下跑
),
 --bounty_plan字段补充
bounty_plan2 as
(select
        '历史方案' as plan_type,
        t2.month as plan_month,
        t2.plan_pay_time as plan_pay_time,
        t2.name as plan_name,
        t2.biz_group_id as plan_group_id,
        t2.biz_group_name as plan_group_name,
        t2.calculate_date_value,
        t2.calculate_date_operator,
        t2.item_style_value,
        t2.item_style_operator,
        t2.bigbd_shop_flag_value,
        t2.bigbd_shop_flag_operator,
        t2.sp_order_flag_value,
        t2.sp_order_flag_operator,
        t2.special_order_flag_value,
        t2.special_order_flag_operator,
        t2.category_first_value,
        t2.category_first_operator,
        t2.category_second_value,
        t2.category_second_operator,
        t2.brand_value,
        t2.brand_operator,
        t2.item_value,
        t2.item_operator,
        t2.shop_value,
        t2.shop_operator,
        t2.store_type_value,
        t2.store_type_operator,
        t2.war_area_value,
        t2.war_area_operator,
        t2.bd_area_value,
        t2.bd_area_operator,
        t2.manage_area_value,
        t2.manage_area_operator,
        t2.new_sign_line_value,
        t2.new_sign_line_operator,
        t2.freeze_sales_team_value,
        t2.freeze_sales_team_operator,
        t2.sales_team_value,
        t2.sales_team_operator,
        t2.shop_group_value,
        t2.shop_group_operator,
        t2.calculate_date_value_start,
        t2.calculate_date_value_end,
        t2.new_sign_line,
        t2.no as plan_no,
        t3.code as indicator_code,
        t3.title as sts_target_name,
        t4.name as grant_object_type,
        t4.code as grant_object_type_code
   from ${bounty_plan_table} t2
   left join (select * from dwd_bounty_indicator_d where dayid='$v_date') t3
   on t2.bounty_indicator_id=t3.id
   left join (select * from dwd_bounty_payout_object_d where dayid='$v_date') t4
   on t2.bounty_payout_object_id = t4.id
),
-- 补数业务逻辑相关
-- 计算的是不参与补数的计算结果数据
without_supply_data_plan as (
select
    brand.update_time,
    brand.update_month,
    brand.plan_type,
    brand.plan_month,
    brand.plan_pay_time,
    brand.plan_name,
    brand.plan_group_id,
    brand.plan_group_name,
    brand.brand_id,
    brand.brand_name,
    brand.item_style,
    brand.item_style_name,
    brand.shop_id,
    brand.shop_name,
    brand.store_type,
    brand.store_type_name,
    brand.war_zone_id,
    brand.war_zone_name,
    brand.war_zone_dep_id,
    brand.war_zone_dep_name,
    brand.area_manager_id,
    brand.area_manager_name,
    brand.area_manager_dep_id,
    brand.area_manager_dep_name,
    brand.bd_manager_id,
    brand.bd_manager_name,
    brand.bd_manager_dep_id,
    brand.bd_manager_dep_name,
    brand.service_user_id_freezed,
    brand.service_department_id_freezed,
    brand.service_user_name_freezed,
    brand.service_feature_name_freezed,
    brand.service_job_name_freezed,
    brand.service_department_name_freezed,
    brand.new_sign_time,
    brand.new_sign_day,
    brand.new_sign_rn,
    brand.shop_brand_sign_day,
    brand.gmv_less_refund,
    brand.gmv,
    brand.pay_amount,
    brand.pay_amount_less_refund,
    brand.refund_actual_amount,
    brand.refund_retreat_amount,
    brand.new_sign_line,
    brand.is_over_sign_line,
    brand.is_first_sign,
    brand.is_succ_sign,
    brand.grant_object_type,
    brand.grant_object_user_id,
    brand.grant_object_user_name,
    brand.grant_object_user_dep_id,
    brand.grant_object_user_dep_name,
    brand.leave_time,
    brand.is_leave,
    brand.sts_target_name,
    brand.planno
from (
    select
      *
    from dw_salary_sign_brand_rule_public_d
    where dayid = '$v_date' and pltype = 'pre'
  ) brand left join (
    select no
    from dw_bounty_plan_d t1
    where ${supply_data_where_condition}
  ) plan
  on brand.planno = plan.no
  -- 关联不上的，就是不参与补数据
  where plan.no is null
  -- 非补数模式下自动跳过
  and 1='${supply_data_mode}'
)
insert overwrite table dw_salary_sign_brand_rule_public_d partition (dayid='$v_date',pltype='pre')
select
       from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,--更新时间
       from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,--执行月份
       plan_type as plan_type ,--明细类型
       --方案基础信息,
       replace(plan_month,'-','') as plan_month,--方案月份
       plan_pay_time as plan_pay_time,--方案时间
       plan_name as plan_name,--方案名称
       plan_group_id as plan_group_id, --归属业务组id
       plan_group_name as plan_group_name, --归属业务组
       brand_id,
       brand_name,--商品品牌
       item_style,
       item_style_name,--ab类型
       shop_id,
       shop_name,--门店名称
       store_type,--门店类型
       store_type_name,
       war_zone_id       , --战区经理ID
       war_zone_name     , --战区经理
       war_zone_dep_id   , --战区ID
       war_zone_dep_name , --战区
       area_manager_id       ,   --大区经理id
       area_manager_name     ,   --大区经理
       area_manager_dep_id,--大区区域ID
       area_manager_dep_name,   --大区
       bd_manager_id         ,--主管id
       bd_manager_name       ,--主管
       bd_manager_dep_id ,--主管区域ID
       bd_manager_dep_name   ,--区域
       service_user_id_freezed,
       service_department_id_freezed,
       service_user_name_freezed,--冻结销售人员姓名
       service_feature_name_freezed,--冻结销售人员职能
       service_job_name_freezed,--冻结销售人员角色
       service_department_name_freezed,--冻结销售人员部门
       new_sign_time,--新签时间
       new_sign_day, --新签日期
       new_sign_rn,--新签时间排名达成
       shop_brand_sign_day,--门店品牌新签时间
       --默认指标--
       gmv_less_refund,  --实货gmv-退款
       gmv,--实货gmv,
       pay_amount,--实货支付金额
       pay_amount_less_refund,--实货支付金额-退款
       refund_actual_amount,--实货退款
       refund_retreat_amount,--实货清退金额
       new_sign_line,
       is_over_sign_line,--是否满足新签门槛
       is_first_sign,--是否首次达成
       is_succ_sign,--是否新签成功
       grant_object_type ,
       grant_object_user_id ,
       grant_object_user_name ,
       grant_object_user_dep_id ,
       grant_object_user_dep_name ,
       users.leave_time as leave_time,--发放对象离职时间
       case when users.leave_time is not null and new_sign_day > users.leave_time then '是' else '否' end as is_leave,--发放对象是否离职
       --统计指标名称
       sts_target_name as sts_target_name,
       plan_no
  from
       (select
               dayid,
               brand_id,
               brand_name,--商品品牌
               item_style,
               item_style_name,--ab类型
               shop_id,
               shop_name,--门店名称
               store_type,--门店类型
               store_type_name,
               war_zone_id       , --战区经理ID
               war_zone_name     , --战区经理
               war_zone_dep_id   , --战区ID
               war_zone_dep_name , --战区
               area_manager_id       ,   --大区经理id
               area_manager_name     ,   --大区经理
               area_manager_dep_id,--大区区域ID
               area_manager_dep_name,   --大区
               bd_manager_id         ,--主管id
               bd_manager_name       ,--主管
               bd_manager_dep_id ,--主管区域ID
               bd_manager_dep_name   ,--区域
               service_user_id_freezed,
               service_department_id_freezed,
               service_user_name_freezed,--冻结销售人员姓名
               service_feature_name_freezed,--冻结销售人员职能
               service_job_name_freezed,--冻结销售人员角色
               service_department_name_freezed,--冻结销售人员部门
               new_sign_time,--新签时间
               new_sign_day, --新签日期
               new_sign_rn,--新签时间排名达成
               shop_brand_sign_day,--门店品牌新签时间
               --默认指标--
               gmv_less_refund,  --实货gmv-退款
               gmv,--实货gmv,
               pay_amount,--实货支付金额
               pay_amount_less_refund,--实货支付金额-退款
               refund_actual_amount,--实货退款
               refund_retreat_amount,--实货清退金额
               new_sign_line,
               is_over_sign_line,
               case when new_sign_rn=1 then '是' else '否' end as is_first_sign,--是否首次达成
               case when gmv_less_refund >= new_sign_line  and new_sign_rn=1 then '是' else '否' end as is_succ_sign,--是否新签成功
               grant_object_type as grant_object_type,--发放对象类型
               grant_object_type_code,
               case when grant_object_type_code= 'WAR_ZONE_MANAGE' then war_zone_id
                    when grant_object_type_code= 'AREA_MANAGER' then area_manager_id
                    when grant_object_type_code= 'BD_MANAGER' then bd_manager_id
                    when grant_object_type_code in('BD','BIG_BD')  then service_user_id_freezed
                    end as  grant_object_user_id,                                                                      --发放对象ID
               case when grant_object_type_code= 'WAR_ZONE_MANAGE' then war_zone_name
                    when grant_object_type_code= 'AREA_MANAGER' then area_manager_name
                    when grant_object_type_code= 'BD_MANAGER' then bd_manager_name
                    when grant_object_type_code in('BD','BIG_BD')  then service_user_name_freezed
               end as grant_object_user_name,                                                                       --发放对象名称
               case when grant_object_type_code= 'WAR_ZONE_MANAGE' then war_zone_dep_id
                    when grant_object_type_code= 'AREA_MANAGER' then area_manager_dep_id
                    when grant_object_type_code= 'BD_MANAGER' then bd_manager_dep_id
                    when grant_object_type_code in('BD','BIG_BD')  then service_department_id_freezed
                    end as grant_object_user_dep_id,                                                                      --发放对象部门ID
               case when grant_object_type_code= 'WAR_ZONE_MANAGE' then war_zone_dep_name
                    when grant_object_type_code= 'AREA_MANAGER' then area_manager_dep_name
                    when grant_object_type_code= 'BD_MANAGER' then bd_manager_dep_name
                    when grant_object_type_code in('BD','BIG_BD')  then service_department_name_freezed
                    end as grant_object_user_dep_name ,
                plan_type ,--明细类型
                --方案基础信息,
                plan_month,--方案月份
                plan_pay_time,--方案时间
                plan_name,--方案名称
                plan_group_id, --归属业务组id
                plan_group_name,  --归属业务组
                sts_target_name,
                plan_no
           from
               (select
                       dayid,
                       brand_id,
                       brand_name,--商品品牌
                       item_style,
                       item_style_name,--ab类型
                       shop_id,
                       shop_name,--门店名称
                       store_type,--门店类型
                       store_type_name,
                       war_zone_id       , --战区经理ID
                       war_zone_name     , --战区经理
                       war_zone_dep_id   , --战区ID
                       war_zone_dep_name , --战区
                       area_manager_id       ,   --大区经理id
                       area_manager_name     ,   --大区经理
                       area_manager_dep_id,--大区区域ID
                       area_manager_dep_name,   --大区
                       bd_manager_id         ,--主管id
                       bd_manager_name       ,--主管
                       bd_manager_dep_id ,--主管区域ID
                       bd_manager_dep_name   ,--区域
                       service_user_id_freezed,
                       service_department_id_freezed,
                       service_user_name_freezed,--冻结销售人员姓名
                       service_feature_name_freezed,--冻结销售人员职能
                       service_job_name_freezed,--冻结销售人员角色
                       service_department_name_freezed,--冻结销售人员部门
                       new_sign_time,--新签时间
                       new_sign_day, --新签日期
                       row_number()over(partition by plan_no,shop_id,brand_id,is_over_sign_line order by new_sign_time) as new_sign_rn,--新签时间排名达成
                       shop_brand_sign_day,--门店品牌新签时间
                       --默认指标--
                       gmv_less_refund,  --实货gmv-退款
                       gmv,--实货gmv
                       pay_amount,--实货支付金额
                       pay_amount_less_refund,--实货支付金额-退款
                       refund_actual_amount,--实货退款
                       refund_retreat_amount,--实货清退金额
                       new_sign_line,
                       is_over_sign_line,
                       grant_object_type,
                       grant_object_type_code,
                       plan_type  ,--明细类型
                       --方案基础信息,
                       plan_month,--方案月份
                       plan_pay_time ,--方案时间
                       plan_name ,--方案名称
                       plan_group_id , --归属业务组id
                       plan_group_name,  --归属业务组
                       sts_target_name,
                       plan_no
                  from
                       (select
                              dayid,
                              brand_id,
                              brand_name,--商品品牌
                              item_style,
                              item_style_name,--ab类型
                              shop_id,
                              shop_name,--门店名称
                              store_type,--门店类型
                              store_type_name,
                              war_zone_id       , --战区经理ID
                              war_zone_name     , --战区经理
                              war_zone_dep_id   , --战区ID
                              war_zone_dep_name , --战区
                              area_manager_id       ,   --大区经理id
                              area_manager_name     ,   --大区经理
                              area_manager_dep_id,--大区区域ID
                              area_manager_dep_name,   --大区
                              bd_manager_id         ,--主管id
                              bd_manager_name       ,--主管
                              bd_manager_dep_id ,--主管区域ID
                              bd_manager_dep_name   ,--区域
                              service_user_id_freezed,
                              service_department_id_freezed,
                              service_user_name_freezed,--冻结销售人员姓名
                              service_feature_name_freezed,--冻结销售人员职能
                              service_job_name_freezed,--冻结销售人员角色
                              service_department_name_freezed,--冻结销售人员部门
                              min(pay_time) as new_sign_time,--新签时间
                              min(pay_day) as new_sign_day, --新签日期
                              shop_brand_sign_day,--门店品牌新签时间
                              --默认指标--
                              sum(gmv_less_refund) as gmv_less_refund,  --实货gmv-退款
                              sum(gmv) as gmv,--实货gmv
                              sum(pay_amount) as pay_amount,--实货支付金额
                              sum(pay_amount_less_refund) as pay_amount_less_refund,--实货支付金额-退款
                              sum(refund_actual_amount) as refund_actual_amount,--实货退款
                              sum(refund_retreat_amount) as refund_retreat_amount,--实货清退金额
                              new_sign_line as new_sign_line,
                              case when sum(gmv_less_refund) >= new_sign_line then '是' else '否' end as is_over_sign_line,--是否满足新签门槛
                              grant_object_type,
                              grant_object_type_code,
                              plan_type  ,--明细类型
                              --方案基础信息,
                              plan_month,--方案月份
                              plan_pay_time ,--方案时间
                              plan_name ,--方案名称
                              plan_group_id , --归属业务组id
                              plan_group_name,  --归属业务组
                              sts_target_name,
                              plan_no
                              ---业务中间表
                         from
                              (select
                                      a.dayid,
                                      a.order_id,
                                      a.trade_no,
                                      business_unit,--业务域,
                                      category_id_first,  --商品一级类目,
                                      category_id_second, --商品二级类目,
                                      category_id_first_name,
                                      category_id_second_name,
                                      brand_id,
                                      brand_name,--商品品牌,
                                      item_id,
                                      item_name,--商品名称,
                                      item_style,
                                      item_style_name,--ab类型,
                                      is_sp_shop,--是否服务商订单
                                      is_bigbd_shop,--是否大BD门店
                                      is_spec_order,--是否特殊订单,
                                      shop_item_sign_day,
                                      shop_item_sign_time,
                                      shop_brand_sign_day,
                                      shop_brand_sign_time,
                                      pay_time,
                                      pay_day,
                                      a.shop_id,
                                      shop_name,--门店名称,
                                      store_type,--门店类型,
                                      store_type_name,
                                      war_zone_id       , --战区经理ID
                                      war_zone_name     , --战区经理
                                      war_zone_dep_id   , --战区ID
                                      war_zone_dep_name , --战区
                                      area_manager_id       ,   --大区经理id
                                      area_manager_name     ,   --大区经理
                                      area_manager_dep_id, --大区区域ID
                                      area_manager_dep_name,   --大区
                                      bd_manager_id         ,--主管id
                                      bd_manager_name       ,--主管
                                      bd_manager_dep_id ,--主管区域ID
                                      bd_manager_dep_name   ,--区域
                                      service_user_id_freezed,
                                      service_department_id_freezed,
                                      service_user_name_freezed,--冻结销售人员姓名,
                                      service_feature_name_freezed,--冻结销售人员职能,
                                      service_job_name_freezed,--冻结销售人员角色,
                                      service_department_name_freezed,--冻结销售人员部门,
                                      --默认指标--
                                      --默认指标--
                                      a.gmv - nvl(c.refund_actual_amount,0) as gmv_less_refund,  --实货gmv-退款,
                                      a.pay_amount,--实货支付金额
                                      a.pay_amount - nvl(c.refund_actual_amount,0)  as pay_amount_less_refund,--实货支付金额-退款
                                      gmv,--实货gmv,
                                      nvl(c.refund_actual_amount,0) as refund_actual_amount,--实货退款,
                                      nvl(c.refund_retreat_amount,0) as refund_retreat_amount,--实货清退金额
                                      new_sign_line as new_sign_line,
                                      grant_object_type,
                                      grant_object_type_code,
                                      plan_type  ,--明细类型
                                      --方案基础信息,
                                      plan_month,--方案月份
                                      plan_pay_time ,--方案时间
                                      plan_name ,--方案名称
                                      plan_group_id , --归属业务组id
                                      plan_group_name,  --归属业务组
                                      sts_target_name,
                                      plan_no
                                 from
                                      (select *
                                         from dw_salary_sign_rule_public_mid_v2_d
                                        where dayid in (replace(last_day(add_months('$v_op_time', 0)), '-', ''),
                                                       replace(last_day(add_months('$v_op_time', -1)), '-', ''),
                                                       replace(last_day(add_months('$v_op_time', -2)), '-', ''),
                                                       replace(last_day(add_months('$v_op_time', -3)), '-', ''),
                                                       replace(last_day(add_months('$v_op_time', -4)), '-', ''),
                                                       replace(last_day(add_months('$v_op_time', -5)), '-', ''),
                                                       replace(last_day(add_months('$v_op_time', -6)), '-', ''),
                                                       replace(last_day(add_months('$v_op_time', -7)), '-', ''),
                                                       replace(last_day(add_months('$v_op_time', -8)), '-', ''),
                                                       replace(last_day(add_months('$v_op_time', -9)), '-', ''),
                                                       replace(last_day(add_months('$v_op_time', -10)), '-', ''),
                                                       replace(last_day(add_months('$v_op_time', -11)), '-', ''))
                                          and dayid > '0'
                                      ) a
                                      --退款表
                                 left join
                                      (select order_id,
                                              sum(refund_actual_amount) as refund_actual_amount,
                                              sum(case when multiple_refund=10 then refund_actual_amount else 0 end) as refund_retreat_amount
                                         from dw_afs_order_refund_new_d --（后期通过type识别清退金额）
                                        where dayid ='$v_date'
                                          and refund_status=9
                                        group by order_id
                                      ) c on a.order_id=c.order_id
                                cross join bounty_plan2 b
                                   on 1=1
                                  and a.dayid = replace(date_sub(add_months(concat(b.plan_month, '-01'), 1), 1), '-', '')
                                  and shop_brand_sign_day between calculate_date_value_start and calculate_date_value_end
                                  and pay_day <= calculate_date_value_end
                                  and ytdw.simple_expr( sale_team_id,'in',sales_team_value)=(case when sales_team_operator ='=' then 1 else 0 end)
                                  and ytdw.simple_expr( item_style_name,'in',item_style_value)=(case when item_style_operator ='=' then 1 else 0 end)
                                  and ytdw.simple_expr( category_id_first,'in',category_first_value)=(case when category_first_operator ='=' then 1 else 0 end)
                                  and ytdw.simple_expr( category_id_second,'in',category_second_value)=(case when category_second_operator ='=' then 1 else 0 end)
                                  and ytdw.simple_expr( brand_id,'in',brand_value)=(case when brand_operator ='=' then 1 else 0 end)
                                  and ytdw.simple_expr( war_zone_dep_id,'in',war_area_value)=(case when war_area_operator ='=' then 1 else 0 end)
                                  and ytdw.simple_expr( area_manager_dep_id,'in',bd_area_value)=(case when bd_area_operator ='=' then 1 else 0 end)
                                  and ytdw.simple_expr( bd_manager_dep_id,'in',manage_area_value)=(case when manage_area_operator ='=' then 1 else 0 end)
                                  and if(a.shop_group = '' OR b.shop_group_value = '', 0, ytdw.simple_expr(substr(b.shop_group_value, 2, length(b.shop_group_value) - 2), 'in', concat('[', a.shop_group, ']'))) = (case when shop_group_operator ='=' then 1 else 0 end)
                              ) big_tbl
                          group by
                                dayid,
                                brand_id,
                                brand_name,--商品品牌
                                item_style,
                                item_style_name,--ab类型
                                shop_id,
                                shop_name,--门店名称
                                store_type,--门店类型
                                store_type_name,
                                war_zone_id       , --战区经理ID
                                war_zone_name     , --战区经理
                                war_zone_dep_id   , --战区ID
                                war_zone_dep_name , --战区
                                area_manager_id       ,   --大区经理id
                                area_manager_name     ,   --大区经理
                                area_manager_dep_id,--大区区域ID
                                area_manager_dep_name,   --大区
                                bd_manager_id         ,--主管id
                                bd_manager_name       ,--主管
                                bd_manager_dep_id ,--主管区域ID
                                bd_manager_dep_name   ,--区域
                                service_user_id_freezed,
                                service_department_id_freezed,
                                service_user_name_freezed,--冻结销售人员姓名
                                service_feature_name_freezed,--冻结销售人员职能
                                service_job_name_freezed,--冻结销售人员角色
                                service_department_name_freezed,--冻结销售人员部门
                                shop_brand_sign_day,
                                new_sign_line,
                                grant_object_type,
                                grant_object_type_code,
                                plan_type  ,--明细类型
                                --方案基础信息,
                                plan_month,--方案月份
                                plan_pay_time ,--方案时间
                                plan_name ,--方案名称
                                plan_group_id , --归属业务组id
                                plan_group_name,  --归属业务组
                                sts_target_name,
                                plan_no
                       ) sign_tmp
                ) sign_mid
          ) sign_rule
     left join
       ( select dayid, user_id, substr(leave_time,1,8) as leave_time from dwd_user_admin_d
          where dayid in (replace(last_day(add_months('$v_op_time', 0)), '-', ''),
                           replace(last_day(add_months('$v_op_time', -1)), '-', ''),
                           replace(last_day(add_months('$v_op_time', -2)), '-', ''),
                           replace(last_day(add_months('$v_op_time', -3)), '-', ''),
                           replace(last_day(add_months('$v_op_time', -4)), '-', ''),
                           replace(last_day(add_months('$v_op_time', -5)), '-', ''),
                           replace(last_day(add_months('$v_op_time', -6)), '-', ''),
                           replace(last_day(add_months('$v_op_time', -7)), '-', ''),
                           replace(last_day(add_months('$v_op_time', -8)), '-', ''),
                           replace(last_day(add_months('$v_op_time', -9)), '-', ''),
                           replace(last_day(add_months('$v_op_time', -10)), '-', ''),
                           replace(last_day(add_months('$v_op_time', -11)), '-', ''))
            and dayid > '0'
       ) users
      on sign_rule.grant_object_user_id =users.user_id and sign_rule.dayid = users.dayid
      where sign_rule.grant_object_user_id is not null

      union all
      select * from without_supply_data_plan
;
" &&

exit 0