select id,
       template_card_id,
       card_fund_id,
       card_id,
       out_biz_id,
       out_sub_biz_id,
       card_fund_serial_id,
       amount,
       card_fund_balance,
       user_id,
       shop_id,
       is_hide,
       is_deleted,
       creator,
       editor,
       from_unixtime(unix_timestamp(create_time), 'yyyyMMddHHmmss') as create_time,
       from_unixtime(unix_timestamp(edit_time), 'yyyyMMddHHmmss')   as edit_time
from ods_t_card_fund_serial_details_d
where dayid = '$v_date';