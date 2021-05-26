
--本月订单信息
with cur_month_order as (
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
           nvl(pay_amount,0) as pay_amount,
           nvl(total_pay_amount,0) as total_pay_amount,
           sp_id,
           service_info_freezed,
           business_unit,
           business_group_code,
           business_group_name,
           pay_time,
           item_style_freezed,
           nvl(pickup_card_amount,0) as pickup_card_amount,
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
           shop_id-- 用于后续联表查询
    from dw_order_d --
    where dayid='$v_date'
    and substr(pay_time,1,6)='$v_cur_month'
    and bu_id=0
    and sale_dc_id=-1   --分销渠道过滤
    and substr(pay_time,1,8)<='$v_date'
    -- 剔除抖音直播店
    and shop_id!='bcfb591b919e48e1804fcdce670c6b55'
),

--门店基础信息表
shop_info as (
    select shop_id,
           shop_name,
           store_type,
           shop_status,
           service_info
    from dw_shop_base_d
    where dayid ='$v_date'
),

--特殊订单表
spec_order as (
    select trade_no
    from dw_offline_spec_refund_d
    where dayid ='$v_date'
    group by trade_no
),

--专属b
exclusive_b_brand as (
    select brand_id
    from dwd_salary_exclusive_b_brand_d
    where dayid='$v_date'
    group by brand_id
),

--特殊提点品牌表
spec_brand as (
    select brand_id
    from dw_offline_spec_brand_d
    where dayid ='$v_date'
    group by brand_id
),

--低端品牌标识
celeron as (
    SELECT id
    FROM dwd_brand_d --
    where dayid='$v_date'
    and (array_contains(split(tags,','),'42') or array_contains(split(tags,','),'41'))
)

insert overwrite table ads_salary_base_cur_month_order_d partition(dayid='$v_date')
select
    cur_month_order.order_id,
    cur_month_order.brand_id,
    cur_month_order.brand_name,
    cur_month_order.item_name,
    cur_month_order.category_id_first,
    cur_month_order.category_id_first_name,
    cur_month_order.category_id_second,
    cur_month_order.category_id_second_name,
    cur_month_order.item_style,
    cur_month_order.pay_amount,
    cur_month_order.total_pay_amount,
    cur_month_order.sp_id,
    cur_month_order.service_info_freezed,
    cur_month_order.business_unit,
    cur_month_order.business_group_code,
    cur_month_order.business_group_name,
    cur_month_order.pay_time,
    cur_month_order.item_style_freezed,
    cur_month_order.pickup_card_amount,
    cur_month_order.is_pickup_order,
    cur_month_order.is_pickup_recharge_order,
    cur_month_order.pickup_brand_id,
    cur_month_order.pickup_brand_name,
    cur_month_order.pickup_category_id_first,
    cur_month_order.pickup_category_id_first_name,
    cur_month_order.pickup_category_id_second,
    cur_month_order.pickup_category_id_second_name,
    shop_info.shop_id,
    shop_info.shop_name,
    shop_info.store_type,
    shop_info.shop_status,
    shop_info.service_info,
    case when spec_brand.brand_id is not null then 1 else 0 end as is_spec_brand,
    case when spec_order.trade_no is not null then 1 else 0 end as is_spec_order,
    case when celeron.id is not null then 1 else 0 end as is_celeron,
    case when exclusive_b_brand.brand_id is not null then 1 else 0 end as is_exclusive_b,
    cur_month_order.category_id_third,
    cur_month_order.category_id_third_name,
    cur_month_order.pickup_category_id_third,
    cur_month_order.pickup_category_id_third_name
from cur_month_order
left join shop_info on cur_month_order.shop_id=shop_info.shop_id
left join spec_order on spec_order.trade_no=cur_month_order.trade_no
left join exclusive_b_brand on exclusive_b_brand.brand_id = cur_month_order.brand_id
left join spec_brand on spec_brand.brand_id = cur_month_order.brand_id
left join celeron on celeron.id = cur_month_order.brand_id;
