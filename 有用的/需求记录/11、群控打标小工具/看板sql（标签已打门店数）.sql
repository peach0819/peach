SELECT count(distinct shop.shop_id) as 已打标门店数,
       count(distinct linker.linker_id) as 已打标联系人数,
       count(distinct total.qw_external_user_id) as 已打标客户微信数,

       total.group_name as 标签组名,
       total.version_date as 日期
FROM (
    SELECT qw_user_id, qw_external_user_id, group_name, version, date_format(version_time, '%Y-%m-%d') as version_date, GROUP_CONCAT(tag_name)
    FROM yt_crm.t_crm_chat_tag_bind
    WHERE version_type = 0
    GROUP BY group_name, version, qw_user_id, qw_external_user_id
    ORDER BY version_time
) total

INNER JOIN yt_crm.t_crm_chat xiaoer ON xiaoer.type = 2 AND xiaoer.qw_user_id = total.qw_user_id
INNER JOIN yt_crm.t_crm_chat customer ON customer.qw_external_user_id = total.qw_external_user_id
LEFT JOIN yt_crm.t_crm_chat_bind linker_bind ON customer.id = linker_bind.chat_id
LEFT JOIN yt_ustone.t_linker linker ON linker_bind.biz_id = linker.linker_id
LEFT JOIN yt_ustone.t_shop shop ON linker.linker_obj_id = shop.shop_id
group by total.version

