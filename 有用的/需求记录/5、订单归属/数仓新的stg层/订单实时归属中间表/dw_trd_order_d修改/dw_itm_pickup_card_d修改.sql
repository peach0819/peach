select gift_coupon_conf.item_id                   as item_id,
       hi_card_template.first_pickup_category_id  as pickup_category_id_first,
       hi_card_template.second_pickup_category_id as pickup_category_id_second,
       hi_card_template.third_pickup_category_id  as pickup_category_id_third
from (
    select id,
           gift_coupon_conf_id,
           hi_card_id
    from ytdw.dwd_gift_hicard_d
    where dayid = '$v_date'
    and is_deleted = 0
) gift_hicard
left join (
    select id,
           hi_card_type,
           get_json_object(hi_card_temp_ext, '$.firstPickupCategoryId')     as first_pickup_category_id,
           get_json_object(hi_card_temp_ext, '$.secondaryPickupCategoryId') as second_pickup_category_id,
           get_json_object(hi_card_temp_ext, '$.tertiaryPickupCategoryId')  as third_pickup_category_id
    from ytdw.dwd_hi_card_template_d
    where dayid = '$v_date'
    and is_deleted = 0
) hi_card_template on gift_hicard.hi_card_id = hi_card_template.id
left join (
    select id,
           item_id
    from ytdw.dwd_gift_coupon_conf_d
    where dayid = '$v_date'
    and is_deleted = 0
) as gift_coupon_conf on gift_hicard.gift_coupon_conf_id = gift_coupon_conf.id
where hi_card_template.hi_card_type = 1 -- 取提货卡