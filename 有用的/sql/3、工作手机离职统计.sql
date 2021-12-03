SELECT phone.phone as 工作手机号,
    admin.full_name 已离职人员名,
    phone.bind_qw_user_id 企微号,
    phone.bind_tu_account 涂色帐号
FROM crm.t_crm_work_phone  phone
LEFT JOIN yt_ustone.t_user_admin admin ON phone.bind_user_id = admin.user_id
WHERE phone.is_deleted = 0
AND admin.leave_time is not null