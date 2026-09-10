--删除 当季全渠道重点门店拜访覆盖率
UPDATE t_crm_visit_indicator_visible_v2 SET is_deleted = 1 WHERE indicator_id = 146;

--新增指标
INSERT INTO t_crm_visit_indicator(`id`, `creator`, `editor`, `indicator_code`, `indicator_name`, `indicator_unit`, `indicator_type`, `indicator_display_type`)
VALUES (148, 'system', 'system', 'quarter_cot_ka_visit_cover_rate', '当季COT/KA门店拜访覆盖率', '%', 1, 'ratio'),
       (149, 'system', 'system', 'quarter_gt_star_visit_cover_rate', '当季GT星级门店拜访覆盖率', '%', 1, 'ratio');

--新增指标可见性矩阵
INSERT INTO t_crm_visit_indicator_visible_v2(`creator`, `editor`, `visible_type`, `job_id`, `indicator_id`, `visiable_sort`)
VALUES ('system', 'system', 0, 5, 148, 100),
       ('system', 'system', 0, 28, 148, 100),

       ('system', 'system', 0, 5, 149, 110),
       ('system', 'system', 0, 28, 149, 110);

--调整 当季服务商拜访覆盖率 顺序
UPDATE t_crm_visit_indicator_visible_v2 set visiable_sort = 120 WHERE indicator_id = 143;

--大区通路发展经理可见性矩阵调整
UPDATE t_crm_visit_indicator_visible_v2 SET is_deleted = 1 WHERE job_id = 8 AND indicator_id IN (140, 142);
INSERT INTO t_crm_visit_indicator_visible_v2(`creator`, `editor`, `visible_type`, `job_id`, `indicator_id`, `visiable_sort`)
VALUES ('system', 'system', 0, 8, 145, 30);