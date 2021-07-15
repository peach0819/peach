--系统类目海拍客类目转换
WITH category as (
    SELECT id, name, biz_category_id
    FROM dwd_category_d
    WHERE dayid = '$v_date'
),

--订单基础信息
order_base as (
    SELECT order1.order_id,
           order1.trade_id,
           order1.trade_no,
           order1.order_place_time,
           order1.shop_id,
           case when order1.sale_dc_id = -1 then 0 else order1.sale_dc_id end as sale_dc_id,
           order1.sale_dc_id_name,
           order1.bu_id,
           order1.bu_id_name,
           order1.is_pickup_pay_order,
           order1.is_pickup_recharge_order,
           order1.supply_id,
           order1.supply_name,
           c1.biz_category_id as category_1st_id,
           c2.biz_category_id as category_2nd_id,
           c3.biz_category_id as category_3rd_id,
           order1.category_1st_name,
           order1.category_2nd_name,
           order1.category_3rd_name,
           pc1.biz_category_id as performance_category_1st_id,
           order1.performance_category_1st_name,
           pc2.biz_category_id as performance_category_2nd_id,
           order1.performance_category_2nd_name,
           pc3.biz_category_id as performance_category_3rd_id,
           order1.performance_category_3rd_name,
           order1.item_style,
           order1.item_style_name
    FROM dw_trd_order_d order1
    LEFT JOIN category c1 ON order1.category_1st_id = c1.id
    LEFT JOIN category c2 ON order1.category_2nd_id = c2.id
    LEFT JOIN category c3 ON order1.category_3rd_id = c3.id
    LEFT JOIN category pc1 ON order1.performance_category_1st_id = pc1.id
    LEFT JOIN category pc2 ON order1.performance_category_2nd_id = pc2.id
    LEFT JOIN category pc3 ON order1.performance_category_3rd_id = pc3.id
    WHERE dayid='$v_date'
),

--门店信息
shop_base as(
    SELECT shop_id,
           shop_name,
           store_type,
           sub_store_type
    FROM dwd_shop_d
    WHERE dayid='$v_date'
),

--门店服务人员信息合并表
shop_pool_server as (
    SELECT shop_id,
           concat_ws(',' , sort_array(collect_set(cast(group_id as string)))) as group_id,
           concat_ws(',' , collect_set(user_id)) as user_id
    FROM dwd_shop_pool_server_d
    WHERE dayid='$v_date'
    AND is_deleted = 0
    AND is_enabled = 0
    group by shop_id
),

--门店分组关系
shop_group_mapping as (
    SELECT shop_id,
           concat_ws(',' , sort_array(collect_set(cast(group_id as string)))) as group_id
    FROM dwd_shop_group_mapping_d
    WHERE dayid='$v_date'
    AND is_deleted = 0
    group by shop_id
),

--服务商订单快照信息
sp_order_snapshot as (
    SELECT order_id,
           sp_id,
           sp_name,
           operator_id
    FROM dwd_sp_order_snapshot_d
    WHERE dayid='$v_date'
    AND is_deleted = 0
)

SELECT order_base.order_id,
       order_base.trade_id,
       order_base.trade_no,
       order_base.order_place_time,
       order_base.shop_id,
       shop_base.shop_name,
       order_base.sale_dc_id,
       order_base.sale_dc_id_name,
       order_base.bu_id,
       order_base.bu_id_name,
       order_base.is_pickup_pay_order,
       order_base.is_pickup_recharge_order,
       order_base.supply_id,
       order_base.supply_name,
       order_base.category_1st_id,
       order_base.category_1st_name,
       order_base.category_2nd_id,
       order_base.category_2nd_name,
       order_base.category_3rd_id,
       order_base.category_3rd_name,
       order_base.performance_category_1st_id,
       order_base.performance_category_1st_name,
       order_base.performance_category_2nd_id,
       order_base.performance_category_2nd_name,
       order_base.performance_category_3rd_id,
       order_base.performance_category_3rd_name,
       order_base.item_style,
       order_base.item_style_name,
       shop_base.store_type,
       shop_base.sub_store_type,
       sp_order_snapshot.sp_id,
       sp_order_snapshot.sp_name,
       sp_order_snapshot.operator_id as sp_operator_id,
       shop_pool_server.group_id     as shop_pool_server_group_id,
       shop_pool_server.user_id      as shop_pool_server_user_id,
       shop_group_mapping.group_id   as shop_group_id
FROM order_base
LEFT JOIN shop_base ON order_base.shop_id = shop_base.shop_id
LEFT JOIN shop_pool_server ON shop_pool_server.shop_id = shop_base.shop_id
LEFT JOIN shop_group_mapping ON shop_group_mapping.shop_id = shop_base.shop_id
LEFT JOIN sp_order_snapshot ON order_base.order_id = sp_order_snapshot.order_id