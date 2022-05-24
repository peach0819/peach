--商品主表（过滤一些测试商品）
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
)

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
;