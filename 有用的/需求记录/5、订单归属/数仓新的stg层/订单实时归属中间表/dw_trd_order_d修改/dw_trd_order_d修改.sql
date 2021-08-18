--订单维度
with order_shop as (
    SELECT order_id,
           trade_id,
           from_unixtime(unix_timestamp(create_time),'yyyyMMddHHmmss') as create_time,,
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
    having rn = 1
)

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
;
