
SELECT    count(*) as count , fail_reason  ,a.qw_tuse_id
FROM t_touch_task_detail t
LEFT JOIN (
    SELECT distinct qw_tuse_id, qw_chat_id
    FROM crm.t_crm_chat_relation
    WHERE is_deleted = 0
    AND qw_tuse_id is not null
) a ON a.qw_chat_id = t.admin_chat_id
WHERE task_id >8892
AND detail_status = 3
 AND fail_type = 99
  group by admin_chat_id, fail_reason, a.qw_tuse_id
  order by count desc