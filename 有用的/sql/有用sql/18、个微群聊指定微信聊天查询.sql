SELECT open_user.name as open_user_name,
       msg.chat_group_name,
       msg.tuse_msg_time,
       msg.send_chat_name,
       msg.tuse_content
FROM (
    SELECT * FROM ads_tuse_wx_group_msg_d
    WHERE dayid = '$v_date'
) msg
INNER JOIN (
    SELECT *
    FROM dwd_crm_chat_group_d
    WHERE dayid = '$v_date'
    AND group_type = 1
    AND open_user_id IN (
        '3A6AC8130AFA921535D2E4C95F9EABD3',
        '8AA55D532D40EE8C908F121E56C0CA2A'
    )
) wx_group ON msg.tuse_group_id = wx_group.group_id
LEFT JOIN (
    SELECT * FROM dwd_crm_chat_d WHERE dayid = '$v_date'
) open_user ON open_user.tuse_id = wx_group.open_user_id