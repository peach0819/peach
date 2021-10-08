WITH old_detail as (
    SELECT *
    FROM ads_order_biz_order_channel_detail_d
    WHERE dayid = '$v_date'
),
new_detail as (
    SELECT *
    FROM stg_order_channel_detail_d
    WHERE dayid = '$v_date'
)

SELECT
       CASE WHEN old_detail.trade_id != new_detail.trade_id THEN old_detail.trade_id ELSE null end as trade_id1,
       CASE WHEN old_detail.trade_id != new_detail.trade_id THEN new_detail.trade_id ELSE null end as trade_id2,
       CASE WHEN old_detail.trade_no != new_detail.trade_no THEN old_detail.trade_no ELSE null end as trade_no1,
       CASE WHEN old_detail.trade_no != new_detail.trade_no THEN new_detail.trade_no ELSE null end as trade_no2,
       CASE WHEN old_detail.order_place_time != new_detail.order_place_time THEN old_detail.order_place_time ELSE null end as order_place_time1,
       CASE WHEN old_detail.order_place_time != new_detail.order_place_time THEN new_detail.order_place_time ELSE null end as order_place_time2,
       CASE WHEN old_detail.shop_id != new_detail.shop_id THEN old_detail.shop_id ELSE null end as shop_id1,
       CASE WHEN old_detail.shop_id != new_detail.shop_id THEN new_detail.shop_id ELSE null end as shop_id2,
       CASE WHEN old_detail.shop_name != new_detail.shop_name THEN old_detail.shop_name ELSE null end as shop_name1,
       CASE WHEN old_detail.shop_name != new_detail.shop_name THEN new_detail.shop_name ELSE null end as shop_name2,
       CASE WHEN old_detail.sale_dc_id != new_detail.sale_dc_id THEN old_detail.sale_dc_id ELSE null end as sale_dc_id1,
       CASE WHEN old_detail.sale_dc_id != new_detail.sale_dc_id THEN new_detail.sale_dc_id ELSE null end as sale_dc_id2,
       CASE WHEN old_detail.bu_id != new_detail.bu_id THEN old_detail.bu_id ELSE null end as bu_id1,
       CASE WHEN old_detail.bu_id != new_detail.bu_id THEN new_detail.bu_id ELSE null end as bu_id2,
       CASE WHEN old_detail.is_pickup_recharge_order != new_detail.is_pickup_recharge_order THEN old_detail.is_pickup_recharge_order ELSE null end as is_pickup_recharge_order1,
       CASE WHEN old_detail.is_pickup_recharge_order != new_detail.is_pickup_recharge_order THEN new_detail.is_pickup_recharge_order ELSE null end as is_pickup_recharge_order2,
       CASE WHEN old_detail.supply_id != new_detail.supply_id THEN old_detail.supply_id ELSE null end as supply_id1,
       CASE WHEN old_detail.supply_id != new_detail.supply_id THEN new_detail.supply_id ELSE null end as supply_id2,
       CASE WHEN old_detail.category_1st_id != new_detail.category_1st_id THEN old_detail.category_1st_id ELSE null end as category_1st_id1,
       CASE WHEN old_detail.category_1st_id != new_detail.category_1st_id THEN new_detail.category_1st_id ELSE null end as category_1st_id2,
       CASE WHEN old_detail.category_2nd_id != new_detail.category_2nd_id THEN old_detail.category_2nd_id ELSE null end as category_2nd_id1,
       CASE WHEN old_detail.category_2nd_id != new_detail.category_2nd_id THEN new_detail.category_2nd_id ELSE null end as category_2nd_id2,
       CASE WHEN old_detail.category_3rd_id != new_detail.category_3rd_id THEN old_detail.category_3rd_id ELSE null end as category_3rd_id1,
       CASE WHEN old_detail.category_3rd_id != new_detail.category_3rd_id THEN new_detail.category_3rd_id ELSE null end as category_3rd_id2,
       CASE WHEN old_detail.performance_category_1st_id != new_detail.performance_category_1st_id THEN old_detail.performance_category_1st_id ELSE null end as performance_category_1st_id1,
       CASE WHEN old_detail.performance_category_1st_id != new_detail.performance_category_1st_id THEN new_detail.performance_category_1st_id ELSE null end as performance_category_1st_id2,
       CASE WHEN old_detail.performance_category_2nd_id != new_detail.performance_category_2nd_id THEN old_detail.performance_category_2nd_id ELSE null end as performance_category_2nd_id1,
       CASE WHEN old_detail.performance_category_2nd_id != new_detail.performance_category_2nd_id THEN new_detail.performance_category_2nd_id ELSE null end as performance_category_2nd_id2,
       CASE WHEN old_detail.performance_category_3rd_id != new_detail.performance_category_3rd_id THEN old_detail.performance_category_3rd_id ELSE null end as performance_category_3rd_id1,
       CASE WHEN old_detail.performance_category_3rd_id != new_detail.performance_category_3rd_id THEN new_detail.performance_category_3rd_id ELSE null end as performance_category_3rd_id2,
       CASE WHEN old_detail.item_style != new_detail.item_style THEN old_detail.item_style ELSE null end as item_style1,
       CASE WHEN old_detail.item_style != new_detail.item_style THEN new_detail.item_style ELSE null end as item_style2,
       CASE WHEN old_detail.store_type != new_detail.store_type THEN old_detail.store_type ELSE null end as store_type1,
       CASE WHEN old_detail.store_type != new_detail.store_type THEN new_detail.store_type ELSE null end as store_type2,
       CASE WHEN old_detail.sub_store_type != new_detail.sub_store_type THEN old_detail.sub_store_type ELSE null end as sub_store_type1,
       CASE WHEN old_detail.sub_store_type != new_detail.sub_store_type THEN new_detail.sub_store_type ELSE null end as sub_store_type2,
       CASE WHEN old_detail.sp_id != new_detail.sp_id THEN old_detail.sp_id ELSE null end as sp_id1,
       CASE WHEN old_detail.sp_id != new_detail.sp_id THEN new_detail.sp_id ELSE null end as sp_id2,
       CASE WHEN old_detail.sp_name != new_detail.sp_name THEN old_detail.sp_name ELSE null end as sp_name1,
       CASE WHEN old_detail.sp_name != new_detail.sp_name THEN new_detail.sp_name ELSE null end as sp_name2,
       CASE WHEN old_detail.sp_operator_id != new_detail.sp_operator_id THEN old_detail.sp_operator_id ELSE null end as sp_operator_id1,
       CASE WHEN old_detail.sp_operator_id != new_detail.sp_operator_id THEN new_detail.sp_operator_id ELSE null end as sp_operator_id2,
       CASE WHEN old_detail.shop_pool_server_group_id != new_detail.shop_pool_server_group_id THEN old_detail.shop_pool_server_group_id ELSE null end as shop_pool_server_group_id1,
       CASE WHEN old_detail.shop_pool_server_group_id != new_detail.shop_pool_server_group_id THEN new_detail.shop_pool_server_group_id ELSE null end as shop_pool_server_group_id2,
       CASE WHEN old_detail.shop_group_id != new_detail.shop_group_id THEN old_detail.shop_group_id ELSE null end as shop_group_id1,
       CASE WHEN old_detail.shop_group_id != new_detail.shop_group_id THEN new_detail.shop_group_id ELSE null end as shop_group_id2
FROM new_detail
FULL JOIN old_detail ON new_detail.order_id = old_detail.order_id
WHERE new_detail.trade_id != old_detail.trade_id
   OR new_detail.trade_no != old_detail.trade_no
   OR new_detail.order_place_time != old_detail.order_place_time
   OR new_detail.shop_id != old_detail.shop_id
   OR new_detail.shop_name != old_detail.shop_name
   OR new_detail.sale_dc_id != old_detail.sale_dc_id
   OR new_detail.bu_id != old_detail.bu_id
   OR new_detail.is_pickup_recharge_order != old_detail.is_pickup_recharge_order
   OR new_detail.supply_id != old_detail.supply_id
   OR new_detail.category_1st_id != old_detail.category_1st_id
   OR new_detail.category_2nd_id != old_detail.category_2nd_id
   OR new_detail.category_3rd_id != old_detail.category_3rd_id
   OR new_detail.performance_category_1st_id != old_detail.performance_category_1st_id
   OR new_detail.performance_category_2nd_id != old_detail.performance_category_2nd_id
   OR new_detail.performance_category_3rd_id != old_detail.performance_category_3rd_id
   OR new_detail.item_style != old_detail.item_style
   OR new_detail.store_type != old_detail.store_type
   OR new_detail.sub_store_type != old_detail.sub_store_type
   OR new_detail.sp_id != old_detail.sp_id
   OR new_detail.sp_name != old_detail.sp_name
   OR new_detail.sp_operator_id != old_detail.sp_operator_id
   OR new_detail.shop_pool_server_group_id != old_detail.shop_pool_server_group_id
   OR new_detail.shop_group_id != old_detail.shop_group_id