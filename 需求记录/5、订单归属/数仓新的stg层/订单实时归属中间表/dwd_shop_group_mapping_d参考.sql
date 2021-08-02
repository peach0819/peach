insert overwrite table dwd_shop_group_mapping_d partition (dayid = '$v_date')
select id,
       shop_id,
       group_id,
       from_unixtime(unix_timestamp(create_time), 'yyyyMMddHHmmss') as create_time,
       creator,
       from_unixtime(unix_timestamp(edit_time), 'yyyyMMddHHmmss')   as edit_time,
       editor,
       is_deleted,
       dc_id,
       biz_type
from ods_t_shop_group_mapping_d
where dayid = '$v_date'
  and dc_id = 0
;