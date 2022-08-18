SELECT create_date,
       wx_fre_count,
       wx_total_fre_count
FROM (
    SELECT date_format(c.create_time, '%Y-%m-%d') as create_date,
           count(distinct c.id) as wx_fre_count,
           count(c.id) as wx_total_fre_count
    FROM t_crm_chat_relation  r
    INNER JOIN t_crm_chat c ON r.shop_chat_id = c.id AND c.type = 3
    WHERE date_format(c.create_time, '%Y-%m-%d')  > date_format(DATE_SUB(now(), INTERVAL 7 DAY), '%Y-%m-%d')
    AND c.create_time > '2022-08-12 00:00:00'
    group by date_format(c.create_time, '%Y-%m-%d')
) t
