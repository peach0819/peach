sleep 1m
v_date=$1
rule_month=$2
begin_date=$3
end_date=$4
source ../sql_variable.sh $v_date

hive -v -e "
use ytdw;

create table if not exists ytdw.ads_order_biz_frozen_order_channel_d
(
    order_id                              bigint comment '订单id',
    shop_id                               string comment '门店id',
    trade_id                              string comment '交易id',
    trade_no                              string comment '交易编号',
    order_place_time                      string comment '下单时间',
    shop_name                             string comment '门店名称',
    sale_dc_id                            int comment '分销订单标识',
    sale_dc_id_name                       string comment '分销订单标识名称',
    bu_id                                 int comment '业务线 0	海拍客 1	嗨清仓 2	批批平台 6	嗨家',
    bu_id_name                            string comment '业务线名称',
    is_pickup_pay_order                   int comment '是否为提货卡支付订单 1 是 0否',
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
comment '订单冻结渠道重刷数据表'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;

--订单基础信息
WITH order_base as (
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
           item_style_name
    FROM dw_trd_order_d
    WHERE dayid='$v_date'
    AND order_place_time between '$begin_date' AND '$end_date'
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

--门店服务人员信息基础表
shop_pool_server_base as (
    SELECT after_server.order_id as trade_id,
           pool_server.group_id,
           pool_server.user_id
    FROM dwd_order_after_server_d after_server
    INNER JOIN dwd_shop_pool_server_d pool_server ON after_server.shop_pool_server_id = pool_server.id
    WHERE after_server.day_id = '$v_date'
    AND pool_server.day_id = '$v_date'
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
           order_base.trade_id,
           order_base.trade_no,
           order_base.order_place_time,
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
           order_base.performance_category_1st_id,
           order_base.performance_category_1st_name,
           order_base.performance_category_2nd_id,
           order_base.performance_category_2nd_name,
           order_base.performance_category_3rd_id,
           order_base.performance_category_3rd_name,
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
               '32/prod',
                map(
                     'time', '$rule_month',
                     'sale_dc_id', order_base.sale_dc_id,
                     'bu_id', order_base.bu_id,
                     'is_pickup_pay_order', order_base.is_pickup_pay_order,
                     'supply_id', order_base.supply_id,
                     'category_ids',  CONCAT(ifnull(order_base.category_1st_id, 0), ',', ifnull(order_base.category_2nd_id, 0), ',', ifnull(order_base.category_3rd_id, 0)),
                     'pickup_category_ids', CONCAT(ifnull(order_base.performance_category_1st_id,0), ',', ifnull(order_base.performance_category_2nd_id, 0), ',', ifnull(order_base.performance_category_3rd_id, 0)),
                     'item_ab_type', order_base.item_style,
                     'shop_id', order_base.shop_id,
                     'user_ids', shop_pool_server.user_id,
                     'user_features', shop_pool_server.group_id,
                     'store_type', case when shop_base.sub_store_type is null then shop_base.store_type else CONCAT(shop_base.store_type,',',shop_base.sub_store_type) end,
                     'sp_id', sp_order_snapshot.sp_id,
                     'group_ids', shop_group_mapping.group_id
                )
           ) as rule_execute_result
    FROM order_base
    LEFT JOIN shop_base ON order_base.shop_id = shop_base.shop_id
    LEFT JOIN shop_pool_server ON shop_pool_server.shop_id = shop_base.shop_id
    LEFT JOIN shop_group_mapping ON shop_group_mapping.shop_id = shop_base.shop_id
    LEFT JOIN sp_order_snapshot ON order_base.order_id = sp_order_snapshot.order_id
)

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

       get_json_object(rule_execute_result, "$.knowledgePackageId") as knowledge_package_id,
       get_json_object(get_json_object(rule_execute_result, "$.resultData"), "$.ruleId") as result_rule_id,
       case when get_json_object(get_json_object(rule_execute_result, "$.resultData"), "$.no_channel") = 'true'
                then '无归属'
            when get_json_object(get_json_object(rule_execute_result, "$.resultData"), "$.user_id") != null
                then get_json_object(get_json_object(rule_execute_result, "$.resultData"), "$.userId")
            when get_json_object(get_json_object(rule_execute_result, "$.resultData"), "$.user_feature") != null
                then shop_pool_server_temp.user_id
            end as result_user_id
FROM rule_execute_result
LEFT JOIN shop_pool_server_temp ON rule_execute_result.trade_id = shop_pool_server_temp.temp_trade_id
    and get_json_object(get_json_object(rule_execute_result.rule_execute_result, "$.resultData"), "$.user_feature") = cast(shop_pool_server_temp.temp_group_id as string)

" &&

exit 0