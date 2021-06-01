sleep 1m
v_date=$1
sh /alidata/workspace/yt_bigdata/edp/data_offline_backup_two/ods_crm_t_salary_offline_refund_d.sh $v_date prod_slave_crm &&
sh /alidata/workspace/yt_bigdata/edp/data_offline_backup_two/dwd_crm_salary_offline_refund_d.sh $v_date &&
source ../sql_variable.sh $v_date

hive -v -e "
use ytdw;
create table if not exists ytdw.ads_salary_base_offline_refund_d (
  trade_no string comment '订单编号',
  refund_actual_amount decimal(12,2) comment '实际退款金额',
  update_time string comment '更新时间',
  data_month string comment '数据月份'
)
comment '线下退款表'
partitioned by (dayid string)
row format delimited fields terminated by '\001'
stored as orc;

with source_table as (
  select *
  from dwd_crm_salary_offline_refund_d
  where dayid='$v_date'
  and is_deleted=0
)
insert overwrite table ads_salary_base_offline_refund_d partition (dayid='$v_date')
select
  order_num as trade_no,
  refund_amount as refund_actual_amount,
  from_unixtime(unix_timestamp(edit_time,'yyyyMMddHHmmss'),'yyyy-MM-dd HH:mm:ss') as update_time,
  data_month
from source_table
inner join (
  select max(data_month) as max_month
  from source_table
  where data_month <= substr('$v_date',0,6)
) max_month_data ON source_table.data_month = max_month_data.max_month;

insert overwrite table dw_order_offline_refund_d partition (dayid='$v_date')
select
  order_shop.order_id,
  order_shop.trade_id,
  offline_refund.trade_no,
  offline_refund.refund_actual_amount*(order_shop.item_actual_amount/trade_shop_total.item_actual_amount) as refund_actual_amount
from (
  select trade_no,sum(refund_actual_amount) refund_actual_amount from ytdw.ads_salary_base_offline_refund_d where dayid='$v_date' group by trade_no
) offline_refund
left join (
  select * from ytdw.dwd_trade_shop_d where dayid='$v_date' and is_deleted=0
) trade_shop on trade_shop.trade_no=offline_refund.trade_no
left join (
  select * from ytdw.dwd_order_shop_d where dayid='$v_date' and is_deleted=0
) order_shop on order_shop.trade_id=trade_shop.trade_id
left join (
  select trade_id,sum(item_actual_amount) item_actual_amount
  from ytdw.dwd_order_shop_d where dayid='$v_date' and is_deleted=0
  group by trade_id
) trade_shop_total on trade_shop_total.trade_id=order_shop.trade_id;
" &&
sh /alidata/workspace/yt_bigdata/edp/salary_data_prodcut_new/ads_salary_base_offline_refund_order_d.sh $v_date &&

exit 0