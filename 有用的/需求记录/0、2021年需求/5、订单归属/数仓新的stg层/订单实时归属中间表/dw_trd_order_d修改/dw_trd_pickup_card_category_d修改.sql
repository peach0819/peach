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