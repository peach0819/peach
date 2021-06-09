use ytdw;
create table if not exists ads_salary_base_offline_refund_order_d
(
    order_id bigint ,
    trade_id string,
	trade_no string,
	refund_actual_amount decimal(18,2)
) comment '线下退款清洗表'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;

insert overwrite table ads_salary_base_offline_refund_order_d partition (dayid='$v_date')
select
    order_shop.order_id,
    order_shop.trade_id,
    offline_refund.trade_no,
    offline_refund.refund_actual_amount*(order_shop.item_actual_amount/trade_shop_total.item_actual_amount) as refund_actual_amount
from (
    select trade_no,sum(refund_actual_amount) refund_actual_amount
    from ads_salary_base_offline_refund_d
    where dayid='$v_date'
    group by trade_no
) offline_refund
left join (
    select *
    from dwd_trade_shop_d
    where dayid='$v_date'
    and is_deleted=0
) trade_shop on trade_shop.trade_no=offline_refund.trade_no
left join (
    select *
    from dwd_order_shop_d
    where dayid='$v_date'
    and is_deleted=0
) order_shop on order_shop.trade_id=trade_shop.trade_id
left join (
    select trade_id,sum(item_actual_amount) item_actual_amount
    from dwd_order_shop_d
    where dayid='$v_date'
    and is_deleted=0
    group by trade_id
) trade_shop_total on trade_shop_total.trade_id=order_shop.trade_id;