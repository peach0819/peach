WITH old_detail as (
    SELECT *
    FROM ads_order_biz_order_channel_d
    WHERE dayid = '$v_date'
),
new_detail as (
    SELECT *
    FROM stg_order_channel_d
    WHERE dayid = '$v_date'
)

SELECT
CASE WHEN old_detail.trade_id != new_detail.trade_id THEN old_detail.trade_id as trade_id1,
CASE WHEN old_detail.trade_id != new_detail.trade_id then new_detail.trade_id as trade_id2,
CASE WHEN old_detail.trade_no != new_detail.trade_no THEN old_detail.trade_no as trade_no1,
CASE WHEN old_detail.trade_no != new_detail.trade_no then new_detail.trade_no as trade_no2,
CASE WHEN old_detail.order_place_time != new_detail.order_place_time THEN old_detail.order_place_time as order_place_time1,
CASE WHEN old_detail.order_place_time != new_detail.order_place_time then new_detail.order_place_time as order_place_time2,
CASE WHEN old_detail.shop_id != new_detail.shop_id THEN old_detail.shop_id as shop_id1,
CASE WHEN old_detail.shop_id != new_detail.shop_id then new_detail.shop_id as shop_id2,
CASE WHEN old_detail.shop_name != new_detail.shop_name THEN old_detail.shop_name as shop_name1,
CASE WHEN old_detail.shop_name != new_detail.shop_name then new_detail.shop_name as shop_name2,
CASE WHEN old_detail.sale_dc_id != new_detail.sale_dc_id THEN old_detail.sale_dc_id as sale_dc_id1,
CASE WHEN old_detail.sale_dc_id != new_detail.sale_dc_id then new_detail.sale_dc_id as sale_dc_id2,
CASE WHEN old_detail.bu_id != new_detail.bu_id THEN old_detail.bu_id as bu_id1,
CASE WHEN old_detail.bu_id != new_detail.bu_id then new_detail.bu_id as bu_id2,
CASE WHEN old_detail.is_pickup_recharge_order != new_detail.is_pickup_recharge_order THEN old_detail.is_pickup_recharge_order as is_pickup_recharge_order1,
CASE WHEN old_detail.is_pickup_recharge_order != new_detail.is_pickup_recharge_order then new_detail.is_pickup_recharge_order as is_pickup_recharge_order2,
CASE WHEN old_detail.supply_id != new_detail.supply_id THEN old_detail.supply_id as supply_id1,
CASE WHEN old_detail.supply_id != new_detail.supply_id then new_detail.supply_id as supply_id2,
CASE WHEN old_detail.category_1st_id != new_detail.category_1st_id THEN old_detail.category_1st_id as category_1st_id1,
CASE WHEN old_detail.category_1st_id != new_detail.category_1st_id then new_detail.category_1st_id as category_1st_id2,
CASE WHEN old_detail.category_2nd_id != new_detail.category_2nd_id THEN old_detail.category_2nd_id as category_2nd_id1,
CASE WHEN old_detail.category_2nd_id != new_detail.category_2nd_id then new_detail.category_2nd_id as category_2nd_id2,
CASE WHEN old_detail.category_3rd_id != new_detail.category_3rd_id THEN old_detail.category_3rd_id as category_3rd_id1,
CASE WHEN old_detail.category_3rd_id != new_detail.category_3rd_id then new_detail.category_3rd_id as category_3rd_id2,
CASE WHEN old_detail.performance_category_1st_id != new_detail.performance_category_1st_id THEN old_detail.performance_category_1st_id as performance_category_1st_id1,
CASE WHEN old_detail.performance_category_1st_id != new_detail.performance_category_1st_id then new_detail.performance_category_1st_id as performance_category_1st_id2,
CASE WHEN old_detail.performance_category_2nd_id != new_detail.performance_category_2nd_id THEN old_detail.performance_category_2nd_id as performance_category_2nd_id1,
CASE WHEN old_detail.performance_category_2nd_id != new_detail.performance_category_2nd_id then new_detail.performance_category_2nd_id as performance_category_2nd_id2,
CASE WHEN old_detail.performance_category_3rd_id != new_detail.performance_category_3rd_id THEN old_detail.performance_category_3rd_id as performance_category_3rd_id1,
CASE WHEN old_detail.performance_category_3rd_id != new_detail.performance_category_3rd_id then new_detail.performance_category_3rd_id as performance_category_3rd_id2,
CASE WHEN old_detail.item_style != new_detail.item_style THEN old_detail.item_style as item_style1,
CASE WHEN old_detail.item_style != new_detail.item_style then new_detail.item_style as item_style2,
CASE WHEN old_detail.store_type != new_detail.store_type THEN old_detail.store_type as store_type1,
CASE WHEN old_detail.store_type != new_detail.store_type then new_detail.store_type as store_type2,
CASE WHEN old_detail.sub_store_type != new_detail.sub_store_type THEN old_detail.sub_store_type as sub_store_type1,
CASE WHEN old_detail.sub_store_type != new_detail.sub_store_type then new_detail.sub_store_type as sub_store_type2,
CASE WHEN old_detail.sp_id != new_detail.sp_id THEN old_detail.sp_id as sp_id1,
CASE WHEN old_detail.sp_id != new_detail.sp_id then new_detail.sp_id as sp_id2,
CASE WHEN old_detail.sp_name != new_detail.sp_name THEN old_detail.sp_name as sp_name1,
CASE WHEN old_detail.sp_name != new_detail.sp_name then new_detail.sp_name as sp_name2,
CASE WHEN old_detail.sp_operator_id != new_detail.sp_operator_id THEN old_detail.sp_operator_id as sp_operator_id1,
CASE WHEN old_detail.sp_operator_id != new_detail.sp_operator_id then new_detail.sp_operator_id as sp_operator_id2,
CASE WHEN old_detail.shop_pool_server_group_id != new_detail.shop_pool_server_group_id THEN old_detail.shop_pool_server_group_id as shop_pool_server_group_id1,
CASE WHEN old_detail.shop_pool_server_group_id != new_detail.shop_pool_server_group_id then new_detail.shop_pool_server_group_id as shop_pool_server_group_id2,
CASE WHEN old_detail.shop_pool_server_user_id != new_detail.shop_pool_server_user_id THEN old_detail.shop_pool_server_user_id as shop_pool_server_user_id1,
CASE WHEN old_detail.shop_pool_server_user_id != new_detail.shop_pool_server_user_id then new_detail.shop_pool_server_user_id as shop_pool_server_user_id2,
CASE WHEN old_detail.shop_group_id != new_detail.shop_group_id THEN old_detail.shop_group_id as shop_group_id1,
CASE WHEN old_detail.shop_group_id != new_detail.shop_group_id then new_detail.shop_group_id as shop_group_id2,
CASE WHEN old_detail.knowledge_package_id != new_detail.knowledge_package_id THEN old_detail.knowledge_package_id as knowledge_package_id1,
CASE WHEN old_detail.knowledge_package_id != new_detail.knowledge_package_id then new_detail.knowledge_package_id as knowledge_package_id2,
CASE WHEN old_detail.result_rule_id != new_detail.result_rule_id THEN old_detail.result_rule_id as result_rule_id1,
CASE WHEN old_detail.result_rule_id != new_detail.result_rule_id then new_detail.result_rule_id as result_rule_id2,
CASE WHEN old_detail.rule_execute_result != new_detail.rule_execute_result THEN old_detail.rule_execute_result as rule_execute_result1,
CASE WHEN old_detail.rule_execute_result != new_detail.rule_execute_result then new_detail.rule_execute_result as rule_execute_result2

FROM new_detail
FULL JOIN old_detail ON new_detail.order_id = old_detail.order_id
WHERE  old_detail.trade_id != new_detail.trade_id
OR old_detail.trade_no != new_detail.trade_no
OR old_detail.order_place_time != new_detail.order_place_time
OR old_detail.shop_id != new_detail.shop_id
OR old_detail.shop_name != new_detail.shop_name
OR old_detail.sale_dc_id != new_detail.sale_dc_id
OR old_detail.bu_id != new_detail.bu_id
OR old_detail.is_pickup_recharge_order != new_detail.is_pickup_recharge_order
OR old_detail.supply_id != new_detail.supply_id
OR old_detail.category_1st_id != new_detail.category_1st_id
OR old_detail.category_2nd_id != new_detail.category_2nd_id
OR old_detail.category_3rd_id != new_detail.category_3rd_id
OR old_detail.performance_category_1st_id != new_detail.performance_category_1st_id
OR old_detail.performance_category_2nd_id != new_detail.performance_category_2nd_id
OR old_detail.performance_category_3rd_id != new_detail.performance_category_3rd_id
OR old_detail.item_style != new_detail.item_style
OR old_detail.store_type != new_detail.store_type
OR old_detail.sub_store_type != new_detail.sub_store_type
OR old_detail.sp_id != new_detail.sp_id
OR old_detail.sp_name != new_detail.sp_name
OR old_detail.sp_operator_id != new_detail.sp_operator_id
OR old_detail.shop_pool_server_group_id != new_detail.shop_pool_server_group_id
OR old_detail.shop_pool_server_user_id != new_detail.shop_pool_server_user_id
OR old_detail.shop_group_id != new_detail.shop_group_id
OR old_detail.knowledge_package_id != new_detail.knowledge_package_id
OR old_detail.result_rule_id != new_detail.result_rule_id
OR old_detail.rule_execute_result != new_detail.rule_execute_result





























