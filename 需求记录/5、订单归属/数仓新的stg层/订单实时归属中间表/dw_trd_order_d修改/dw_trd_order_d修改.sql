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

--商品维度
item as (
    select item_id,
           category_1st_id,
           category_2nd_id,
           category_3rd_id,
           performance_category_1st_id,
           performance_category_2nd_id,
           performance_category_3rd_id,
           item_style
    from dim_itm_item_d
    where dayid = '$v_date'
),

--hi卡
hi_pickup as (
    select trade_id,
           hi_card_type
    from dim_trd_hi_pickup_card_category_d
    where dayid='$v_date'
)

select order_shop.order_id,
       order_shop.trade_id,            -- 交易ID
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
left join item on order_shop.item_id = item.item_id
left join hi_pickup on hi_pickup.trade_id = order_shop.trade_id
;
