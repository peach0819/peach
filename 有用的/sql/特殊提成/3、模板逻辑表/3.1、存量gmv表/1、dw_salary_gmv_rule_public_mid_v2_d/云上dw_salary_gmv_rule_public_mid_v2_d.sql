insert overwrite table dw_salary_gmv_rule_public_mid_v2_d partition(dayid='${v_date}')
select business_unit,--业务域,
       item.performance_category_1st_id,  --业绩一级类目,
       item.performance_category_2nd_id, --业绩二级类目,
       item.performance_category_1st_name,
       item.performance_category_2nd_name,
       item.brand_id,
       item.brand_name,--业绩品牌,
       order.item_id,
       item_name,--商品名称,
       item_style,
       case when order.item_style=0 then 'A' when order.item_style=1 then 'B' else '其他' end as item_style_name,--ab类型,
       case when order.sp_id is not null then '是' else '否' end as is_sp_shop,--是否服务商订单
       case when ytdw.get_service_info('service_feature_id:4',service_info_freezed,'service_user_id') is not null then '是' else '否' end as is_bigbd_shop,--是否大BD门店
       case when spec_order.trade_no is not null then '是' else '否' end as is_spec_order,--是否特殊订单,
       order.shop_id,
       shop_name,--门店名称,
       store_type,--门店类型,
       store_type_name,
       shop.war_zone_id       , --战区经理ID
       shop.war_zone_name     , --战区经理
       shop.war_zone_dep_id   , --战区ID
       shop.war_zone_dep_name , --战区
       shop.area_manager_id     	,   --大区经理id
       shop.area_manager_name   	,   --大区经理
       shop.area_manager_dep_id, --大区区域ID
       shop.area_manager_dep_name,   --大区
       shop.bd_manager_id       	,--主管id
       shop.bd_manager_name     	,--主管
       shop.bd_manager_dep_id ,--主管区域ID
       shop.bd_manager_dep_name 	,--区域
       sp_id,
       sp_name,--服务商名,
       null as sp_operator_name,--服务商经理名,
       ytdw.get_service_info('service_type:all',service_info_freezed,'service_user_name') as service_user_names_freezed,--冻结销售人员姓名,
       ytdw.get_service_info('service_type:all',service_info_freezed,'service_feature_name') as service_feature_names_freezed,--冻结销售人员职能,
       ytdw.get_service_info('service_type:all',service_info_freezed,'service_job_name') as service_job_names_freezed,--冻结销售人员角色,
       ytdw.get_service_info('service_type:all',service_info_freezed,'service_department_name') as service_department_names_freezed,--冻结销售人员部门,
       order.service_info_freezed,
       order.service_info,

       --默认指标--
       if(business_unit not in ('卡券票','其他'), order.total_pay_amount - nvl(refund.refund_actual_amount,0), 0) as gmv_less_refund,  --实货gmv-退款,
       if(business_unit not in ('卡券票','其他'), order.total_pay_amount, 0) as gmv,--实货gmv,
       if(business_unit not in ('卡券票','其他'), order.pay_amount, 0) as pay_amount,--实货支付金额
       if(business_unit not in ('卡券票','其他'), order.pay_amount - nvl(refund.refund_actual_amount,0), 0) as pay_amount_less_refund,--实货支付金额-退款
       if(business_unit not in ('卡券票','其他'), nvl(refund.refund_actual_amount,0), 0) as refund_actual_amount,--实货退款,
       if(business_unit not in ('卡券票','其他'), nvl(refund.refund_retreat_amount,0), 0) as refund_retreat_amount,--实货清退金额

       substr(order.pay_time,1,8) as pay_day,
       order.order_id,
       ord_seller.sale_team_name,
       ord_seller.sale_team_freezed_name,
       ord_seller.sale_team_id,
       ord_seller.sale_team_freezed_id,
       null as shop_group,

       --提货卡口径指标
       if(order.is_pickup_recharge_order = 1 OR business_unit not in ('卡券票','其他'), order.total_pay_amount - nvl(order.pickup_card_amount, 0) - nvl(refund.refund_actual_amount_less_pickup, 0), 0) as pickup_pay_gmv_less_refund, --提货卡口径gmv-退款
       if(order.is_pickup_recharge_order = 1 OR business_unit not in ('卡券票','其他'), order.total_pay_amount - nvl(order.pickup_card_amount, 0), 0) as pickup_pay_gmv,  --提货卡口径gmv
       if(order.is_pickup_recharge_order = 1 OR business_unit not in ('卡券票','其他'), order.pay_amount - nvl(order.pickup_card_amount, 0), 0) as pickup_pay_pay_amount, --提货卡口径支付金额
       if(order.is_pickup_recharge_order = 1 OR business_unit not in ('卡券票','其他'), order.pay_amount - nvl(order.pickup_card_amount, 0) - nvl(refund.refund_actual_amount_less_pickup, 0), 0) as pickup_pay_pay_amount_less_refund, --提货卡口径支付金额-退款

       --提货卡充值指标
       if(is_pickup_recharge_order = 1, order.total_pay_amount - nvl(refund.refund_actual_amount, 0), 0) as pickup_recharge_gmv_less_refund, --提货卡充值gmv-退款
       if(is_pickup_recharge_order = 1, order.total_pay_amount, 0) as pickup_recharge_gmv, --提货卡充值gmv
       if(is_pickup_recharge_order = 1, order.pay_amount, 0) as pickup_recharge_pay_amount, --提货卡充值支付金额
       if(is_pickup_recharge_order = 1, order.pay_amount - nvl(refund.refund_actual_amount, 0), 0) as pickup_recharge_pay_amount_less_refund, --提货卡充值支付金额-退款
       is_pickup_recharge_order,

       --hi卡充值指标
       if(order.item_style = 1 AND order.category_id_first_name = '卡券票' AND order.is_pickup_recharge_order = 0, order.total_pay_amount, 0) as hi_recharge_gmv, --hi卡充值gmv
       if(order.item_style = 1 AND order.category_id_first_name = '卡券票' AND order.is_pickup_recharge_order = 0, order.total_pay_amount - nvl(refund.refund_actual_amount, 0), 0) as hi_recharge_gmv --hi卡充值gmv-退款
--订单表
from (
    select *
    from ytdw.dw_order_d
    where dayid ='${v_date}'
    -- 保留近100天数据
    and substr(pay_time,1,8) >= replace(date_add('${v_op_time}', -100), '-', '')
    and bu_id=0
) order

--退款表
left join (
    select order_id,
           sum(refund_actual_amount) as refund_actual_amount,
           sum(if(multiple_refund=10, refund_actual_amount, 0)) as refund_retreat_amount,
           nvl(sum(refund_pickup_card_amount), 0) as refund_pickup_card_amount,
           sum(refund_actual_amount) - nvl(sum(refund_pickup_card_amount), 0) as refund_actual_amount_less_pickup
    from ytdw.dw_afs_order_refund_new_d
    where dayid ='${v_date}'
    and refund_status=9
    group by order_id
) refund on order.order_id=refund.order_id

--特殊订单表
left join (
    select trade_no
    from yt_crm.ads_salary_base_special_order_d
    where dayid ='${v_date}'
) spec_order on order.trade_no=spec_order.trade_no

--门店表
left join (
    select shop_id,
           war_zone_id       , --战区经理ID
           war_zone_name     , --战区经理
           war_zone_dep_id   , --战区ID
           war_zone_dep_name , --战区
           area_manager_id     	,   --大区经理id
           area_manager_name   	,   --大区经理
           area_manager_dep_id,--大区区域ID
           area_manager_dep_name,   --大区
           bd_manager_id       	,--主管id
           bd_manager_name     	,--主管
           bd_manager_dep_id ,--主管区域ID
           bd_manager_dep_name 	--区域
    from ytdw.dw_shop_base_d
    where dayid ='${v_date}'
) shop on order.shop_id=shop.shop_id

--订单销售团队表
LEFT JOIN (
    SELECT order_id,
           sale_team_id,
           sale_team_name,
           sale_team_freezed_id,
           sale_team_freezed_name
    FROM ytdw.dim_hpc_trd_ord_seller_d
    WHERE dayid = '${v_date}'
) ord_seller ON order.order_id = ord_seller.order_id

--商品表，获取业绩属性
LEFT JOIN (
    SELECT item_id,
           brand_id, --业绩品牌
           brand_name,
           performance_category_1st_id,  --业绩一级类目
           performance_category_1st_name,
           performance_category_2nd_id,  -- 业绩二级类目
           performance_category_2nd_name
    FROM ytdw.dim_ytj_itm_item_d
    WHERE dayid = '${v_date}'
) item ON order.item_id = item.item_id