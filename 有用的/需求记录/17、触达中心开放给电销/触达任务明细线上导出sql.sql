SELECT task_id as 任务id,
case when  detail_status  = 2 then '发送成功' else '发送失败' end as 发送状态,
t.shop_id as 门店id,
s.shop_name as 门店名,
t.linker_id as 联系人id,
l.LINKER_REAL_NAME as  联系人名,
admin_chat_id as 企微id,
xiaoer.name as 企微昵称,
shop_chat_id as 客户微信id,
customer.name as 客户昵称,
content as 发送内容,
file_name as 发送文件名,
fail_type as `失败code`
FROM t_touch_task_detail t
LEFT JOIN yt_ustone.t_shop s ON t.shop_id = s.shop_id
left join yt_ustone.t_linker l ON t.linker_id = l.linker_id
LEFT JOIN crm.t_crm_chat xiaoer ON t.admin_chat_id = xiaoer.id
LEFT JOIN crm.t_crm_chat customer ON t.shop_chat_id = customer.id
WHERE task_id IN (
40,41,42,43,48,49,54,55,56,57,60,65,67,68,87,88,89,90,91
)