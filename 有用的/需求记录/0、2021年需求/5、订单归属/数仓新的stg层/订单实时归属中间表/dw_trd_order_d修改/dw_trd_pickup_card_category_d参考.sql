insert overwrite table dw_trd_pickup_card_category_d partition (dayid='$v_date')
select trade_id,
       pickup_category_id_first,
       pickup_category_id_first_name,
       pickup_category_id_second,
       pickup_category_id_second_name,
       pickup_category_id_third,
       pickup_category_id_third_name,
       pickup_brand_id,
       pickup_brand_name
from
(
select out_biz_id as trade_id,
  firstpickupcategoryid as pickup_category_id_first,
  category_first.name as pickup_category_id_first_name,
  secondarypickupcategoryid as pickup_category_id_second,
  category_second.name as pickup_category_id_second_name,
  tertiarypickupcategoryid as pickup_category_id_third,
  category_third.name as pickup_category_id_third_name,
  pickup_brand_id,
  brand.name as pickup_brand_name,
  row_number()over(partition by out_biz_id order by out_biz_id) as rn
from
(select trade_id
from dwd_trade_shop_d
where dayid='$v_date' and is_deleted=0 and trade_type=1  --卡票券充值
)trade
join
(select out_biz_id,template_card_id
from dwd_card_fund_serial_details_d
where dayid='$v_date'
) serial on serial.out_biz_id=trade.trade_id
join
(
select id,pickup_brand_id,
 get_json_object(hi_card_temp_ext,'$.firstPickupCategoryId') as firstpickupcategoryid,
 get_json_object(hi_card_temp_ext,'$.secondaryPickupCategoryId') as secondarypickupcategoryid,
 get_json_object(hi_card_temp_ext,'$.tertiaryPickupCategoryId') as tertiarypickupcategoryid
from dwd_hi_card_template_d
where dayid ='$v_date'
and hi_card_type=1 --0 hi卡 1 提货卡
) template on serial.template_card_id=template.id
left join
(select id,name from dw_category_info_d where dayid = '$v_date') category_first
on category_first.id = template.firstpickupcategoryid
left join
(select id,name from dw_category_info_d where dayid = '$v_date') category_second
on category_second.id = template.secondarypickupcategoryid
left join
(select id,name from dw_category_info_d where dayid = '$v_date') category_third
on category_third.id = template.tertiarypickupcategoryid
left join
(select id,name from dwd_brand_d where dayid = '$v_date') brand on brand.id = template.pickup_brand_id
) pickup_card
where rn=1