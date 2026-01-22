--新增城市群负责人
-- INSERT INTO t_crm_visit_indicator_visible_v2(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`, `visiable_sort`)
-- VALUES ('system', 'system', 0, 28, 2, 101, 0),
-- 	   ('system', 'system', 0, 28, 1, 101, 0),
-- 	   ('system', 'system', 0, 28, 2, 120, 10),
-- 	   ('system', 'system', 0, 28, 1, 120, 10),
-- 	   ('system', 'system', 0, 28, 2, 121, 10),
-- 	   ('system', 'system', 0, 28, 1, 121, 10),
-- 	   ('system', 'system', 0, 28, 2, 122, 10),
-- 	   ('system', 'system', 0, 28, 1, 122, 10);

-- 5	城市渠道负责人
-- 13	省区渠道负责人
-- 15	地区渠道负责人
-- 28	城市群负责人
--废弃老的可见性矩形
update t_crm_visit_indicator_visible_v2 set is_deleted = 1 WHERE job_id IN (5,13,15,28);

INSERT INTO t_crm_visit_indicator_visible_v2(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`, `visiable_sort`)
VALUES ('system', 'system', 0, 5, 5, 101, 0),
	   ('system', 'system', 0, 13, 5, 101, 0),
	   ('system', 'system', 0, 15, 5, 101, 0),
	   ('system', 'system', 0, 28, 5, 101, 0),

	   ('system', 'system', 0, 5, 5, 120, 10),
	   ('system', 'system', 0, 13, 5, 120, 10),
	   ('system', 'system', 0, 15, 5, 120, 10),
	   ('system', 'system', 0, 28, 5, 120, 10),

	   ('system', 'system', 0, 5, 5, 121, 10),
	   ('system', 'system', 0, 13, 5, 121, 10),
	   ('system', 'system', 0, 15, 5, 121, 10),
	   ('system', 'system', 0, 28, 5, 121, 10),

	   ('system', 'system', 0, 5, 5, 122, 10),
	   ('system', 'system', 0, 13, 5, 122, 10),
	   ('system', 'system', 0, 15, 5, 122, 10),
	   ('system', 'system', 0, 28, 5, 122, 10),

	   ('system', 'system', 0, 5, 5, 125, 99),
	   ('system', 'system', 0, 13, 5, 125, 99),
	   ('system', 'system', 0, 15, 5, 125, 99),
	   ('system', 'system', 0, 28, 5, 125, 99),

	   ('system', 'system', 0, 5, 5, 127, 99),
	   ('system', 'system', 0, 13, 5, 127, 99),
	   ('system', 'system', 0, 15, 5, 127, 99),
	   ('system', 'system', 0, 28, 5, 127, 99),

	   ('system', 'system', 0, 5, 5, 129, 99),
	   ('system', 'system', 0, 13, 5, 129, 99),
	   ('system', 'system', 0, 15, 5, 129, 99),
	   ('system', 'system', 0, 28, 5, 129, 99),

	   ('system', 'system', 0, 5, 5, 131, 99);

-- 27  区域渠道负责人
update t_crm_visit_indicator_visible_v2 set is_deleted = 1 WHERE job_id IN (27);

INSERT INTO t_crm_visit_indicator_visible_v2(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`, `visiable_sort`)
VALUES ('system', 'system', 0, 27, 5, 101, 0),
	   ('system', 'system', 0, 27, 5, 120, 10),
	   ('system', 'system', 0, 27, 5, 127, 10);


-- 废弃老的2026年目标
update t_crm_visit_target set inuse = 1, is_deleted = 1 WHERE data_month IN ('2026-01', '2026-02', '2026-03') AND inuse = 0;