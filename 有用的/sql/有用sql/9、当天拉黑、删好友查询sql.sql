SELECT
    shop.shop_name as 门店,
    linker.linker_real_name as 联系人,
    customer.name as 客户企微昵称,
    customer_bind.remark as 客户企微备注,
    admin.full_name as 小二名,
    dept.name as 小二部门,
    case when detail.fail_type = 14 then '拉黑' else '删好友' end as 客户流失类型
FROM (
SELECT distinct shop_id, linker_id, admin_chat_id, shop_chat_id, fail_type
FROM t_touch_task_detail
WHERE detail_status = 3
AND fail_type IN (14,15)
AND create_time > '2021-12-13 00:00:00'
order by task_id
) detail
LEFT JOIN yt_ustone.t_shop shop ON detail.shop_id = shop.shop_id
LEFT JOIN yt_ustone.t_linker linker ON linker.linker_id = detail.linker_id

LEFT JOIN crm.t_crm_chat xiaoer ON xiaoer.id = detail.admin_chat_id
LEFT JOIN crm.t_crm_work_phone phone ON xiaoer.qw_user_id = phone.bind_qw_user_id
LEFT JOIN yt_ustone.t_user_admin admin ON phone.bind_user_id = admin.user_id
LEFT JOIN yt_ustone.t_department dept ON dept.id = admin.dept_id

LEFT JOIN crm.t_crm_chat customer ON customer.id = detail.shop_chat_id
LEFT JOIN crm.t_crm_chat_bind customer_bind ON customer.id = customer_bind.biz_id AND customer_bind.chat_id = xiaoer.id