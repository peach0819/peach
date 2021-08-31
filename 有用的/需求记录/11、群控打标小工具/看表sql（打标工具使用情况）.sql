SELECT count(DISTINCT shop_id) as 当日打标门店数,
       count(DISTINCT linker_id) as 当日打标联系人数,
       date_format(version_time, '%Y-%m-%d')
FROM t_crm_chat_tag_bind
WHERE version_type = 1
order by date_format(version_time, '%Y-%m-%d');