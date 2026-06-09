--删除线上所有可见性矩阵
update t_crm_visit_indicator_visible set is_deleted = 1 WHERE is_deleted = 0 AND indicator_id IN (101, 120, 121, 122, 124, 125, 126, 127, 128, 129, 130, 131);

--新增指标
INSERT INTO t_crm_visit_indicator(`id`, `creator`, `editor`, `indicator_code`, `indicator_name`, `indicator_unit`, `indicator_type`, `indicator_display_type`)
VALUES (139, 'system', 'system', 'quarter_visit_my_reach', '当季我的拜访达标', '', 1, 'text'),
       (140, 'system', 'system', 'month_visit_freq_reach_rate', '当月拜访频次达标率', '%', 1, 'ratio'),
       (141, 'system', 'system', 'month_nc_visit_reach_rate', '当月专职NC门店拜访达成率', '%', 1, 'ratio'),
       (142, 'system', 'system', 'month_fws_visit_cover_rate', '当月服务商拜访达成率', '%', 1, 'ratio'),
       (143, 'system', 'system', 'quarter_fws_visit_cover_rate', '当季服务商拜访覆盖率', '%', 1, 'ratio'),
       (144, 'system', 'system', 'month_star_visit_reach_rate', '当月星级门店拜访达成率', '%', 1, 'ratio'),
       (145, 'system', 'system', 'month_shop_visit_reach_rate', '当月门店拜访达成率', '%', 1, 'ratio'),
       (146, 'system', 'system', 'month_all_big_visit_cover_rate', '当季全渠道重点门店拜访覆盖率', '%', 1, 'ratio'),
       (147, 'system', 'system', 'month_hospital_visit_reach_rate', '当月院线店拜访达成率', '%', 1, 'ratio');

--指标可见性矩阵
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `indicator_id`, `visiable_sort`)
VALUES ('system', 'system', 0, 5, 101, 0),
       ('system', 'system', 0, 28, 101, 0),
       ('system', 'system', 0, 12, 101, 0),
       ('system', 'system', 0, 8, 101, 0),
       ('system', 'system', 0, 11, 101, 0),
       ('system', 'system', 0, 24, 101, 0),
       ('system', 'system', 0, 7, 101, 0),
       ('system', 'system', 0, 10, 101, 0),
       ('system', 'system', 0, 19, 101, 0),
       ('system', 'system', 0, 18, 101, 0),
       ('system', 'system', 0, 4, 101, 0),
       ('system', 'system', 0, 3, 101, 0),
       ('system', 'system', 0, 17, 101, 0),
       ('system', 'system', 0, 16, 101, 0),
       ('system', 'system', 0, 1, 101, 0),

       ('system', 'system', 0, 5, 139, 10),
       ('system', 'system', 0, 28, 139, 10),
       ('system', 'system', 0, 8, 139, 10),

       ('system', 'system', 0, 5, 140, 20),
       ('system', 'system', 0, 28, 140, 20),
       ('system', 'system', 0, 12, 140, 20),
       ('system', 'system', 0, 8, 140, 20),
       ('system', 'system', 0, 11, 140, 20),
       ('system', 'system', 0, 7, 140, 20),
       ('system', 'system', 0, 10, 140, 20),
       ('system', 'system', 0, 19, 140, 20),
       ('system', 'system', 0, 18, 140, 20),
       ('system', 'system', 0, 4, 140, 20),
       ('system', 'system', 0, 3, 140, 20),
       ('system', 'system', 0, 17, 140, 20),
       ('system', 'system', 0, 16, 140, 20),
       ('system', 'system', 0, 1, 140, 20),

       ('system', 'system', 0, 5, 145, 30),
       ('system', 'system', 0, 28, 145, 30),

       ('system', 'system', 0, 5, 141, 40),
       ('system', 'system', 0, 28, 141, 40),

       ('system', 'system', 0, 5, 147, 50),
       ('system', 'system', 0, 28, 147, 50),

       ('system', 'system', 0, 5, 142, 60),
       ('system', 'system', 0, 28, 142, 60),
       ('system', 'system', 0, 8, 142, 60),

       ('system', 'system', 0, 5, 143, 70),
       ('system', 'system', 0, 28, 143, 70),
       ('system', 'system', 0, 8, 143, 70),

       ('system', 'system', 0, 5, 144, 80),
       ('system', 'system', 0, 28, 144, 80),

       ('system', 'system', 0, 5, 146, 90),
       ('system', 'system', 0, 28, 146, 90);

--测试岗位
INSERT INTO t_crm_visit_indicator_visible(`creator`, `editor`, `visible_type`, `job_id`, `indicator_id`, `visiable_sort`)
VALUES ('system', 'system', 0, 59400, 101, 0),
       ('system', 'system', 0, 59400, 139, 10),
       ('system', 'system', 0, 59400, 140, 20),
       ('system', 'system', 0, 59400, 145, 30),
       ('system', 'system', 0, 59400, 141, 40),
       ('system', 'system', 0, 59400, 147, 50),
       ('system', 'system', 0, 59400, 142, 60),
       ('system', 'system', 0, 59400, 143, 70),
       ('system', 'system', 0, 59400, 144, 80),
       ('system', 'system', 0, 59400, 146, 90);
