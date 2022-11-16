v_date=$1

source ../sql_variable.sh $v_date

apache-spark-sql -e "
use ytdw;

create table if not exists ytdw.ads_order_biz_order_channel_detail_d
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
    shop_group_id                         string comment '分店分组'
)
comment '订单渠道数据中间表'
partitioned by (dayid string)
stored as orc;

--订单基础信息
with order_base as (
    SELECT order_id,
           trade_id,
           trade_no,
           order_place_time,
           shop_id,
           case when sale_dc_id = -1 then 0 else sale_dc_id end as sale_dc_id,
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
           item_style_name
    FROM dw_trd_order_d
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
    AND is_enabled = 1
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

INSERT OVERWRITE TABLE ads_order_biz_order_channel_detail_d partition (dayid='$v_date')
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
       null as shop_group_id
FROM order_base
LEFT JOIN shop_base ON order_base.shop_id = shop_base.shop_id
LEFT JOIN shop_pool_server ON shop_pool_server.shop_id = shop_base.shop_id
LEFT JOIN sp_order_snapshot ON order_base.order_id = sp_order_snapshot.order_id
;
"