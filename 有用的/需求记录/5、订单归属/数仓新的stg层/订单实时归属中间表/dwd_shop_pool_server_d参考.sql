select
id,
  shop_id,
  group_id,
  group_code,
  user_id,
  creater,
  from_unixtime(unix_timestamp(create_time),'yyyyMMddHHmmss') as create_time,
 editor,
  from_unixtime(unix_timestamp(edit_time),'yyyyMMddHHmmss') as edit_time,
 is_enabled,
  is_deleted
from ods_t_shop_pool_server_d
where dayid='$datadate'