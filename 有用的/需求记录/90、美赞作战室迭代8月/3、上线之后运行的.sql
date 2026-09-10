--删除 当季全渠道重点门店拜访覆盖率
DELETE FROM t_crm_visit_indicator WHERE id = 146;
DELETE FROM t_crm_visit_indicator_visible WHERE indicator_id = 146;
DELETE FROM t_crm_visit_indicator_visible_v2 WHERE indicator_id = 146;

--新增指标可见性矩阵
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `indicator_id`, `visiable_sort`)
VALUES ('system', 'system', 0, 5, 148, 100),
       ('system', 'system', 0, 28, 148, 100),
       ('system', 'system', 0, 5, 149, 110),
       ('system', 'system', 0, 28, 149, 110);

--调整 当季服务商拜访覆盖率 顺序
UPDATE t_crm_visit_indicator_visible set visiable_sort = 120 WHERE indicator_id = 143;

--大区通路发展经理可见性矩阵调整
UPDATE t_crm_visit_indicator_visible SET is_deleted = 1 WHERE job_id = 8 AND indicator_id IN (140, 142);
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `indicator_id`, `visiable_sort`)
VALUES ('system', 'system', 0, 8, 145, 30);