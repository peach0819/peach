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
source ../yarn_variable.sh dw_salary_gmv_rule_public_backward_d '肥桃'

spark-sql $spark_yarn_job_name_conf $spark_yarn_queue_name_conf --master yarn --executor-memory 4G --num-executors 4 -v -e "
use ytdw;

set hivevar:filter_expr_columns=get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value') as calculate_date_value,
         get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.operator') as calculate_date_operator,
         get_json_object(get_json_object(filter_config_json,'$.freeze_sales_team'),'$.value') as freeze_sales_team_value,
         get_json_object(get_json_object(filter_config_json,'$.freeze_sales_team'),'$.operator') as freeze_sales_team_operator,
         get_json_object(get_json_object(filter_config_json,'$.item_style'),'$.value') as item_style_value,
         get_json_object(get_json_object(filter_config_json,'$.item_style'),'$.operator') as item_style_operator,
         get_json_object(get_json_object(filter_config_json,'$.category_first'),'$.value') as category_first_value,
         get_json_object(get_json_object(filter_config_json,'$.category_first'),'$.operator') as category_first_operator,
         get_json_object(get_json_object(filter_config_json,'$.category_second'),'$.value') as category_second_value,
         get_json_object(get_json_object(filter_config_json,'$.category_second'),'$.operator') as category_second_operator,
         get_json_object(get_json_object(filter_config_json,'$.brand'),'$.value') as brand_value,
         get_json_object(get_json_object(filter_config_json,'$.brand'),'$.operator') as brand_operator,
         get_json_object(get_json_object(filter_config_json,'$.item'),'$.value') as item_value,
         get_json_object(get_json_object(filter_config_json,'$.item'),'$.operator') as item_operator,
         get_json_object(get_json_object(filter_config_json,'$.war_area'),'$.value') as war_area_value,
         get_json_object(get_json_object(filter_config_json,'$.war_area'),'$.operator') as war_area_operator,
         get_json_object(get_json_object(filter_config_json,'$.bd_area'),'$.value') as bd_area_value,
         get_json_object(get_json_object(filter_config_json,'$.bd_area'),'$.operator') as bd_area_operator,
         get_json_object(get_json_object(filter_config_json,'$.manage_area'),'$.value') as manage_area_value,
         get_json_object(get_json_object(filter_config_json,'$.manage_area'),'$.operator') as manage_area_operator,
         get_json_object(get_json_object(filter_config_json,'$.shop_group'),'$.value') as shop_group_value,
         get_json_object(get_json_object(filter_config_json,'$.shop_group'),'$.operator') as shop_group_operator,
         replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),',')[0],'[',''),'\"',''),'-','') as calculate_date_value_start,
         replace(replace(replace(split(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),',')[1],']',''),'\"',''),'-','') as calculate_date_value_end,
         replace(replace(replace(replace(get_json_object(get_json_object(filter_config_json,'$.calculate_date'),'$.value'),']',''),'\"',''),'[',''),',','~') as plan_pay_time;

with
-- 补数情况下使用的表
bounty_plan_supply_data as (
  select \${filter_expr_columns}, t1.*
    from dw_bounty_plan_d t1
    where ${supply_data_where_condition}
),
bounty_plan as
(select  \${filter_expr_columns}, t1.*
    from dw_bounty_plan_d t1
    where dayid =replace(date_add(from_unixtime(unix_timestamp(),'yyyy-MM-dd'),-1),'-','')-------用系统日期的前一天作为方案表的取dayid日期
     and is_deleted =0
     and bounty_rule_type=1--本任务仅为GMV
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
        t2.freeze_sales_team_value,
        t2.freeze_sales_team_operator,
        t2.item_style_value,
        t2.item_style_operator,
        t2.category_first_value,
        t2.category_first_operator,
        t2.category_second_value,
        t2.category_second_operator,
        t2.brand_value,
        t2.brand_operator,
        t2.item_value,
        t2.item_operator,
        t2.war_area_value,
        t2.war_area_operator,
        t2.bd_area_value,
        t2.bd_area_operator,
        t2.manage_area_value,
        t2.manage_area_operator,
        t2.shop_group_value,
        t2.shop_group_operator,
        t2.calculate_date_value_start,
        t2.calculate_date_value_end,
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
    gmv.update_time,
      gmv.update_month,
      gmv.plan_type,
      gmv.plan_month,
      gmv.plan_pay_time,
      gmv.plan_name,
      gmv.plan_group_id,
      gmv.plan_group_name,
      gmv.business_unit,
      gmv.category_id_first,
      gmv.category_id_second,
      gmv.category_id_first_name,
      gmv.category_id_second_name,
      gmv.brand_id,
      gmv.brand_name,
      gmv.item_id,
      gmv.item_name,
      gmv.item_style,
      gmv.item_style_name,
      gmv.is_sp_shop,
      gmv.is_bigbd_shop,
      gmv.is_spec_order,
      gmv.shop_id,
      gmv.shop_name,
      gmv.store_type,
      gmv.store_type_name,
      gmv.war_zone_id,
      gmv.war_zone_name,
      gmv.war_zone_dep_id,
      gmv.war_zone_dep_name,
      gmv.area_manager_id,
      gmv.area_manager_name,
      gmv.area_manager_dep_id,
      gmv.area_manager_dep_name,
      gmv.bd_manager_id,
      gmv.bd_manager_name,
      gmv.bd_manager_dep_id,
      gmv.bd_manager_dep_name,
      gmv.sp_id,
      gmv.sp_name,
      gmv.sp_operator_name,
      gmv.service_user_names_freezed,
      gmv.service_feature_names_freezed,
      gmv.service_job_names_freezed,
      gmv.service_department_names_freezed,
      gmv.service_info_freezed,
      gmv.service_info,
      gmv.gmv_less_refund,
      gmv.gmv,
      gmv.pay_amount,
      gmv.pay_amount_less_refund,
      gmv.refund_actual_amount,
      gmv.refund_retreat_amount,
      gmv.grant_object_type,
      gmv.grant_object_user_id,
      gmv.grant_object_user_name,
      gmv.grant_object_user_dep_id,
      gmv.grant_object_user_dep_name,
      gmv.leave_time,
      gmv.is_leave,
      gmv.sts_target_name,
      gmv.sts_target,
      gmv.pay_day,
      gmv.planno
from (
    select
      *
    from dw_salary_gmv_rule_public_d
    where dayid = '$v_date' and pltype='pre'
  ) gmv left join (
    select no
    from dw_bounty_plan_d t1
    where ${supply_data_where_condition}
  ) plan
  on gmv.planno = plan.no
  -- 关联不上的，就是不参与补数据
  where plan.no is null
  -- 非补数模式下自动跳过
  and 1='${supply_data_mode}'
)
insert overwrite table dw_salary_gmv_rule_public_d partition (dayid='$v_date',pltype='pre')
select
   from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as update_time,                                 --更新时间
   from_unixtime(unix_timestamp(),'yyyy-MM') as update_month,                                            --执行月份
   plan_type as plan_type ,                                                                              --明细类型
   --方案基础信息,
   replace(plan_month,'-','') as plan_month,                                                                             --方案月份
   plan_pay_time as plan_pay_time,                                                                       --方案时间
   plan_name as plan_name,                                                                               --方案名称
   plan_group_id as plan_group_id,                                                                       --归属业务组id
   plan_group_name as plan_group_name,                                                                   --归属业务组
   business_unit,                                                                                        --业务域,
   category_id_first,                                                                                    --商品一级类目
   category_id_second,                                                                                   --商品二级类目
   category_id_first_name,
   category_id_second_name,
   brand_id,
   brand_name,                                                                                           --商品品牌
   item_id,
   item_name,                                                                                            --商品名称
   item_style,
   item_style_name,                                                                                      --ab类型,
   is_sp_shop,                                                                                           --是否服务商订单
   is_bigbd_shop,                                                                                        --是否大BD门店
   is_spec_order,                                                                                        --是否特殊订单
   shop_id,
   shop_name,                                                                                            --门店名称
   store_type,                                                                                           --门店类型
   store_type_name,
   war_zone_id       ,                                                                                   --战区经理ID
   war_zone_name     ,                                                                                   --战区经理
   war_zone_dep_id   ,                                                                                   --战区ID
   war_zone_dep_name ,                                                                                   --战区
   area_manager_id      ,                                                                                --大区经理id
   area_manager_name    ,                                                                                --大区经理
   area_manager_dep_id,                                                                                  --大区区域ID
   area_manager_dep_name,                                                                                --大区
   bd_manager_id        ,                                                                                --主管id
   bd_manager_name      ,                                                                                --主管
   bd_manager_dep_id,                                                                                    --主管区域ID
   bd_manager_dep_name  ,                                                                                --区域
   sp_id,
   sp_name,                                                                                              --服务商名,
   sp_operator_name,                                                                                     --服务商经理名,
   service_user_names_freezed,                                                                           --冻结销售人员姓名
   service_feature_names_freezed,                                                                        --冻结销售人员职能
   service_job_names_freezed,                                                                            --冻结销售人员角色
   service_department_names_freezed,                                                                     --冻结销售人员部门
   service_info_freezed,
   service_info,
    --默认指标--
   gmv_less_refund,                                                                                      --实货gmv-退款
   gmv,                                                                                                  --实货gmv,
   pay_amount,                                                                                           --实货支付金额
   pay_amount_less_refund,                                                                               --实货支付金额-退款
   refund_actual_amount,                                                                                 --实货退款
   refund_retreat_amount,                                                                                --实货清退金额
   --发放对象--
   grant_object_type,                                                                                    --发放对象类型
   grant_object_user_id,                                                                      --发放对象ID
   grant_object_user_name,                                                                       --发放对象名称
   grant_object_user_dep_id,                                                                        --发放对象部门ID
   grant_object_user_dep_name,                                                                    --发放对象部门
   users.leave_time as leave_time,                                                                       --发放对象离职时间
   case when users.leave_time is not null and pay_day>users.leave_time then '是' else '否' end as is_leave,--发放对象是否离职
   ---统计指标----
   --方案配置 无指标计算型 过滤条件
   sts_target_name as sts_target_name                                                                    --统计指标名称
   ,case when (users.leave_time is null or pay_day<=users.leave_time) then
         case when indicator_code in ('STOCK_GMV_1_GOODS_GMV_MINUS_REFUND', 'STOCK_GMV_AVG_GOODS_GMV_MINUS_REFUND')
              --实货GMV(去退款)
              then gmv_less_refund
              --实货GMV
              when indicator_code = 'STOCK_GMV_1_GOODS_GMV'
              then gmv
              --实货支付金额(去优惠券去退款)
              when indicator_code in ('STOCK_GMV_1_GOODS_PAY_AMT_MINUS_COUNPONS_MINUS_REF', 'STOCK_GMV_AVG_GOODS_PAY_AMT_MINUS_COUNPONS_REF')
              then pay_amount_less_refund
         end
    else 0 end as sts_target,                                                                            --统计指标数值
    pay_day,
    plan_no
 from
 (
   select  a.dayid,
           a.business_unit,                                                                              --业务域
           a.category_id_first,                                                                          --商品一级类目
           a.category_id_second,                                                                         --商品二级类目
           a.category_id_first_name,
           a.category_id_second_name,
           a.brand_id,
           a.brand_name,                                                                                 --商品品牌
           a.item_id,
           a.item_name,                                                                                  --商品名称
           a.item_style,
           a.item_style_name,                                                                            --ab类型
           a.is_sp_shop,                                                                                 --是否服务商订单
           a.is_bigbd_shop,                                                                              --是否大BD门店
           a.is_spec_order,                                                                              --是否特殊订单
           a.shop_id,
           a.shop_name,                                                                                  --门店名称
           a.store_type,                                                                                 --门店类型
           a.store_type_name,
           a.war_zone_id       ,                                                                         --战区经理ID
           a.war_zone_name     ,                                                                         --战区经理
           a.war_zone_dep_id   ,                                                                         --战区ID
           a.war_zone_dep_name ,                                                                         --战区
           a.area_manager_id      ,                                                                      --大区经理id
           a.area_manager_dep_id,                                                                        --大区区域ID
           a.area_manager_name    ,                                                                      --大区经理
           a.area_manager_dep_name,                                                                      --大区
           a.bd_manager_id        ,                                                                      --主管id
           a.bd_manager_name      ,                                                                      --主管
           a.bd_manager_dep_id,                                                                          --主管区域ID
           a.bd_manager_dep_name  ,                                                                      --区域
           a.sp_id,
           a.sp_name,                                                                                    --服务商名
           a.sp_operator_name,                                                                           --服务商经理名
           a.service_user_names_freezed,                                                                 --冻结销售人员姓名
           a.service_feature_names_freezed,                                                              --冻结销售人员职能
           a.service_job_names_freezed,                                                                  --冻结销售人员角色
           a.service_department_names_freezed,                                                           --冻结销售人员部门
           a.service_info_freezed,
           a.service_info,
           --默认指标--
           sum(case when business_unit not in ('卡券票','其他') then a.gmv - nvl(c.refund_actual_amount,0) else 0 end) as gmv_less_refund,                                  --实货gmv-退款
           sum(case when business_unit not in ('卡券票','其他') then a.gmv else 0 end) as gmv,                                                                              --实货gmv
           sum(case when business_unit not in ('卡券票','其他') then a.pay_amount else 0 end) as pay_amount,                                                                --实货支付金额
           sum(case when business_unit not in ('卡券票','其他') then a.pay_amount - nvl(c.refund_actual_amount,0) else 0 end) as pay_amount_less_refund,                    --实货支付金额-退款
           sum(case when business_unit not in ('卡券票','其他') then nvl(c.refund_actual_amount,0) else 0 end) as refund_actual_amount,                                     --实货退款
           sum(case when business_unit not in ('卡券票','其他') then nvl(c.refund_retreat_amount,0) else 0 end) as refund_retreat_amount,                                   --实货清退金额
           a.pay_day,
           b.plan_type,
           b.plan_month,
           b.plan_pay_time,
           b.plan_name,
           b.plan_group_id,
           b.plan_group_name,
           b.plan_no,
           b.indicator_code,
           b.sts_target_name,
           b.grant_object_type,
           b.grant_object_type_code,
           case  when b.grant_object_type_code= 'WAR_ZONE_MANAGE' then war_zone_id
                 when b.grant_object_type_code= 'AREA_MANAGER' then area_manager_id
                 when b.grant_object_type_code= 'BD_MANAGER' then bd_manager_id
                 when b.grant_object_type_code= 'BD' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_user_id')
                 when b.grant_object_type_code= 'BIG_BD' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_user_id')
            end as  grant_object_user_id,                                                                      --发放对象ID
           case when b.grant_object_type_code= 'WAR_ZONE_MANAGE' then war_zone_name
                when b.grant_object_type_code= 'AREA_MANAGER' then area_manager_name
                when b.grant_object_type_code= 'BD_MANAGER' then bd_manager_name
                when b.grant_object_type_code= 'BD' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_user_name')
                when b.grant_object_type_code= 'BIG_BD' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_user_name')
            end as grant_object_user_name,                                                                       --发放对象名称
           case when b.grant_object_type_code= 'WAR_ZONE_MANAGE' then war_zone_dep_id
                when b.grant_object_type_code= 'AREA_MANAGER' then area_manager_dep_id
                when b.grant_object_type_code= 'BD_MANAGER' then bd_manager_dep_id
                when b.grant_object_type_code= 'BD' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_department_id')
                when b.grant_object_type_code= 'BIG_BD' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_department_id')
            end as grant_object_user_dep_id,                                                                      --发放对象部门ID
           case when b.grant_object_type_code= 'WAR_ZONE_MANAGE' then war_zone_dep_name
                when b.grant_object_type_code= 'AREA_MANAGER' then area_manager_dep_name
                when b.grant_object_type_code= 'BD_MANAGER' then bd_manager_dep_name
                when b.grant_object_type_code= 'BD' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_department_name')
                when b.grant_object_type_code= 'BIG_BD' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_department_name')
            end as grant_object_user_dep_name                                                                    --发放对象部门
    from
         (select *
            from dw_salary_gmv_rule_public_mid_v2_d
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
            and dayid > '0' ) a
    left join
    (select order_id,sum(refund_actual_amount) as refund_actual_amount,
        sum(case when multiple_refund=10 then refund_actual_amount else 0 end) as refund_retreat_amount
     from dw_afs_order_refund_new_d --（后期通过type识别清退金额）
       where dayid ='$v_date'
     and refund_status=9
       group by order_id
     ) c on a.order_id=c.order_id
    cross join bounty_plan2 b
      on 1=1
      and a.dayid = replace(date_sub(add_months(concat(b.plan_month, '-01'), 1), 1), '-', '')
      and pay_day between calculate_date_value_start and calculate_date_value_end
      and ytdw.simple_expr( sale_team_freezed_id,'in',freeze_sales_team_value)=(case when freeze_sales_team_operator ='=' then 1 else 0 end)
      and ytdw.simple_expr( item_style_name,'in',item_style_value)=(case when item_style_operator ='=' then 1 else 0 end)
      and ytdw.simple_expr( category_id_first,'in',category_first_value)=(case when category_first_operator ='=' then 1 else 0 end)
      and ytdw.simple_expr( category_id_second,'in',category_second_value)=(case when category_second_operator ='=' then 1 else 0 end)
      and ytdw.simple_expr( brand_id,'in',brand_value)=(case when brand_operator ='=' then 1 else 0 end)
      and ytdw.simple_expr( item_id,'in',item_value)=(case when item_operator ='=' then 1 else 0 end)
      and ytdw.simple_expr( war_zone_dep_id,'in',war_area_value)=(case when war_area_operator ='=' then 1 else 0 end)
      and ytdw.simple_expr( area_manager_dep_id,'in',bd_area_value)=(case when bd_area_operator ='=' then 1 else 0 end)
      and ytdw.simple_expr( bd_manager_dep_id,'in',manage_area_value)=(case when manage_area_operator ='=' then 1 else 0 end)
      and if(a.shop_group = '' OR b.shop_group_value = '', 0, ytdw.simple_expr(substr(b.shop_group_value, 2, length(b.shop_group_value) - 2), 'in', concat('[', a.shop_group, ']'))) = (case when shop_group_operator ='=' then 1 else 0 end)

   group by a.dayid,
           a.business_unit,                                                                              --业务域
           a.category_id_first,                                                                          --商品一级类目
           a.category_id_second,                                                                         --商品二级类目
           a.category_id_first_name,
           a.category_id_second_name,
           a.brand_id,
           a.brand_name,                                                                                 --商品品牌
           a.item_id,
           a.item_name,                                                                                  --商品名称
           a.item_style,
           a.item_style_name,                                                                            --ab类型
           a.is_sp_shop,                                                                                 --是否服务商订单
           a.is_bigbd_shop,                                                                              --是否大BD门店
           a.is_spec_order,                                                                              --是否特殊订单
           a.shop_id,
           a.shop_name,                                                                                  --门店名称
           a.store_type,                                                                                 --门店类型
           a.store_type_name,
           a.war_zone_id       ,                                                                         --战区经理ID
           a.war_zone_name     ,                                                                         --战区经理
           a.war_zone_dep_id   ,                                                                         --战区ID
           a.war_zone_dep_name ,                                                                         --战区
           a.area_manager_id      ,                                                                      --大区经理id
           a.area_manager_dep_id,                                                                        --大区区域ID
           a.area_manager_name    ,                                                                      --大区经理
           a.area_manager_dep_name,                                                                      --大区
           a.bd_manager_id        ,                                                                      --主管id
           a.bd_manager_name      ,                                                                      --主管
           a.bd_manager_dep_id,                                                                          --主管区域ID
           a.bd_manager_dep_name  ,                                                                      --区域
           a.sp_id,
           a.sp_name,                                                                                    --服务商名
           a.sp_operator_name,                                                                           --服务商经理名
           a.service_user_names_freezed,                                                                 --冻结销售人员姓名
           a.service_feature_names_freezed,                                                              --冻结销售人员职能
           a.service_job_names_freezed,                                                                  --冻结销售人员角色
           a.service_department_names_freezed,                                                           --冻结销售人员部门
           a.service_info_freezed,
           a.service_info,
           a.pay_day,
           b.plan_type,
           b.plan_month,
           b.plan_pay_time,
           b.plan_name,
           b.plan_group_id,
           b.plan_group_name,
           b.plan_no,
           b.indicator_code,
           b.sts_target_name,
           b.grant_object_type,
           b.grant_object_type_code,
           case  when b.grant_object_type_code= 'WAR_ZONE_MANAGE' then war_zone_id
                 when b.grant_object_type_code= 'AREA_MANAGER' then area_manager_id
                 when b.grant_object_type_code= 'BD_MANAGER' then bd_manager_id
                 when b.grant_object_type_code= 'BD' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_user_id')
                 when b.grant_object_type_code= 'BIG_BD' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_user_id')
            end ,                                                                      --发放对象ID
           case when b.grant_object_type_code= 'WAR_ZONE_MANAGE' then war_zone_name
                when b.grant_object_type_code= 'AREA_MANAGER' then area_manager_name
                when b.grant_object_type_code= 'BD_MANAGER' then bd_manager_name
                when b.grant_object_type_code= 'BD' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_user_name')
                when b.grant_object_type_code= 'BIG_BD' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_user_name')
            end ,                                                                       --发放对象名称
           case when b.grant_object_type_code= 'WAR_ZONE_MANAGE' then war_zone_dep_id
                when b.grant_object_type_code= 'AREA_MANAGER' then area_manager_dep_id
                when b.grant_object_type_code= 'BD_MANAGER' then bd_manager_dep_id
                when b.grant_object_type_code= 'BD' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_department_id')
                when b.grant_object_type_code= 'BIG_BD' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_department_id')
            end ,                                                                      --发放对象部门ID
           case when b.grant_object_type_code= 'WAR_ZONE_MANAGE' then war_zone_dep_name
                when b.grant_object_type_code= 'AREA_MANAGER' then area_manager_dep_name
                when b.grant_object_type_code= 'BD_MANAGER' then bd_manager_dep_name
                when b.grant_object_type_code= 'BD' then ytdw.get_service_info('service_job_name:BD',service_info_freezed,'service_department_name')
                when b.grant_object_type_code= 'BIG_BD' then ytdw.get_service_info('service_job_name:大BD',service_info_freezed,'service_department_name')
            end
  ) gmv_rule
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
) users on gmv_rule.grant_object_user_id =users.user_id and gmv_rule.dayid = users.dayid
where gmv_rule.grant_object_user_id is not null
union all
  select * from without_supply_data_plan
;
" &&

exit 0