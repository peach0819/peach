
SELECT linker.linker_obj_id as 门店id,
       linker.linker_id as 联系人id,
       t.group_name as 标签组名,
       GROUP_CONCAT(t.tag_name) as 标签内容
FROM (
    SELECT qw_user_id, qw_external_user_id, group_name, tag_name
    FROM t_crm_chat_tag_bind
    WHERE version = 42
    AND qw_user_id = '13067871832'
) t
LEFT JOIN (
    SELECT qw_user_id, qw_external_user_id, group_name, tag_name
    FROM t_crm_chat_tag_bind
    WHERE version = 57
    AND qw_user_id = '13067871832'
) t1 ON t.qw_user_id = t1.qw_user_id AND t.qw_external_user_id = t1.qw_external_user_id AND t.group_name = t1.group_name
INNER JOIN t_crm_chat xiaoer ON t.qw_user_id = xiaoer.qw_user_id
INNER JOIN t_crm_chat customer ON customer.qw_external_user_id = t.qw_external_user_id
INNER JOIN t_crm_chat_bind customer_bind ON  customer_bind.type = 2 AND customer_bind.is_deleted = 0 AND customer_bind.chat_id = customer.id
INNER JOIN yt_ustone.t_linker linker ON linker.linker_id = customer_bind.biz_id
WHERE t1.tag_name is null
group by linker.linker_obj_id, linker.linker_id, t.group_name