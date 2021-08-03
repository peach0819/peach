create table if not exists ytdw.dw_itm_pickup_card_d
(
  item_id                     bigint  comment '商品ID',
  pickup_brand_id             bigint  comment '提货卡品牌ID',
  pickup_brand_name           string  comment '提货卡品牌名称',
  pickup_category_id_first    bigint  comment '提货卡一级类目ID',
  pickup_category_name_first  string  comment '提货卡一级类目名称',
  pickup_category_id_second   bigint  comment '提货卡二级类目ID',
  pickup_category_name_second string  comment '提货卡二级类目名称',
  pickup_category_id_third    bigint  comment '提货卡三级类目ID',
  pickup_category_name_third  string  comment '提货卡三级类目名称'
)
comment '商品提货卡对应关系'
partitioned by (dayid string)
stored as orc;

insert overwrite table ytdw.dw_itm_pickup_card_d partition (dayid = '$v_date')
-- t_hi_card_template和t_gift_coupon_conf  通过t_gift_hicard这张表来联系起来
select
  item_pickup.item_id as item_id,
  item_pickup.pickup_brand_id as pickup_brand_id,
  brand.name as pickup_brand_name,
  item_pickup.first_pickup_category_id as pickup_category_id_first,
  category_first.name as pickup_category_name_first,
  item_pickup.second_pickup_category_id as pickup_category_id_second,
  category_second.name as pickup_category_name_second,
  item_pickup.third_pickup_category_id as pickup_category_id_third,
  category_third.name as pickup_category_name_third
from
(
  select
    hi_card_template.id as hi_card_template_id,
    hi_card_template.hi_card_type as hi_card_type,
    gift_coupon_conf.id as gift_coupon_conf_id,
    gift_coupon_conf.item_id as item_id,
    hi_card_template.pickup_brand_id as pickup_brand_id,
    hi_card_template.first_pickup_category_id as first_pickup_category_id,
    hi_card_template.second_pickup_category_id as second_pickup_category_id,
    hi_card_template.third_pickup_category_id as third_pickup_category_id
  from
  (
    select
      id, gift_coupon_conf_id, hi_card_id
    from ytdw.dwd_gift_hicard_d
    where dayid = '$v_date'
      and is_deleted = 0
  ) as gift_hicard
  left join
  ( --提货卡对应的品牌、类目信息
    select
      id,
      hi_card_type,
      pickup_brand_id,
      get_json_object(hi_card_temp_ext,'$.firstPickupCategoryId') as first_pickup_category_id,
      get_json_object(hi_card_temp_ext,'$.secondaryPickupCategoryId') as second_pickup_category_id,
      get_json_object(hi_card_temp_ext,'$.tertiaryPickupCategoryId') as third_pickup_category_id
    from ytdw.dwd_hi_card_template_d
    where dayid = '$v_date'
      and is_deleted = 0
  ) as hi_card_template
  on gift_hicard.hi_card_id = hi_card_template.id
  left join
  (
    select
      id, item_id
    from ytdw.dwd_gift_coupon_conf_d
    where dayid = '$v_date'
      and is_deleted = 0
  ) as gift_coupon_conf
  on gift_hicard.gift_coupon_conf_id = gift_coupon_conf.id
  where hi_card_template.hi_card_type = 1 -- 取提货卡
) as item_pickup
--拿类目名
left join
(
    select id, name from ytdw.dw_category_info_d where dayid = '$v_date'
) as category_first
on category_first.id = item_pickup.first_pickup_category_id
left join
(
    select id, name from ytdw.dw_category_info_d where dayid = '$v_date'
) as category_second
on category_second.id = item_pickup.second_pickup_category_id
left join
(
    select id, name from ytdw.dw_category_info_d where dayid = '$v_date'
) as category_third
on category_third.id = item_pickup.third_pickup_category_id
--拿品牌名
left join
(
    select id, name from ytdw.dwd_brand_d where dayid = '$v_date'
) as brand
on brand.id = item_pickup.pickup_brand_id;