SELECT shop.shop_id as 门店id,
       shop.shop_name as 门店名,
       linker.linker_id as 联系人id,
       linker.linker_real_name as 联系人名,
       case when linker.linker_type = 1 then '常用联系人'
            when linker.linker_type is not null then '非常用联系人'
            else null end as 联系人是否常用,

       customer.qw_external_user_id as 客户企微外部id,
       customer.name as 客户微信昵称,
       case when customer.type = 1 then '个微客户' else '企微客户' end as 客户微信类型,

       xiaoer.qw_user_id as 添加人帐号,
       xiaoer.name as 添加人企微昵称,
       parent_dept.name as 添加人大区,
       dept.name as 添加人组名,
       admin.user_real_name as 添加人真实小二,

       group1.tag as '性别(单选)',
       group2.tag as '代操作服务(单选)',
       group3.tag as '对接人角色(单选)',
       group4.tag as '开店形式(单选)',
       group5.tag as '其他比价拿货平台(多选)',
       group6.tag as '门店类型(多选)',
       group7.tag as '门店提供的附加服务(多选)',
       group8.tag as '门店线上销售渠道(多选)'
FROM t_crm_chat_bind xiaoer_bind

--小二面
INNER JOIN yt_crm.t_crm_chat xiaoer ON xiaoer.type = 2 AND xiaoer.id = xiaoer_bind.chat_id and xiaoer.is_deleted = 0
INNER JOIN yt_crm.t_crm_work_phone phone ON phone.bind_qw_user_id = xiaoer.qw_user_id and phone.is_deleted = 0
LEFT JOIN yt_ustone.t_user_admin admin ON admin.user_id = phone.bind_user_id
LEFT JOIN yt_ustone.t_department dept ON dept.id = admin.dept_id
LEFT JOIN yt_ustone.t_department parent_dept ON parent_dept.id = dept.parent_id

--客户面
INNER JOIN yt_crm.t_crm_chat customer ON customer.id = xiaoer_bind.biz_id and customer.is_deleted = 0
LEFT JOIN yt_crm.t_crm_chat_bind linker_bind ON customer.id = linker_bind.chat_id and linker_bind.is_deleted = 0
LEFT JOIN yt_ustone.t_linker linker ON linker_bind.biz_id = linker.linker_id
LEFT JOIN yt_ustone.t_shop shop ON linker.linker_obj_id = shop.shop_id

--标签面

LEFT JOIN (
    SELECT distinct qw_user_id, qw_external_user_id
    FROM yt_crm.t_crm_chat_tag_bind
    WHERE version_type = 0
    AND version = 83
) total ON total.qw_user_id = xiaoer.qw_user_id AND total.qw_external_user_id = customer.qw_external_user_id

LEFT JOIN (
    SELECT qw_user_id, qw_external_user_id, GROUP_CONCAT(tag_name) as tag
    FROM yt_crm.t_crm_chat_tag_bind
    WHERE version_type = 0
    AND version = 83
    AND group_name = '性别(单选)'
    group by qw_user_id, qw_external_user_id
) group1 ON group1.qw_user_id = total.qw_user_id AND group1.qw_external_user_id = total.qw_external_user_id

LEFT JOIN (
    SELECT qw_user_id, qw_external_user_id, GROUP_CONCAT(tag_name) as tag
    FROM yt_crm.t_crm_chat_tag_bind
    WHERE version_type = 0
    AND version = 83
    AND group_name = '代操作服务(单选)'
    group by qw_user_id, qw_external_user_id
) group2 ON group2.qw_user_id = total.qw_user_id AND group2.qw_external_user_id = total.qw_external_user_id

LEFT JOIN (
    SELECT qw_user_id, qw_external_user_id, GROUP_CONCAT(tag_name) as tag
    FROM yt_crm.t_crm_chat_tag_bind
    WHERE version_type = 0
    AND version = 83
    AND group_name = '对接人角色(单选)'
    group by qw_user_id, qw_external_user_id
) group3 ON group3.qw_user_id = total.qw_user_id AND group3.qw_external_user_id = total.qw_external_user_id

LEFT JOIN (
    SELECT qw_user_id, qw_external_user_id, GROUP_CONCAT(tag_name) as tag
    FROM yt_crm.t_crm_chat_tag_bind
    WHERE version_type = 0
    AND version = 83
    AND group_name = '开店形式(单选)'
    group by qw_user_id, qw_external_user_id
) group4 ON group4.qw_user_id = total.qw_user_id AND group4.qw_external_user_id = total.qw_external_user_id

LEFT JOIN (
    SELECT qw_user_id, qw_external_user_id, GROUP_CONCAT(tag_name) as tag
    FROM yt_crm.t_crm_chat_tag_bind
    WHERE version_type = 0
    AND version = 83
    AND group_name = '其他比价拿货平台(多选)'
    group by qw_user_id, qw_external_user_id
) group5 ON group5.qw_user_id = total.qw_user_id AND group5.qw_external_user_id = total.qw_external_user_id

LEFT JOIN (
    SELECT qw_user_id, qw_external_user_id, GROUP_CONCAT(tag_name) as tag
    FROM yt_crm.t_crm_chat_tag_bind
    WHERE version_type = 0
    AND version = 83
    AND group_name = '门店类型(多选)'
    group by qw_user_id, qw_external_user_id
) group6 ON group6.qw_user_id = total.qw_user_id AND group6.qw_external_user_id = total.qw_external_user_id

LEFT JOIN (
    SELECT qw_user_id, qw_external_user_id, GROUP_CONCAT(tag_name) as tag
    FROM yt_crm.t_crm_chat_tag_bind
    WHERE version_type = 0
    AND version = 83
    AND group_name = '门店提供的附加服务(多选)'
    group by qw_user_id, qw_external_user_id
) group7 ON group7.qw_user_id = total.qw_user_id AND group7.qw_external_user_id = total.qw_external_user_id

LEFT JOIN (
    SELECT qw_user_id, qw_external_user_id, GROUP_CONCAT(tag_name) as tag
    FROM yt_crm.t_crm_chat_tag_bind
    WHERE version_type = 0
    AND version = 83
    AND group_name = '门店线上销售渠道(多选)'
    group by qw_user_id, qw_external_user_id
) group8 ON group8.qw_user_id = total.qw_user_id AND group8.qw_external_user_id = total.qw_external_user_id

WHERE xiaoer_bind.is_deleted = 0
AND xiaoer_bind.type = 1



