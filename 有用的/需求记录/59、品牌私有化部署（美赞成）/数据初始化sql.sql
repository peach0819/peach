
--原子指标
INSERT INTO t_crm_visit_indicator(`id`, `creator`, `editor`, `indicator_code`, `indicator_name`, `indicator_unit`, `indicator_type`, `indicator_display_type`)
VALUES (1, 'system', 'system', 'month_visit_valid_shop_cnt', '当月有效拜访门店数', '', 0, 'num'),
       (2, 'system', 'system', 'month_visit_shop_cnt', '当月目标拜访店次', '', 0, 'num'),
       (3, 'system', 'system', 'month_visit_hsp_cnt', '当月服务商拜访数', '', 0, 'num'),
       (4, 'system', 'system', 'month_visit_big_shop_cnt', '当月重点门店目标拜访店次', '', 0, 'num');

--派生指标
INSERT INTO t_crm_visit_indicator(`id`, `creator`, `editor`, `indicator_code`, `indicator_name`, `indicator_unit`, `indicator_type`, `indicator_display_type`)
VALUES (100, 'system', 'system', 'month_visit_my_reach', '当月我的拜访达标', '', 1, 'text'),
       (101, 'system', 'system', 'month_visit_reach_rate', '当月拜访人员达标率', '%', 1, 'ratio'),
       (102, 'system', 'system', 'month_visit_valid_cnt', '当月有效拜访门店数', '', 1, 'num'),
       (103, 'system', 'system', 'quarter_visit_valid_cnt', '季度有效拜访门店数', '', 1, 'num'),
       (104, 'system', 'system', 'month_visit_valid_rate', '当月有效拜访率', '%', 1, 'ratio'),
       (105, 'system', 'system', 'month_visit_plan_reach_rate', '当月计划拜访门店完成率', '%', 1, 'ratio'),
       (106, 'system', 'system', 'month_visit_freq_reach_rate', '当月门店拜访频次达标率', '%', 1, 'ratio'),
       (107, 'system', 'system', 'month_visit_nc_cover_rate', '当月NC门店拜访覆盖率', '%', 1, 'ratio'),
       (108, 'system', 'system', 'month_visit_ncm_cover_rate', '当月NCM门店拜访覆盖率', '%', 1, 'ratio'),
       (109, 'system', 'system', 'month_visit_ncm_big_freq_reach_rate', '当月NCM重点门店拜访频次达成率', '%', 1, 'ratio'),
       (110, 'system', 'system', 'month_visit_hsp_cnt_actual', '当月服务商拜访个数', '', 1, 'num'),
       (111, 'system', 'system', 'quarter_visit_hsp_cover_rate', '季度服务商拜访覆盖率', '%', 1, 'ratio');

------------------------------------------------指标可见性矩阵初始化
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
       ('system', 'system', 0, 26, 4, 101, 0),
       ('system', 'system', 0, 2, null, 101, 0),
       ('system', 'system', 0, 25, null, 101, 0),
       ('system', 'system', 0, 7, null, 101, 0),
       ('system', 'system', 0, 10, null, 101, 0),
       ('system', 'system', 0, 19, null, 101, 0),
       ('system', 'system', 0, 18, null, 101, 0),
       ('system', 'system', 0, 4, null, 101, 0),
       ('system', 'system', 0, 3, null, 101, 0),
       ('system', 'system', 0, 17, null, 101, 0),
       ('system', 'system', 0, 16, null, 101, 0),
       ('system', 'system', 0, 6, null, 101, 0),
       ('system', 'system', 0, 14, null, 101, 0),
       ('system', 'system', 0, 9, null, 101, 0),
       ('system', 'system', 0, 20, null, 101, 0),
       ('system', 'system', 0, 22, null, 101, 0),
       ('system', 'system', 0, 21, null, 101, 0),
       ('system', 'system', 0, 23, null, 101, 0),
       ('system', 'system', 0, 1, null, 101, 0);

--当月有效拜访门店数
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 1, 5, 2, 102),
       ('system', 'system', 1, 15, 2, 102),
       ('system', 'system', 1, 13, 2, 102),
       ('system', 'system', 1, 5, 1, 102),
       ('system', 'system', 1, 15, 1, 102),
       ('system', 'system', 1, 13, 1, 102),
       ('system', 'system', 0, 5, 4, 102),
       ('system', 'system', 0, 15, 4, 102),
       ('system', 'system', 0, 13, 4, 102),
       ('system', 'system', 1, 12, null, 102),
       ('system', 'system', 1, 11, null, 102),
       ('system', 'system', 0, 26, 4, 102),
       ('system', 'system', 1, 2, null, 102),
       ('system', 'system', 1, 25, null, 102);

--季度有效拜访门店数
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 1, 5, 2, 103),
       ('system', 'system', 1, 15, 2, 103),
       ('system', 'system', 1, 13, 2, 103),
       ('system', 'system', 1, 5, 1, 103),
       ('system', 'system', 1, 15, 1, 103),
       ('system', 'system', 1, 13, 1, 103),
       ('system', 'system', 1, 5, 4, 103),
       ('system', 'system', 1, 15, 4, 103),
       ('system', 'system', 1, 13, 4, 103),
       ('system', 'system', 1, 12, null, 103),
       ('system', 'system', 1, 8, null, 103),
       ('system', 'system', 1, 11, null, 103),
       ('system', 'system', 1, 26, 4, 103),
       ('system', 'system', 1, 2, null, 103),
       ('system', 'system', 1, 25, null, 103);

--当月有效拜访率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 1, 5, 2, 104),
       ('system', 'system', 1, 15, 2, 104),
       ('system', 'system', 1, 13, 2, 104),
       ('system', 'system', 1, 5, 1, 104),
       ('system', 'system', 1, 15, 1, 104),
       ('system', 'system', 1, 13, 1, 104),
       ('system', 'system', 1, 5, 4, 104),
       ('system', 'system', 1, 15, 4, 104),
       ('system', 'system', 1, 13, 4, 104),
       ('system', 'system', 0, 12, null, 104),
       ('system', 'system', 0, 8, null, 104),
       ('system', 'system', 0, 11, null, 104),
       ('system', 'system', 1, 24, null, 104),
       ('system', 'system', 0, 26, 4, 104),
       ('system', 'system', 0, 2, null, 104),
       ('system', 'system', 0, 25, null, 104),
       ('system', 'system', 0, 7, null, 104),
       ('system', 'system', 0, 10, null, 104),
       ('system', 'system', 0, 19, null, 104),
       ('system', 'system', 0, 18, null, 104),
       ('system', 'system', 0, 4, null, 104),
       ('system', 'system', 0, 3, null, 104),
       ('system', 'system', 0, 17, null, 104),
       ('system', 'system', 0, 16, null, 104),
       ('system', 'system', 0, 6, null, 104),
       ('system', 'system', 0, 14, null, 104),
       ('system', 'system', 0, 9, null, 104),
       ('system', 'system', 0, 20, null, 104),
       ('system', 'system', 0, 22, null, 104),
       ('system', 'system', 0, 21, null, 104),
       ('system', 'system', 0, 23, null, 104),
       ('system', 'system', 0, 1, null, 104);

--当月计划拜访门店完成率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 1, 5, 2, 105),
       ('system', 'system', 1, 15, 2, 105),
       ('system', 'system', 1, 13, 2, 105),
       ('system', 'system', 1, 5, 1, 105),
       ('system', 'system', 1, 15, 1, 105),
       ('system', 'system', 1, 13, 1, 105),
       ('system', 'system', 1, 5, 4, 105),
       ('system', 'system', 1, 15, 4, 105),
       ('system', 'system', 1, 13, 4, 105),
       ('system', 'system', 1, 12, null, 105),
       ('system', 'system', 1, 8, null, 105),
       ('system', 'system', 1, 11, null, 105),
       ('system', 'system', 1, 24, null, 105),
       ('system', 'system', 1, 2, null, 105),
       ('system', 'system', 1, 25, null, 105);

--当月门店拜访频次达标率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 2, 106),
       ('system', 'system', 0, 15, 2, 106),
       ('system', 'system', 0, 13, 2, 106),
       ('system', 'system', 0, 5, 1, 106),
       ('system', 'system', 0, 15, 1, 106),
       ('system', 'system', 0, 13, 1, 106),
       ('system', 'system', 1, 5, 4, 106),
       ('system', 'system', 1, 15, 4, 106),
       ('system', 'system', 1, 13, 4, 106),
       ('system', 'system', 0, 12, null, 106),
       ('system', 'system', 0, 8, null, 106),
       ('system', 'system', 0, 11, null, 106),
       ('system', 'system', 0, 2, null, 106),
       ('system', 'system', 0, 25, null, 106),
       ('system', 'system', 0, 7, null, 106),
       ('system', 'system', 0, 10, null, 106),
       ('system', 'system', 0, 19, null, 106),
       ('system', 'system', 0, 18, null, 106),
       ('system', 'system', 0, 4, null, 106),
       ('system', 'system', 0, 3, null, 106),
       ('system', 'system', 0, 17, null, 106),
       ('system', 'system', 0, 16, null, 106),
       ('system', 'system', 0, 6, null, 106),
       ('system', 'system', 0, 14, null, 106),
       ('system', 'system', 0, 9, null, 106),
       ('system', 'system', 0, 20, null, 106),
       ('system', 'system', 0, 22, null, 106),
       ('system', 'system', 0, 21, null, 106),
       ('system', 'system', 0, 23, null, 106),
       ('system', 'system', 0, 1, null, 106);

--当月NC门店拜访覆盖率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 2, 107),
       ('system', 'system', 0, 15, 2, 107),
       ('system', 'system', 0, 13, 2, 107),
       ('system', 'system', 0, 5, 1, 107),
       ('system', 'system', 0, 15, 1, 107),
       ('system', 'system', 0, 13, 1, 107),
       ('system', 'system', 1, 12, null, 107),
       ('system', 'system', 1, 8, null, 107),
       ('system', 'system', 1, 11, null, 107),
       ('system', 'system', 1, 2, null, 107),
       ('system', 'system', 1, 25, null, 107);

--当月NCM门店拜访覆盖率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 24, null, 108);

--当月NCM重点门店拜访频次达成率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 24, null, 109);

--当月服务商拜访个数
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 0, 5, 4, 110),
       ('system', 'system', 0, 15, 4, 110),
       ('system', 'system', 0, 13, 4, 110),
       ('system', 'system', 1, 12, null, 110),
       ('system', 'system', 1, 11, null, 110),
       ('system', 'system', 1, 25, null, 110);

--当季服务商拜访覆盖率
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `channel_id`, `indicator_id`)
VALUES ('system', 'system', 1, 5, 4, 111),
       ('system', 'system', 1, 15, 4, 111),
       ('system', 'system', 1, 13, 4, 111),
       ('system', 'system', 1, 12, null, 111),
       ('system', 'system', 1, 8, null, 111),
       ('system', 'system', 1, 11, null, 111),
       ('system', 'system', 1, 25, null, 111);


