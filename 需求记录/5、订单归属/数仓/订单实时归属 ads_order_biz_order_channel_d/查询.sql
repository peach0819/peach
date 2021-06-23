

--订单基础信息
WITH order_base as (
    SELECT order_id,
           shop_id,
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
           item_style,
           item_style_name
    FROM dw_trd_order_d
    WHERE dayid='$v_date'
),

--门店基础信息
shop_base as (
    SELECT shop_id,
           shop_name,
           store_type,
           sub_store_type
    FROM dwd_shop_d
    WHERE dayid='$v_date'
),

--门店服务人员信息
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
),

--规则执行
rule_execute_result as (
    SELECT order_base.order_id,
           order_base.shop_id,
           order_base.sale_dc_id,
           order_base.sale_dc_id_name,
           order_base.bu_id,
           order_base.bu_id_name,
           order_base.is_pickup_pay_order,
           order_base.supply_id,
           order_base.supply_name,
           order_base.category_1st_id,
           order_base.category_2nd_id,
           order_base.category_3rd_id,
           order_base.category_1st_name,
           order_base.category_2nd_name,
           order_base.category_3rd_name,
           order_base.item_style,
           order_base.item_style_name,
           shop_base.shop_name,
           shop_base.store_type,
           shop_base.sub_store_type,
           sp_order_snapshot.sp_id,
           sp_order_snapshot.sp_name,
           sp_order_snapshot.operator_id as sp_operator_id,
           shop_pool_server.group_id     as shop_pool_server_group_id,
           shop_pool_server.user_id      as shop_pool_server_user_id,
           shop_group_mapping.group_id   as shop_group_id,
           ytdw.rule_execute(
               '待填充知识包id/prod',
                map(
                     '规则月份', from_unixtime(unix_timestamp()),
                     '分销渠道', order_base.sale_dc_id,
                     'bu_id', order_base.bu_id,
                     '是否提货卡充值订单', order_base.is_pickup_pay_order,
                     '供应商名称', order_base.supply_id,
                     '商品一级类目', order_base.category_1st_id,
                     '商品二级类目', order_base.category_2nd_id,
                     '商品三级类目', order_base.category_3rd_id,
                     '商品AB类型', order_base.item_style,
                     '门店名称', order_base.shop_id,
                     '门店服务人员', shop_pool_server.user_id,
                     '门店服务人员职能', shop_pool_server.group_id,
                     '门店类型', shop_base.store_type,
                     '门店子类型', shop_base.sub_store_type,
                     '服务商', sp_order_snapshot.sp_id,
                     '门店分组', shop_group_mapping.group_id
                )
           ) as rule_execute_result
    FROM order_base
    LEFT JOIN shop_base ON order_base.shop_id = shop_base.shop_id
    LEFT JOIN shop_pool_server ON shop_pool_server.shop_id = shop_base.shop_id
    LEFT JOIN shop_group_mapping ON shop_group_mapping.shop_id = shop_base.shop_id
    LEFT JOIN sp_order_snapshot ON order_base.order_id = sp_order_snapshot.order_id
)

INSERT OVERWRITE TABLE ads_order_biz_order_channel_d partition (dayid='$v_date')
SELECT order_id,
       shop_id,
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

       get_json_object(rule_execute_result, "$.knowledgePackageId") as knowledge_package_id,
       get_json_object(result_data, "$.ruleId") as result_rule_id,
       get_json_object(result_data, "$.userId") as result_user_id
FROM rule_execute_result
LATERAL VIEW explode(split(regexp_replace(regexp_replace(get_json_object(rule_execute_result, "$.resultData"), '\\[|\\]',''),  '\}\,','\}\;'),'\;')) temp as result_data
;