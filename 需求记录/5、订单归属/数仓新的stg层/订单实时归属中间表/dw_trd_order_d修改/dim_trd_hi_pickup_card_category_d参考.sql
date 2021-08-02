select trade_id,
       hi_card_type,
       pickup_category_1st_id ,
	   pickup_category_1st_name,
	   pickup_category_2nd_id ,
	   pickup_category_2nd_name,
	   pickup_category_3rd_id ,
	   pickup_category_3rd_name,
       pickup_brand_id,
       pickup_brand_name
from
(
select out_biz_id as trade_id,
   hi_card_type,
   category_1st_id   as  pickup_category_1st_id ,
   category_1st_name as  pickup_category_1st_name,
   category_2nd_id   as  pickup_category_2nd_id ,
   category_2nd_name as  pickup_category_2nd_name,
   category_3rd_id   as  pickup_category_3rd_id ,
   category_3rd_name as pickup_category_3rd_name,
  pickup_brand_id,
  brand.name as pickup_brand_name,
  row_number()over(partition by out_biz_id order by card_fund_serial_id desc) as rn --最近的模板id
from
(select trade_id
from dwd_trade_shop_d
where dayid='$v_date' and is_deleted=0 and trade_type=1  --卡票券充值
)trade
join
(select out_biz_id,template_card_id,card_fund_serial_id
from dwd_card_fund_serial_details_d
where dayid='$v_date'
) serial on serial.out_biz_id=trade.trade_id
join
(
select
	id,
	pickup_brand_id,
	hi_card_type,
	coalesce(tertiarypickupcategoryid,secondarypickupcategoryid,firstpickupcategoryid) as conn_category_3rd_id
 from
 (
select id,pickup_brand_id,hi_card_type,
 get_json_object(hi_card_temp_ext,'$.firstPickupCategoryId') as firstpickupcategoryid,
 get_json_object(hi_card_temp_ext,'$.secondaryPickupCategoryId') as secondarypickupcategoryid,
 get_json_object(hi_card_temp_ext,'$.tertiaryPickupCategoryId') as tertiarypickupcategoryid
from dwd_hi_card_template_d
where dayid ='$v_date'
--and hi_card_type=1 --0 hi卡 1 提货卡
) template_mid
) template on serial.template_card_id=template.id
left join
(
select
	category_1st_id   ,
	category_1st_name ,
	category_2nd_id   ,
	category_2nd_name ,
	category_3rd_id   ,
	category_3rd_name
from dim_itm_category_d
where dayid = '$v_date'
group by
	category_1st_id   ,
	category_1st_name ,
	category_2nd_id   ,
	category_2nd_name ,
	category_3rd_id   ,
	category_3rd_name

) category
on category.category_3rd_id = template.conn_category_3rd_id
left join
(select id,name from dwd_brand_d where dayid = '$v_date') brand on brand.id = template.pickup_brand_id
) pickup_card
where rn=1