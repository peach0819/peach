--总的统计
SELECT count(distinct CASE WHEN tuse_meta_msg_content = '消息已发出，但被对方拒收了' then from_chat_id else null end) as 客户拉黑数,
       count(distinct CASE WHEN tuse_meta_msg_content like '%开启了联系人验证%' then from_chat_id else null end)  as 客户删好友数,
       date_format(tuse_msg_time, '%Y-%m-%d') as msg_date
FROM t_crm_tuse_qw_personal_msg
WHERE tuse_msg_type = 10000
AND from_chat_id is not null
group by msg_date
order by msg_date

--总的无法触达占比
SELECT msg_date,
       black_count/total_count as 消息发送被拉黑率,
       delete_count/total_count as 消息发送被删除率,
       (black_count+delete_count)/total_count as 消息未触达率
FROM (
SELECT date_format(tuse_msg_time, '%Y-%m-%d') as msg_date,
       count(*) as total_count,
       count(CASE WHEN tuse_meta_msg_content = '消息已发出，但被对方拒收了' then from_chat_id else null end) as black_count,
       count(CASE WHEN tuse_meta_msg_content like '%开启了联系人验证%' then from_chat_id else null end) as delete_count
FROM t_crm_tuse_qw_personal_msg
GROUP BY date_format(tuse_msg_time, '%Y-%m-%d')
) temp

--删好友明细
SELECT distinct c.name as 客户微信昵称,
       c2.name as 小二企微昵称,
       date_format(tuse_msg_time, '%Y-%m-%d') as msg_date
FROM t_crm_tuse_qw_personal_msg m
LEFT JOIN t_crm_chat c ON m.from_chat_id = c.id
LEFT JOIN t_crm_chat c2 ON m.to_chat_id = c2.id
WHERE m.tuse_meta_msg_content like '%对方验证通过后%'
AND c.name != ''
AND c2.name != ''
ORDER BY msg_date, c2.name;

--拉黑明细
SELECT distinct c.name as 客户微信昵称,
       c2.name as 小二企微昵称,
       date_format(tuse_msg_time, '%Y-%m-%d') as msg_date
FROM t_crm_tuse_qw_personal_msg m
LEFT JOIN t_crm_chat c ON m.from_chat_id = c.id
LEFT JOIN t_crm_chat c2 ON m.to_chat_id = c2.id
WHERE m.tuse_meta_msg_content like '%拒收%'
AND c.name != ''
AND c2.name != ''
ORDER BY msg_date;