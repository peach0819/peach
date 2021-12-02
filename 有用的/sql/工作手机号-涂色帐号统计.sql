SELECT  phone.phone as 工作手机号,
        phone.bind_qw_user_id as 企微帐号,
        phone.bind_tu_account as 涂色帐号,
        phone.bind_tu_password as 涂色密码,
        admin.full_name as 绑定电销名,
        dept.name as 电销组名
FROM t_crm_work_phone phone
LEFT JOIN yt_ustone.t_user_admin admin ON phone.bind_user_id = admin.user_id
LEFT JOIN yt_ustone.t_department dept ON dept.id = admin.dept_id
WHERE phone.is_deleted = 0;