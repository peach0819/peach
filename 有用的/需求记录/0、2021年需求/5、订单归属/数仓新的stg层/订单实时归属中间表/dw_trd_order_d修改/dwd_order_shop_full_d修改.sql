SELECT order_id,
       trade_id,
       from_unixtime(unix_timestamp(create_time),'yyyyMMddHHmmss') as create_time,,
       shop_id,
       nvl(ytdw.getValueFromKVString(attribute,'saleDcId'),-1) as sale_dc_id,
       bu_id,
       supply_id,
       item_id
from ods_pt_order_shop_d
where dayid='$v_date'
and regexp_extract(attribute,'(off:)([0-9]*)(\;?)',2) <> '1' --原因你懂的
and order_id<>36133857 --脏数据，订单金额过大