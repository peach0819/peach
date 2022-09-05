select report.id, report.report_name, report.report_key, report.create_time, t.owner_user_id, t.owner_user_name, d.name

FROM (
SELECT id, report_name, report_key , create_time FROM t_crm_report WHERE is_deleted = 0
) report

LEFT JOIN prod_edp.task t ON report.report_key = t.task_name AND  t.is_deleted = 0
 LEFT JOIN yt_ustone.t_user_admin u ON t.owner_user_id = u.user_id
 LEFT JOIN yt_ustone.t_department d ON u.dept_id = d.id
limit 3000