--商品主表（过滤一些测试商品）
with t1 as (
    select *
    from dwd_item_full_d
    where dayid = '$v_date'
    and substr(create_time,1,8)<='$v_date'
    and id not in ('271791','325516','187049','187325','187329','187330','105006','293796','247515','316732','316721','366633','379050')
    and category_id_first not in ('11551')
)


select t1.id as item_id,
  t1.category_id_first as category_1st_id,
  t1.category_id_second as category_2nd_id,
  t1.category_id_third as category_3rd_id,
  coalesce(pickup_item.pickup_category_id_first,pickup_trade.pickup_category_id_first,t1.category_id_first) as performance_category_1st_id,
  coalesce(pickup_item.pickup_category_id_second,pickup_trade.pickup_category_id_second,t1.category_id_second) as performance_category_2nd_id,
  coalesce(pickup_item.pickup_category_id_third,pickup_trade.pickup_category_id_third,t1.category_id_third) as performance_category_3rd_id,
  t1.item_style

from t1
--商品维度提货卡相关字段
left join
(
  select * from ytdw.dw_itm_pickup_card_d where dayid = '$v_date'
) as pickup_item on pickup_item.item_id = t1.id
--订单维度提货卡相关字段
--2020.11.18加入row_number强制去重,避免出现测试数据的干扰
left join
(
  select
    pickup_trade.item_id,
    pickup_trade.pickup_category_id_first,
    pickup_trade.pickup_category_id_second,
    pickup_trade.pickup_category_id_third,
    pickup_trade.pickup_brand_id
  from
  (
    select
      row_number() over(partition by pickup_trade.item_id order by pickup_trade.item_id) as rn,
      pickup_trade.*
    from
    (
      select
        order_shop.item_id as item_id,
        pickup_card_category.pickup_category_id_first as pickup_category_id_first,
        pickup_card_category.pickup_category_id_second as pickup_category_id_second,
        pickup_card_category.pickup_category_id_third as pickup_category_id_third,
        pickup_card_category.pickup_brand_id as pickup_brand_id
      from
      (
        select
          trade_id,
          item_id,
          item_name
        from ytdw.dwd_order_shop_full_d
        where dayid = '$v_date'
          and is_deleted=0
          and item_dc_id=0
      ) as order_shop
      join
      (
        select
          trade_id,
          pickup_category_id_first,
          pickup_category_id_second,
          pickup_category_id_third,
          pickup_brand_id,
        from ytdw.dw_trd_pickup_card_category_d where dayid = '$v_date'
      ) as pickup_card_category
      on pickup_card_category.trade_id = order_shop.trade_id
    ) as pickup_trade
  ) as pickup_trade
  where pickup_trade.rn = 1
) pickup_trade on pickup_trade.item_id = t1.id
;