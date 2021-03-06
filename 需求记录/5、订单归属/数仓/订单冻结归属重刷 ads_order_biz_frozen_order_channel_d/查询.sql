--订单基础信息
WITH order_base as (
    SELECT *
    FROM ads_order_biz_order_channel_detail_d
    WHERE dayid='$v_date'
    AND substr(order_place_time,0,8)='$v_date'
),

--门店服务人员信息基础表
shop_pool_server_base as (
    SELECT after_server.order_id as trade_id,
           pool_server.group_id,
           pool_server.user_id
    FROM dwd_order_after_server_d after_server
    INNER JOIN dwd_shop_pool_server_d pool_server ON after_server.shop_pool_server_id = pool_server.id
    WHERE after_server.dayid = '$v_date'
    AND pool_server.dayid = '$v_date'
),

--门店服务人员信息合并表
shop_pool_server as (
    SELECT trade_id,
           concat_ws(',' , sort_array(collect_set(cast(group_id as string)))) as group_id,
           concat_ws(',' , collect_set(user_id)) as user_id
    FROM shop_pool_server_base
    group by trade_id
),

--门店服务人员信息临时表
shop_pool_server_temp as (
    SELECT trade_id as temp_trade_id,
           group_id as temp_group_id,
           user_id as temp_user_id
    FROM shop_pool_server_base
),

--规则执行
rule_execute_result as (
    SELECT order_base.order_id,
           order_base.trade_id,
           order_base.trade_no,
           order_base.order_place_time,
           order_base.shop_id,
           order_base.sale_dc_id,
           order_base.sale_dc_id_name,
           order_base.bu_id,
           order_base.bu_id_name,
           order_base.is_pickup_pay_order,
           order_base.is_pickup_recharge_order,
           order_base.supply_id,
           order_base.supply_name,
           order_base.category_1st_id,
           order_base.category_2nd_id,
           order_base.category_3rd_id,
           order_base.category_1st_name,
           order_base.category_2nd_name,
           order_base.category_3rd_name,
           order_base.performance_category_1st_id,
           order_base.performance_category_1st_name,
           order_base.performance_category_2nd_id,
           order_base.performance_category_2nd_name,
           order_base.performance_category_3rd_id,
           order_base.performance_category_3rd_name,
           order_base.item_style,
           order_base.item_style_name,
           order_base.shop_name,
           order_base.store_type,
           order_base.sub_store_type,
           order_base.sp_id,
           order_base.sp_name,
           order_base.sp_operator_id,
           shop_pool_server.group_id     as shop_pool_server_group_id,
           shop_pool_server.user_id      as shop_pool_server_user_id,
           order_base.shop_group_id,
           ytdw.rule_execute(
               '3/prod',
                map(
                     'time', '$rule_month',
                     'sale_dc_id', order_base.sale_dc_id,
                     'bu_id', order_base.bu_id,
                     'is_pickup_pay_order', order_base.is_pickup_recharge_order,
                     'supply_id', order_base.supply_id,
                     'category_ids',  CONCAT(COALESCE(order_base.category_1st_id, 0), ',', COALESCE(order_base.category_2nd_id, 0), ',', COALESCE(order_base.category_3rd_id, 0)),
                     'pickup_category_ids', CONCAT(COALESCE(order_base.performance_category_1st_id,0), ',', COALESCE(order_base.performance_category_2nd_id, 0), ',', COALESCE(order_base.performance_category_3rd_id, 0)),
                     'item_ab_type', order_base.item_style,
                     'shop_id', order_base.shop_id,
                     'user_ids', shop_pool_server.user_id,
                     'user_features', shop_pool_server.group_id,
                     'store_type', case when order_base.sub_store_type is null then order_base.store_type else CONCAT(order_base.store_type,',',order_base.sub_store_type) end,
                     'sp_id', order_base.sp_id,
                     'group_ids', order_base.shop_group_id
                )
           ) as rule_execute_result
    FROM order_base
    LEFT JOIN shop_pool_server ON shop_pool_server.trade_id = order_base.trade_id
)

INSERT OVERWRITE TABLE ads_order_biz_frozen_order_channel_d partition (dayid='$v_date')
SELECT order_id,
       shop_id,
       trade_id,
       trade_no,
       order_place_time,
       shop_name,
       sale_dc_id,
       sale_dc_id_name,
       bu_id,
       bu_id_name,
       is_pickup_pay_order,
       is_pickup_recharge_order,
       supply_id,
       supply_name,
       category_1st_id,
       category_1st_name,
       category_2nd_id,
       category_2nd_name,
       category_3rd_id,
       category_3rd_name,
       performance_category_1st_id,
       performance_category_1st_name,
       performance_category_2nd_id,
       performance_category_2nd_name,
       performance_category_3rd_id,
       performance_category_3rd_name,
       item_style,
       item_style_name,
       store_type,
       sub_store_type,
       sp_id,
       sp_name,
       sp_operator_id,
       shop_pool_server_group_id,
       shop_pool_server_user_id,
       shop_group_id,

       get_json_object(rule_execute_result, '$.knowledgePackageId') as knowledge_package_id,
       get_json_object(get_json_object(rule_execute_result, '$.resultData'), '$.ruleId') as result_rule_id,
       case when get_json_object(get_json_object(rule_execute_result, '$.resultData'), '$.no_channel') = 'true'
                then '无归属'
            when get_json_object(get_json_object(rule_execute_result, '$.resultData'), '$.user_id') != ''
                then get_json_object(get_json_object(rule_execute_result, '$.resultData'), '$.user_id')
            when get_json_object(get_json_object(rule_execute_result, '$.resultData'), '$.user_feature') != ''
                 and get_json_object(get_json_object(rule_execute_result, '$.resultData'), '$.user_feature') = '0'
                then sp_operator_id
            when get_json_object(get_json_object(rule_execute_result, '$.resultData'), '$.user_feature') != ''
                then shop_pool_server_temp.temp_user_id
            end as result_user_id,
       rule_execute_result
FROM rule_execute_result
LEFT JOIN shop_pool_server_temp ON rule_execute_result.trade_id = shop_pool_server_temp.temp_trade_id
    and get_json_object(get_json_object(rule_execute_result.rule_execute_result, '$.resultData'), '$.user_feature') = cast(shop_pool_server_temp.temp_group_id as string)