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
                pickup_item.pickup_category_id_first as pickup_category_id_first,
                pickup_item.pickup_category_id_second as pickup_category_id_second,
                pickup_item.pickup_category_id_third as pickup_category_id_third,
                item_base.item_style
         from item_base
                  left join pickup_item on pickup_item.item_id = item_base.id
     ),

     pickup_trade as (
         select trade_id,
                pickup_category_id_first,
                pickup_category_id_second,
                pickup_category_id_third
         from
             (
                 select out_biz_id as trade_id,
                        firstpickupcategoryid as pickup_category_id_first,
                        secondarypickupcategoryid as pickup_category_id_second,
                        tertiarypickupcategoryid as pickup_category_id_third,
                        row_number() over (partition by out_biz_id order by out_biz_id) as rn
                 from (
                          select trade_id
                          from dwd_trade_shop_d
                          where dayid='$v_date' and is_deleted=0 and trade_type=1  --卡票券充值
                      ) trade
                          inner join (
                     select out_biz_id,template_card_id
                     from dwd_card_fund_serial_details_d
                     where dayid='$v_date'
                 ) serial on serial.out_biz_id=trade.trade_id
                          inner join (
                     select id,
                            get_json_object(hi_card_temp_ext,'$.firstPickupCategoryId') as firstpickupcategoryid,
                            get_json_object(hi_card_temp_ext,'$.secondaryPickupCategoryId') as secondarypickupcategoryid,
                            get_json_object(hi_card_temp_ext,'$.tertiaryPickupCategoryId') as tertiarypickupcategoryid
                     from dwd_hi_card_template_d
                     where dayid ='$v_date'
                       and hi_card_type=1 --0 hi卡 1 提货卡
                 ) template on serial.template_card_id=template.id
             ) pickup_card
         where rn=1
     ),

     new_order as (
         select order_shop.order_id,
                order_shop.trade_id,            -- 交易ID
                coalesce(item.pickup_category_id_first, pickup_trade.pickup_category_id_first, item.category_1st_id) as performance_category_1st_id,
                coalesce(item.pickup_category_id_second, pickup_trade.pickup_category_id_second, item.category_2nd_id) as performance_category_2nd_id,
                coalesce(item.pickup_category_id_third, pickup_trade.pickup_category_id_third, item.category_3rd_id) as performance_category_3rd_id
         from order_shop
                  left join item on order_shop.item_id = item.item_id
                  left join pickup_trade ON pickup_trade.trade_id = order_shop.trade_id
     ),

     old_order as (
         SELECT            order_id, trade_id,
                           performance_category_1st_id,
                           performance_category_2nd_id,
                           performance_category_3rd_id
         FROM dw_trd_order_d WHERE dayid = '$v_date'
     )

SELECT new_order.order_id,
       new_order.trade_id,
       new_order.performance_category_1st_id as new_performance_category_1st_id,
       old_order.performance_category_1st_id as old_performance_category_1st_id,
       new_order.performance_category_2nd_id as new_performance_category_2nd_id,
       old_order.performance_category_2nd_id as old_performance_category_2nd_id,
       new_order.performance_category_3rd_id as new_performance_category_3rd_id,
       old_order.performance_category_3rd_id as old_performance_category_3rd_id

FROM new_order
         INNER JOIN old_order ON new_order.order_id = old_order.order_id
WHERE new_order.performance_category_1st_id != old_order.performance_category_1st_id
   OR new_order.performance_category_2nd_id != old_order.performance_category_2nd_id
   OR new_order.performance_category_3rd_id != old_order.performance_category_3rd_id
