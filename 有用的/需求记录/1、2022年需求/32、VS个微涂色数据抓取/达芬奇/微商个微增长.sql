SELECT create_date,  wx_count,wx_fre_count, wx_group_count, member_count FROM (
SELECT  fre.create_date,
        ifnull(wx_count, 0) as wx_count,
        ifnull(wx_fre_count, 0) as wx_fre_count,
        ifnull(wx_group_count, 0) as wx_group_count,
        ifnull(member_count, 0) as member_count
FROM (
    SELECT count(distinct c.id) as wx_fre_count, date_format(c.create_time, '%Y-%m-%d') as create_date
    FROM t_crm_chat_relation  r
    INNER JOIN t_crm_chat c ON r.shop_chat_id = c.id AND c.type = 3
    WHERE date_format(c.create_time, '%Y-%m-%d')  > date_format(DATE_SUB(now(), INTERVAL 7 DAY), '%Y-%m-%d')
    group by date_format(c.create_time, '%Y-%m-%d')
) fre
LEFT JOIN (
    SELECT count(distinct c.id) as wx_count,  date_format(c.create_time, '%Y-%m-%d') as create_date
    FROM t_crm_chat_relation  r
    INNER JOIN t_crm_chat c ON r.qw_chat_id = c.id AND c.type = 3
    WHERE date_format(c.create_time, '%Y-%m-%d')  > date_format(DATE_SUB(now(), INTERVAL 7 DAY), '%Y-%m-%d')
    group by date_format(c.create_time, '%Y-%m-%d')
) wx  ON wx.create_date = fre.create_date
LEFT JOIN (
    SELECT count(*) as wx_group_count ,date_format(create_time, '%Y-%m-%d') as create_date
    FROM t_crm_chat_group
    WHERE group_type = 1
    AND date_format(create_time, '%Y-%m-%d')  > date_format(DATE_SUB(now(), INTERVAL 7 DAY), '%Y-%m-%d')
    group by date_format(create_time, '%Y-%m-%d')
) wx_group  ON fre.create_date = wx_group.create_date
LEFT JOIN (
    SELECT count(*) as member_count ,date_format(create_time, '%Y-%m-%d') as create_date
    FROM t_crm_chat_group_member
    WHERE member_type = 3
    AND is_deleted = 0
    AND date_format(create_time, '%Y-%m-%d')  > date_format(DATE_SUB(now(), INTERVAL 7 DAY), '%Y-%m-%d')
    group by date_format(create_time, '%Y-%m-%d')
) group_member ON fre.create_date = group_member.create_date
HAVING fre.create_date > '2022-08-11'
) t
