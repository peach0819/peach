SELECT shop.shop_id as 门店id,
       shop.shop_name as 门店名,
       linker.linker_id as 联系人id,
       linker.linker_real_name as 联系人名,

       customer.name as 客户微信昵称,

       xiaoer.qw_user_id as 添加人帐号,
       xiaoer.name as 添加人,
       parent_dept.name as 添加人大区,
       dept.name as 添加人组名
FROM t_crm_chat_bind linker_bind
INNER JOIN t_crm_chat customer ON customer.id = linker_bind.chat_id and customer.is_deleted = 0
INNER JOIN yt_ustone.t_linker linker ON linker_bind.biz_id = linker.linker_id
INNER JOIN yt_ustone.t_shop shop ON linker.linker_obj_id = shop.shop_id

INNER JOIN t_crm_chat_bind xiaoer_bind ON xiaoer_bind.biz_id = customer.id
INNER JOIN yt_crm.t_crm_chat xiaoer ON xiaoer.type = 2 AND xiaoer.id = xiaoer_bind.chat_id and xiaoer.is_deleted = 0
INNER JOIN yt_crm.t_crm_work_phone phone ON phone.bind_qw_user_id = xiaoer.qw_user_id and phone.is_deleted = 0
LEFT JOIN yt_ustone.t_user_admin admin ON admin.user_id = phone.bind_user_id and admin.user_status=1
LEFT JOIN yt_ustone.t_department dept ON dept.id = admin.dept_id
LEFT JOIN yt_ustone.t_department parent_dept ON parent_dept.id = dept.parent_id
WHERE linker_bind.is_deleted = 0
AND linker_bind.type = 2