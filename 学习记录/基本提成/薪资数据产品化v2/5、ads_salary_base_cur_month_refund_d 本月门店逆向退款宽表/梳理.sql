
--本月退款信息
--公司统一线上退款
with online_refund as (
    select order_id,
           '线上退款' as salary_refund_type,
           nvl(refund_actual_amount,0) as refund_actual_amount, --实际退款金额
           nvl(refund_pickup_card_amount,0) as refund_pickup_card_amount --提货卡退款金额
    from dw_afs_order_refund_new_d
    where dayid='$v_date'
    and refund_status=9
    and substr(refund_end_time,1,6)='$v_cur_month'
),
--薪资专属线下退款
offline_refund as (
    select order_id,
           '线下退款' as salary_refund_type,
           nvl(refund_actual_amount,0) as refund_actual_amount,
           0 as refund_pickup_card_amount --提货卡退款金额
    from dw_order_offline_refund_d
    where dayid='$v_date'
),
--本月退款订单结果集
cur_month_salary_refund as (
    --公司统一线上退款
    select * from online_refund

    union all

    -- 薪资专属线下退款
    select * from offline_refund
),

--订单基础信息，用来关联退单的订单信息
order_info as (
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
    where dayid='$v_date'
    and bu_id=0
    and sale_dc_id=-1   --分销渠道过滤
    and substr(pay_time,1,8)<='$v_date'
    -- 剔除抖音直播店
    and douyin_shop_mapping.douyin_shop_mapping_id is null
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
    FROM dwd_brand_d
    where dayid='$v_date'
    and (array_contains(split(tags,','),'42') or array_contains(split(tags,','),'41'))
)

insert overwrite table ads_salary_base_cur_month_refund_d partition(dayid='$v_date')
select
    --  退款信息
    cur_month_salary_refund.order_id,
    cur_month_salary_refund.salary_refund_type,
    cur_month_salary_refund.refund_actual_amount,
    cur_month_salary_refund.refund_pickup_card_amount,
    -- 订单信息
    order_info.brand_id,
    order_info.brand_name,
    order_info.item_name,
    order_info.category_id_first,
    order_info.category_id_first_name,
    order_info.category_id_second,
    order_info.category_id_second_name,
    order_info.item_style,
    order_info.sp_id,
    order_info.service_info_freezed,
    order_info.business_unit,
    order_info.business_group_code,
    order_info.business_group_name,
    order_info.pay_time,
    order_info.item_style_freezed,
    order_info.is_pickup_order,
    order_info.is_pickup_recharge_order,
    order_info.pickup_brand_id,
    order_info.pickup_brand_name,
    order_info.pickup_category_id_first,
    order_info.pickup_category_id_first_name,
    order_info.pickup_category_id_second,
    order_info.pickup_category_id_second_name,
    shop_info.shop_id,
    shop_info.shop_name,
    shop_info.store_type,
    shop_info.shop_status,
    shop_info.service_info,
    case when spec_brand.brand_id is not null then 1 else 0 end as is_spec_brand,
    case when spec_order.trade_no is not null then 1 else 0 end as is_spec_order,
    case when celeron.id is not null then 1 else 0 end as is_celeron,
    case when exclusive_b_brand.brand_id is not null then 1 else 0 end as is_exclusive_b,
    order_info.category_id_third,
    order_info.category_id_third_name,
    order_info.pickup_category_id_third,
    order_info.pickup_category_id_third_name
from cur_month_salary_refund
inner join order_info on order_info.order_id=cur_month_salary_refund.order_id
left join shop_info on order_info.shop_id=shop_info.shop_id
left join spec_order on spec_order.trade_no=order_info.trade_no
left join exclusive_b_brand on exclusive_b_brand.brand_id=order_info.brand_id
left join spec_brand on spec_brand.brand_id=order_info.brand_id
left join celeron on celeron.id=order_info.brand_id