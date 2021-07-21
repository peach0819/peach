use ytdw;

create table if not exists ytdw.ads_order_biz_order_channel_d
(
    order_id                              bigint comment '订单id',
    trade_id                              string comment '交易id',
    trade_no                              string comment '交易编号',
    order_place_time                      string comment '下单时间',
    shop_id                               string comment '门店id',
    shop_name                             string comment '门店名称',
    sale_dc_id                            int comment '分销订单标识',
    sale_dc_id_name                       string comment '分销订单标识名称',
    bu_id                                 int comment '业务线 0	海拍客 1	嗨清仓 2	批批平台 6	嗨家',
    bu_id_name                            string comment '业务线名称',
    is_pickup_pay_order                   int comment '是否为提货卡支付订单 1 是 0否',
    is_pickup_recharge_order              int comment '是否为充值提货hi卡订单 1 是 0否',
    supply_id                             string comment '供应商id',
    supply_name                           string comment '供应商名称',
    category_1st_id                       bigint comment '一级类目ID',
    category_1st_name                     string comment '一级类目名称',
    category_2nd_id                       bigint comment '二级类目ID',
    category_2nd_name                     string comment '二级类目名称',
    category_3rd_id                       bigint comment '三级类目ID',
    category_3rd_name                     string comment '三级类目名称',
    performance_category_1st_id           bigint comment '业绩一级类目ID',
    performance_category_1st_name         string comment '业绩一级类目名称',
    performance_category_2nd_id           bigint comment '业绩二级类目ID',
    performance_category_2nd_name         string comment '业绩二级类目名称',
    performance_category_3rd_id           bigint comment '业绩三级类目ID',
    performance_category_3rd_name         string comment '业绩三级类目名称',
    item_style                            tinyint comment '商品标签类型默认是0：A类1：B类',
    item_style_name                       string comment '商品标签类型默认是0：A类1：B类',
    store_type                            tinyint comment '门店类型',
    sub_store_type                        int comment '门店子类型',
    sp_id                                 bigint comment '服务商id',
    sp_name                               string comment '服务商名称',
    sp_operator_id                        string comment '服务商经理id',
    shop_pool_server_group_id             string comment '门店服务人员职能',
    shop_pool_server_user_id              string comment '门店服务人员',
    shop_group_id                         string comment '分店分组',
    knowledge_package_id                  string comment '规则执行知识包id',
    result_rule_id                        string comment '执行规则id',
    result_user_id                        string comment '执行规则结果，订单归属用户id',
    rule_execute_result                   string comment '规则执行结果'
)
comment '订单渠道数据表'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;

set hive.execution.engine=mr;

--门店服务人员信息临时表
WITH shop_pool_server_temp as (
    SELECT shop_id as temp_shop_id,
           group_id as temp_group_id,
           user_id as temp_user_id
    FROM dwd_shop_pool_server_d
    WHERE dayid='$v_date'
    AND is_deleted = 0
    AND is_enabled = 1
),

--规则执行
rule_execute_result as (
    SELECT order_id,
           trade_id,
           trade_no,
           order_place_time,
           shop_id,
           sale_dc_id,
           sale_dc_id_name,
           bu_id,
           bu_id_name,
           is_pickup_pay_order,
           is_pickup_recharge_order,
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
           ytdw.rule_execute(
               '3/prod',
                map(
                     'time', from_unixtime(unix_timestamp()),
                     'sale_dc_id', sale_dc_id,
                     'bu_id', bu_id,
                     'is_pickup_pay_order', case when is_pickup_recharge_order = 1 then 'true' else 'false' end,
                     'supply_id', supply_id,
                     'category_ids',  CONCAT(COALESCE(category_1st_id, 0), ',', COALESCE(category_2nd_id, 0), ',', COALESCE(category_3rd_id, 0)),
                     'pickup_category_ids', CONCAT(COALESCE(performance_category_1st_id,0), ',', COALESCE(performance_category_2nd_id, 0), ',', COALESCE(performance_category_3rd_id, 0)),
                     'item_ab_type', item_style,
                     'shop_id', shop_id,
                     'user_ids', shop_pool_server_user_id,
                     'user_features', shop_pool_server_group_id,
                     'store_type', case when sub_store_type is null then store_type else CONCAT(store_type,',',sub_store_type) end,
                     'sp_id', sp_id,
                     'group_ids', shop_group_id
                )
           ) as rule_execute_result
    FROM ads_order_biz_order_channel_detail_d
    WHERE dayid = '$v_date'
)

INSERT OVERWRITE TABLE ads_order_biz_order_channel_d partition (dayid='$v_date')
SELECT order_id,
       trade_id,
       trade_no,
       order_place_time,
       shop_id,
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
LEFT JOIN shop_pool_server_temp ON rule_execute_result.shop_id = shop_pool_server_temp.temp_shop_id
    and get_json_object(get_json_object(rule_execute_result.rule_execute_result, '$.resultData'), '$.user_feature') = cast(shop_pool_server_temp.temp_group_id as string)
;