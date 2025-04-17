
--废弃老的指标
-- UPDATE t_crm_visit_indicator
-- SET is_deleted = 1
-- WHERE id IN (
-- 102,
-- 103,
-- 104,
-- 105,
-- 106,
-- 107,
-- 108,
-- 109,
-- 110,
-- 111
-- );

--废弃所有老的指标可见性
-- update t_crm_visit_indicator_visible SET is_deleted = 1 WHERE indicator_id IN (100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111);

--新增指标
INSERT INTO t_crm_visit_indicator(`id`, `creator`, `editor`, `indicator_code`, `indicator_name`, `indicator_unit`, `indicator_type`, `indicator_display_type`)
VALUES (120, 'system', 'system', 'month_visit_freq_valid_rate', '门店拜访频次达成率', '%', 1, 'ratio'),
       (121, 'system', 'system', 'month_nka_nc_visit_valid_rate', 'NKA专职NC门店拜访达成率', '%', 1, 'ratio'),
       (122, 'system', 'system', 'month_rka_nc_visit_valid_rate', 'RKA专职NC门店拜访达成率', '%', 1, 'ratio'),
       (123, 'system', 'system', 'month_hospital_visit_valid_rate', '院线店拜访达成率', '%', 1, 'ratio'),
       (124, 'system', 'system', 'month_shop_visit_valid_rate', '门店拜访覆盖率', '%', 1, 'ratio'),
       (125, 'system', 'system', 'month_fws_visit_valid_rate', '月度服务商拜访达成率', '%', 1, 'ratio'),
       (126, 'system', 'system', 'quar_fws_visit_valid_rate', '季度服务商拜访达成率', '%', 1, 'ratio'),
       (127, 'system', 'system', 'month_gt_shop_visit_valid_rate', '月度GT渠道门店拜访覆盖率', '%', 1, 'ratio'),
       (128, 'system', 'system', 'quar_gt_shop_visit_valid_rate', '季度GT渠道门店拜访覆盖率', '%', 1, 'ratio');

--当月拜访人员达标率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`, `visiable_sort`)
VALUES ('system', 'system', 0, 5, 2, 101, 0),
       ('system', 'system', 0, 15, 2, 101, 0),
       ('system', 'system', 0, 13, 2, 101, 0),
       ('system', 'system', 0, 5, 1, 101, 0),
       ('system', 'system', 0, 15, 1, 101, 0),
       ('system', 'system', 0, 13, 1, 101, 0),
       ('system', 'system', 0, 5, 4, 101, 0),
       ('system', 'system', 0, 15, 4, 101, 0),
       ('system', 'system', 0, 13, 4, 101, 0),
       ('system', 'system', 0, 12, null, 101, 0),
       ('system', 'system', 0, 8, null, 101, 0),
       ('system', 'system', 0, 11, null, 101, 0),
       ('system', 'system', 0, 24, null, 101, 0),
       ('system', 'system', 0, 7, null, 101, 0),
       ('system', 'system', 0, 10, null, 101, 0),
       ('system', 'system', 0, 19, null, 101, 0),
       ('system', 'system', 0, 18, null, 101, 0),
       ('system', 'system', 0, 4, null, 101, 0),
       ('system', 'system', 0, 3, null, 101, 0),
       ('system', 'system', 0, 17, null, 101, 0),
       ('system', 'system', 0, 16, null, 101, 0),
       ('system', 'system', 0, 1, null, 101, 0),
       ('system', 'system', 0, 27, 4, 101, 0),
       ('system', 'system', 0, 27, 2, 101, 0),
       ('system', 'system', 0, 27, 1, 101, 0);

--门店拜访频次达成率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 2, 120),
       ('system', 'system', 0, 15, 2, 120),
       ('system', 'system', 0, 13, 2, 120),
       ('system', 'system', 0, 5, 1, 120),
       ('system', 'system', 0, 15, 1, 120),
       ('system', 'system', 0, 13, 1, 120),
       ('system', 'system', 0, 12, null, 120),
       ('system', 'system', 0, 8, null, 120),
       ('system', 'system', 0, 11, null, 120),
       ('system', 'system', 0, 7, null, 120),
       ('system', 'system', 0, 10, null, 120),
       ('system', 'system', 0, 19, null, 120),
       ('system', 'system', 0, 18, null, 120),
       ('system', 'system', 0, 4, null, 120),
       ('system', 'system', 0, 3, null, 120),
       ('system', 'system', 0, 17, null, 120),
       ('system', 'system', 0, 16, null, 120),
       ('system', 'system', 0, 1, null, 120),
       ('system', 'system', 0, 27, 2, 120),
       ('system', 'system', 0, 27, 1, 120);

--NKA专职NC门店拜访达成率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 2, 121),
       ('system', 'system', 0, 15, 2, 121),
       ('system', 'system', 0, 13, 2, 121),
       ('system', 'system', 0, 5, 1, 121),
       ('system', 'system', 0, 15, 1, 121),
       ('system', 'system', 0, 13, 1, 121),
       ('system', 'system', 0, 11, null, 121);

--RKA专职NC门店拜访达成率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 2, 122),
       ('system', 'system', 0, 15, 2, 122),
       ('system', 'system', 0, 13, 2, 122),
       ('system', 'system', 0, 5, 1, 122),
       ('system', 'system', 0, 15, 1, 122),
       ('system', 'system', 0, 13, 1, 122);

--院线店拜访达成率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 2, 123),
       ('system', 'system', 0, 5, 1, 123);

--门店拜访覆盖率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 2, 124),
       ('system', 'system', 0, 15, 2, 124),
       ('system', 'system', 0, 13, 2, 124),
       ('system', 'system', 0, 5, 1, 124),
       ('system', 'system', 0, 15, 1, 124),
       ('system', 'system', 0, 13, 1, 124),
       ('system', 'system', 0, 5, 4, 124),
       ('system', 'system', 0, 15, 4, 124),
       ('system', 'system', 0, 13, 4, 124),
       ('system', 'system', 0, 12, null, 124),
       ('system', 'system', 0, 24, null, 124);

--月度服务商拜访达成率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 4, 125),
       ('system', 'system', 0, 15, 4, 125),
       ('system', 'system', 0, 13, 4, 125);

--季度服务商拜访达成率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 4, 126),
       ('system', 'system', 0, 15, 4, 126),
       ('system', 'system', 0, 13, 4, 126);

--月度GT渠道门店拜访覆盖率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 4, 127),
       ('system', 'system', 0, 15, 4, 127),
       ('system', 'system', 0, 13, 4, 127),
       ('system', 'system', 0, 27, 4, 127);

--季度GT渠道门店拜访覆盖率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 4, 128),
       ('system', 'system', 0, 15, 4, 128),
       ('system', 'system', 0, 13, 4, 128),
       ('system', 'system', 0, 27, 4, 128);