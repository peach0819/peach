set hive.execution.engine=mr;
use ytdw;

create table if not exists ytdw.stg_order_channel_detail_d
(
    order_id                              bigint comment '订单id',
    trade_id                              string comment '交易id',
    trade_no                              string comment '交易编号',
    order_place_time                      string comment '下单时间',
    shop_id                               string comment '门店id',
    shop_name                             string comment '门店名称',
    sale_dc_id                            int comment '分销订单标识',
    bu_id                                 int comment '业务线 0	海拍客 1	嗨清仓 2	批批平台 6	嗨家',
    is_pickup_recharge_order              int comment '是否为充值提货hi卡订单 1 是 0否',
    supply_id                             string comment '供应商id',
    category_1st_id                       bigint comment '一级类目ID',
    category_2nd_id                       bigint comment '二级类目ID',
    category_3rd_id                       bigint comment '三级类目ID',
    performance_category_1st_id           bigint comment '业绩一级类目ID',
    performance_category_2nd_id           bigint comment '业绩二级类目ID',
    performance_category_3rd_id           bigint comment '业绩三级类目ID',
    item_style                            tinyint comment '商品标签类型默认是0：A类1：B类',
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
row format delimited fields terminated by '\001'
stored as orc;


------------------------订单维度宽表拆分
with order_shop as (
    SELECT order_id,
           trade_id,
           from_unixtime(unix_timestamp(create_time),'yyyyMMddHHmmss') as create_time,
           shop_id,
           nvl(ytdw.getValueFromKVString(attribute,'saleDcId'),-1) as sale_dc_id,
           bu_id,
           supply_id,
           item_id
    from ods_pt_order_shop_d
    where dayid='$v_date'
    and regexp_extract(attribute,'(off:)([0-9]*)(\;?)',2) <> '1' --原因你懂的
    and order_id<>36133857 --脏数据，订单金额过大
    and substr(create_time,1,8) <='$v_date'
    and is_deleted=0
),

trade_shop as (
    select trade_id,
           trade_no
    from ods_pt_trade_shop_d
    where dayid='$v_date'
),

--商品主表（过滤一些测试商品）
item_base as (
    select *
    from ods_t_item_d
    where dayid = '$v_date'
    and substr(create_time,1,8)<='$v_date'
    and id not in ('271791','325516','187049','187325','187329','187330','105006','293796','247515','316732','316721','366633','379050')
    and category_id_first not in ('11551')
),

--商品维度提货卡相关字段
pickup_item as (
    select gift_coupon_conf.item_id                   as item_id,
           hi_card_template.first_pickup_category_id  as pickup_category_id_first,
           hi_card_template.second_pickup_category_id as pickup_category_id_second,
           hi_card_template.third_pickup_category_id  as pickup_category_id_third
    from (
        select id,
               gift_coupon_conf_id,
               hi_card_id
        from ods_t_gift_hicard_d
        where dayid = '$v_date'
        and is_deleted = 0
    ) gift_hicard
    left join (
        select id,
               hi_card_type,
               get_json_object(hi_card_temp_ext, '$.firstPickupCategoryId')     as first_pickup_category_id,
               get_json_object(hi_card_temp_ext, '$.secondaryPickupCategoryId') as second_pickup_category_id,
               get_json_object(hi_card_temp_ext, '$.tertiaryPickupCategoryId')  as third_pickup_category_id
        from ods_t_hi_card_template_d
        where dayid = '$v_date'
        and is_deleted = 0
    ) hi_card_template on gift_hicard.hi_card_id = hi_card_template.id
    left join (
        select id,
               item_id
        from ods_t_gift_coupon_conf_d
        where dayid = '$v_date'
        and is_deleted = 0
    ) as gift_coupon_conf on gift_hicard.gift_coupon_conf_id = gift_coupon_conf.id
    where hi_card_template.hi_card_type = 1 -- 取提货卡
),

--商品维度
item as (
    select item_base.id                                                                 as item_id,
           item_base.category_id_first                                                  as category_1st_id,
           item_base.category_id_second                                                 as category_2nd_id,
           item_base.category_id_third                                                  as category_3rd_id,
           coalesce(pickup_item.pickup_category_id_first,item_base.category_id_first)   as performance_category_1st_id,
           coalesce(pickup_item.pickup_category_id_second,item_base.category_id_second) as performance_category_2nd_id,
           coalesce(pickup_item.pickup_category_id_third,item_base.category_id_third)   as performance_category_3rd_id,
           item_base.item_style
    from item_base
    left join pickup_item on pickup_item.item_id = item_base.id
),

--hi卡
hi_pickup as (
    SELECT trade_id,
           hi_card_type
    FROM (
        select serial.out_biz_id as trade_id,
               template.hi_card_type,
               row_number() over(partition by serial.out_biz_id order by serial.card_fund_serial_id desc) as rn --最近的模板id
        from (
            select out_biz_id,
                   template_card_id,
                   card_fund_serial_id
            from ods_t_card_fund_serial_details_d
            where dayid='$v_date'
        ) serial
        inner join (
            select id,
                   hi_card_type
            from ods_t_hi_card_template_d
            where dayid ='$v_date'
              and is_deleted <> 99
        ) template on serial.template_card_id=template.id
    ) temp
    WHERE rn = 1
),

--原dw_trd_order_d解析
order_detail as (
    select order_shop.order_id,
           order_shop.trade_id,            -- 交易ID
           trade_shop.trade_no,
           order_shop.create_time as order_place_time,  --下单时间
           order_shop.shop_id,            -- 店铺ID
           order_shop.sale_dc_id,
           order_shop.bu_id,
           if(hi_pickup.hi_card_type = 1,1,0) as is_pickup_recharge_order,
           order_shop.supply_id,               -- 供应商id
           item.category_1st_id,
           item.category_2nd_id,
           item.category_3rd_id,
           item.performance_category_1st_id,
           item.performance_category_2nd_id,
           item.performance_category_3rd_id,
           item.item_style
    from order_shop
    left join trade_shop ON order_shop.trade_id = trade_shop.trade_id
    left join item on order_shop.item_id = item.item_id
    left join hi_pickup on hi_pickup.trade_id = order_shop.trade_id
),
--------------------------------订单宽表拆解结束

--订单基础信息
order_base as (
    SELECT order_id,
           trade_id,
           trade_no,
           order_place_time,
           shop_id,
           case when sale_dc_id = -1 then 0 else sale_dc_id end as sale_dc_id,
           bu_id,
           is_pickup_recharge_order,
           supply_id,
           category_1st_id,
           category_2nd_id,
           category_3rd_id,
           performance_category_1st_id,
           performance_category_2nd_id,
           performance_category_3rd_id,
           item_style
    FROM order_detail
),

--门店信息
shop_base as(
    select shop_id,
           shop_name,
           store_type,
           sub_store_type
    from ods_t_shop_d
    where dayid='$v_date'
    and shop_status in (1, 2, 3, 4, 5)
    and inuse=1
    and provincearea_id is not null
    and provincearea_id!=''
    and dc_id=0
),

--门店服务人员信息合并表
shop_pool_server as (
    SELECT shop_id,
           concat_ws(',' , sort_array(collect_set(cast(group_id as string)))) as group_id,
           concat_ws(',' , collect_set(user_id)) as user_id
    FROM ods_t_shop_pool_server_d
    WHERE dayid='$v_date'
    AND is_deleted = 0
    AND is_enabled = 1
    group by shop_id
),

--门店分组关系
shop_group_mapping as (
    select shop_id,
           concat_ws(',' , sort_array(collect_set(cast(group_id as string)))) as group_id
    from ods_t_shop_group_mapping_d
    where dayid = '$v_date'
    and dc_id = 0
    AND is_deleted = 0
    group by shop_id
),

--服务商订单快照信息
sp_order_snapshot as (
    SELECT order_id,
           sp_id,
           sp_name,
           operator_id
    FROM ods_t_sp_order_snapshot_d
    WHERE dayid='$v_date'
    AND is_deleted = 0
)

INSERT OVERWRITE TABLE stg_order_channel_detail_d partition (dayid='$v_date')
SELECT order_base.order_id,
       order_base.trade_id,
       order_base.trade_no,
       order_base.order_place_time,
       order_base.shop_id,
       shop_base.shop_name,
       order_base.sale_dc_id,
       order_base.bu_id,
       order_base.is_pickup_recharge_order,
       order_base.supply_id,
       order_base.category_1st_id,
       order_base.category_2nd_id,
       order_base.category_3rd_id,
       order_base.performance_category_1st_id,
       order_base.performance_category_2nd_id,
       order_base.performance_category_3rd_id,
       order_base.item_style,
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