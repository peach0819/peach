WITH douyin_shop_mapping as (
    select shop_id as douyin_shop_id, id as douyin_shop_mapping_id
    from dwd_shop_data_cluster_mapping_d
    where dayid = '$v_date'
    and inuse = 1
    and cluster_id in (1750) --167是长尾BD. 1750是对外合作门店
)

select trade_no,
       order_id,
       brand_id,
       brand_name,
       item_name,
       category_id_first,
       category_id_first_name,
       category_id_second,
       category_id_second_name,
       category_id_third,
       category_id_third_name,
       item_style,
       sp_id,
       service_info_freezed,
       business_unit,
       business_group_code,
       business_group_name,
       pay_time,
       item_style_freezed,
       is_pickup_order,
       is_pickup_recharge_order,
       pickup_brand_id,
       pickup_brand_name,
       pickup_category_id_first,
       pickup_category_id_first_name,
       pickup_category_id_second,
       pickup_category_id_second_name,
       pickup_category_id_third,
       pickup_category_id_third_name,
       shop_id
from dw_order_d
left join (
    select shop_id as douyin_shop_id, id as douyin_shop_mapping_id
    from dwd_shop_data_cluster_mapping_d
    where dayid = '$v_date'
    and inuse = 1
    and cluster_id in (1750) --167是长尾BD. 1750是对外合作门店
) douyin_shop_mapping ON dw_order_d.shop_id = douyin_shop_mapping.douyin_shop_id
where dayid = '$v_date'
and bu_id = 0
and sale_dc_id = -1 --分销渠道过滤
and substr(pay_time, 1, 8) <= '$v_date'
-- 剔除抖音直播店
and douyin_shop_mapping.douyin_shop_mapping_id is null