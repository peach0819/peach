SELECT
    shop.shop_name as `门店`,
    linker.linker_real_name as `联系人`,
    customer.name as `客户企微昵称`,
    customer_bind.remark as `客户企微备注`,
    concat(admin.user_real_name, '(', admin.official_name,')') as `小二名`,
    dept.name as `小二部门`,
    case when detail.fail_type = 14 then '拉黑' else '删好友' end as `客户流失类型`
FROM (
    SELECT distinct shop_id, linker_id, admin_chat_id, shop_chat_id, fail_type
    FROM (SELECT * FROM dwd_touch_task_detail_d WHERE dayid = '$v_date') t
    WHERE detail_status = 3
    AND fail_type IN (14,15)
    AND substr(create_time,1,8)='$v_date'
) detail
LEFT JOIN (SELECT * FROM dwd_shop_d WHERE dayid = '$v_date') shop ON detail.shop_id = shop.shop_id
LEFT JOIN (SELECT * FROM dwd_linker_d WHERE dayid = '$v_date') linker ON linker.linker_id = detail.linker_id

LEFT JOIN (SELECT * FROM dwd_crm_chat_d WHERE dayid = '$v_date') xiaoer ON xiaoer.id = detail.admin_chat_id
LEFT JOIN (SELECT * FROM dwd_crm_work_phone_d WHERE dayid = '$v_date') phone ON xiaoer.qw_user_id = phone.bind_qw_user_id
LEFT JOIN (SELECT * FROM dim_hpc_pub_user_admin) admin ON phone.bind_user_id = admin.user_id
LEFT JOIN (
    SELECT dept_id as id,
           dept_name as name,
           dept_parent_id as parent_id,
           dept_parent_name as parent_name
    FROM dim_hpc_pub_dept
) dept ON dept.id = admin.dept_id

LEFT JOIN (SELECT * FROM dwd_crm_chat_d WHERE dayid = '$v_date') customer ON customer.id = detail.shop_chat_id
LEFT JOIN (SELECT * FROM dwd_crm_chat_bind_d WHERE dayid = '$v_date') customer_bind ON customer.id = customer_bind.biz_id AND customer_bind.chat_id = xiaoer.id