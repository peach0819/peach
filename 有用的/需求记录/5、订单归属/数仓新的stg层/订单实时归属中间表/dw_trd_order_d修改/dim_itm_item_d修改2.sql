with item_base as (
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

select
    item_base.id as item_id,
    item_base.category_id_first as category_1st_id,
    item_base.category_id_second as category_2nd_id,
    item_base.category_id_third as category_3rd_id,
    item_base.item_style,
    coalesce(pickup_item.pickup_category_id_first,pickup_trade.pickup_category_id_first,item_base.category_id_first) as performance_category_1st_id,
    coalesce(pickup_item.pickup_category_id_second,pickup_trade.pickup_category_id_second,item_base.category_id_second) as performance_category_2nd_id,
    coalesce(pickup_item.pickup_category_id_third,pickup_trade.pickup_category_id_third,item_base.category_id_third) as performance_category_3rd_id
from item_base
left join pickup_item on pickup_item.item_id = item_base.id

--订单维度提货卡相关字段
--2020.11.18加入row_number强制去重,避免出现测试数据的干扰
        left join
    (
        select
            pickup_trade.item_id,
            pickup_trade.pickup_category_id_first,
            pickup_trade.pickup_category_id_second,
            pickup_trade.pickup_category_id_third
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
                            pickup_card_category.pickup_category_id_third as pickup_category_id_third
                        from
                            (
                                select
                                    trade_id,
                                    item_id,
                                    item_name
                                from dwd_order_shop_full_d
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
                                    pickup_category_id_third
                                from dw_trd_pickup_card_category_d where dayid = '$v_date'
                            ) as pickup_card_category on pickup_card_category.trade_id = order_shop.trade_id
                    ) as pickup_trade
            ) as pickup_trade
        where pickup_trade.rn = 1
    ) as pickup_trade on pickup_trade.item_id = item_base.id

;