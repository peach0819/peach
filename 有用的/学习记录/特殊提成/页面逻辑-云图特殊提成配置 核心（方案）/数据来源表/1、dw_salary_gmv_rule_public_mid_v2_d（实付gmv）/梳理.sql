

--订单表
with order as (
    select *
    from dw_order_d
    where dayid = '$v_date'
      and substr(pay_time, 1, 8) >= '$v_120_days_ago' --过滤4个月以前数据,目前只允许配置近三个月内的方案
      and bu_id = 0
    --剔除美妆店,员工店,伙伴店
    --and nvl(store_type,100) not in (3,9,11)
    --and sale_dc_id=-1
),

--退款表
refund as (
    select order_id,
           sum(refund_actual_amount) as refund_actual_amount,
           sum(case when multiple_refund=10 then refund_actual_amount else 0 end) as refund_retreat_amount
    from dw_afs_order_refund_new_d
    where dayid ='$v_date'
    and refund_status=9
    group by order_id
),

--特殊订单表
spec_order as (
    select trade_no
    from dw_offline_spec_refund_d
    where dayid ='$v_date'
),

--门店表
shop as (
    select shop_id,
           war_zone_id,           --战区经理ID
           war_zone_name,         --战区经理
           war_zone_dep_id,       --战区ID
           war_zone_dep_name,     --战区
           area_manager_id,       --大区经理id
           area_manager_name,     --大区经理
           area_manager_dep_id,--大区区域ID
           area_manager_dep_name, --大区
           bd_manager_id,--主管id
           bd_manager_name,--主管
           bd_manager_dep_id,--主管区域ID
           bd_manager_dep_name    --区域
    from dw_shop_base_d
    where dayid ='$v_date'
)


insert overwrite table dw_salary_gmv_rule_public_mid_v2_d partition (dayid = '$v_date')
select business_unit,--业务域,
       category_id_first, --商品一级类目,
       category_id_second, --商品二级类目,
       category_id_first_name,
       category_id_second_name,
       brand_id,
       brand_name,--商品品牌,
       item_id,
       item_name,--商品名称,
       item_style,
       case when order.item_style = 0 then 'A' when order.item_style = 1 then 'B' else '其他' end as item_style_name,--ab类型,
       case when order.sp_id is not null then '是' else '否' end                                  as is_sp_shop,--是否服务商订单
       case
           when ytdw.get_service_info('service_feature_id:4', service_info_freezed, 'service_user_id') is not null
               then '是'
           else '否' end                                                                         as is_bigbd_shop,--是否大BD门店
       case when spec_order.trade_no is not null then '是' else '否' end                          as is_spec_order,--是否特殊订单,
       order.shop_id,
       shop_name,--门店名称,
       store_type,--门店类型,
       store_type_name,
       shop.war_zone_id, --战区经理ID
       shop.war_zone_name, --战区经理
       shop.war_zone_dep_id, --战区ID
       shop.war_zone_dep_name, --战区
       shop.area_manager_id, --大区经理id
       shop.area_manager_name, --大区经理
       shop.area_manager_dep_id, --大区区域ID
       shop.area_manager_dep_name, --大区
       shop.bd_manager_id,--主管id
       shop.bd_manager_name,--主管
       shop.bd_manager_dep_id,--主管区域ID
       shop.bd_manager_dep_name,--区域
       sp_id,
       sp_name,--服务商名,
       null                                                                                     as sp_operator_name,--服务商经理名,
       ytdw.get_service_info('service_type:all', service_info_freezed,
                             'service_user_name')                                               as service_user_names_freezed,--冻结销售人员姓名,
       ytdw.get_service_info('service_type:all', service_info_freezed,
                             'service_feature_name')                                            as service_feature_names_freezed,--冻结销售人员职能,
       ytdw.get_service_info('service_type:all', service_info_freezed,
                             'service_job_name')                                                as service_job_names_freezed,--冻结销售人员角色,
       ytdw.get_service_info('service_type:all', service_info_freezed,
                             'service_department_name')                                         as service_department_names_freezed,--冻结销售人员部门,
       order.service_info_freezed,
       order.service_info,
       --默认指标--
       case
           when business_unit not in ('卡券票', '其他') then order.total_pay_amount - nvl(refund.refund_actual_amount, 0)
           else 0 end                                                                           as gmv_less_refund, --实货gmv-退款,
       case when business_unit not in ('卡券票', '其他') then order.total_pay_amount else 0 end      as gmv,--实货gmv,
       case when business_unit not in ('卡券票', '其他') then order.pay_amount else 0 end            as pay_amount,--实货支付金额
       case
           when business_unit not in ('卡券票', '其他') then order.pay_amount - nvl(refund.refund_actual_amount, 0)
           else 0 end                                                                           as pay_amount_less_refund,--实货支付金额-退款
       case
           when business_unit not in ('卡券票', '其他') then nvl(refund.refund_actual_amount, 0)
           else 0 end                                                                           as refund_actual_amount,--实货退款,
       case
           when business_unit not in ('卡券票', '其他') then nvl(refund.refund_retreat_amount, 0)
           else 0 end                                                                           as refund_retreat_amount,--实货清退金额
       substr(order.pay_time, 1, 8)                                                             as pay_day,
       order.order_id,
       sale_team_name,
       sale_team_freezed_name,
       case
           when sale_team_name = '电销部' then 1
           when sale_team_name = 'BD部' then 2
           when sale_team_name = '大客户部' then 3
           when sale_team_name = '服务商部' then 4
           when sale_team_name = '美妆销售团队' then 5
           else null end                                                                        as sale_team_id,
       case
           when sale_team_freezed_name = '电销部' then 1
           when sale_team_freezed_name = 'BD部' then 2
           when sale_team_freezed_name = '大客户部' then 3
           when sale_team_freezed_name = '服务商部' then 4
           when sale_team_freezed_name = '美妆销售团队' then 5
           else null end                                                                        as sale_team_freezed_id

from order  --订单表
left join refund on order.order_id=refund.order_id  --退款表
left join spec_order on order.trade_no=spec_order.trade_no  --特殊订单表
left join shop on order.shop_id=shop.shop_id  --门店表