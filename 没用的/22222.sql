INSERT OVERWRITE TABLE ads_order_biz_frozen_order_channel_d partition (dayid='$v_date')
SELECT order_id,
       trade_id,
       trade_no,
       order_place_time,
       shop_id,
       trade_id,
       sale_dc_id,
       sale_dc_id_name,
       bu_id,
       bu_id_name,
       is_pickup_pay_order,
       supply_id,
       supply_name,
       category_1st_id,
       category_2nd_id,
       category_3rd_id,
       category_1st_name,
       category_2nd_name,
       category_3rd_name,
       performance_category_1st_id,
       performance_category_1st_name,
       performance_category_2nd_id,
       performance_category_2nd_name,
       performance_category_3rd_id,
       performance_category_3rd_name,
       item_style,
       item_style_name,
       shop_name,
       store_type,
       sub_store_type,
       sp_id,
       sp_name,
       sp_operator_id,
       shop_pool_server_group_id,
       shop_pool_server_user_id,
       shop_group_id,
       rule_execute_result,

       get_json_object(rule_execute_result, '$.knowledgePackageId') as knowledge_package_id,
       get_json_object(get_json_object(rule_execute_result, '$.resultData'), '$.ruleId') as result_rule_id,
       case when get_json_object(get_json_object(rule_execute_result, '$.resultData'), '$.no_channel') = 'true'
                then '无归属'
            when get_json_object(get_json_object(rule_execute_result, '$.resultData'), '$.user_id') != null
                then get_json_object(get_json_object(rule_execute_result, '$.resultData'), '$.userId')
            when get_json_object(get_json_object(rule_execute_result, '$.resultData'), '$.user_feature') != null
                then shop_pool_server_temp.temp_user_id
            end as result_user_id
FROM rule_execute_result
LEFT JOIN shop_pool_server_temp ON rule_execute_result.trade_id = shop_pool_server_temp.temp_trade_id
    and get_json_object(get_json_object(rule_execute_result.rule_execute_result, '$.resultData'), '$.user_feature') = cast(shop_pool_server_temp.temp_group_id as string)
