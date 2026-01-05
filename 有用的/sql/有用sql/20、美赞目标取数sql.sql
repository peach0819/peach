SELECT t.id,
t.service_obj_type AS `拜访对象分类id`,
t.role_id AS `角色分类id`,
t.channel_id AS `人员渠道id`,
t.indicator_id AS `指标id`,
c.indicator_value AS `指标值`
FROM t_crm_visit_target  t
INNER JOIN (
	SELECT *
	FROM t_crm_visit_target_content
	WHERE id IN (
		SELECT MAX(id)
		FROM t_crm_visit_target_content
		GROUP BY target_id
	)
) c ON t.id = c.target_id
WHERE t.data_month = '2025-10'