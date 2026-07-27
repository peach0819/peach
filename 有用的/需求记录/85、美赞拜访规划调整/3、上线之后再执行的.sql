--删除指标：当月门店拜访频次达成率、当月NKA专职NC门店拜访达成率、当月RKA专职NC门店拜访达成率、当月门店拜访覆盖率、当季服务商拜访达成率、
--          当月GT渠道门店拜访覆盖率、当季GT渠道门店拜访覆盖率、当月GT渠道院线店拜访覆盖率、当季GT渠道院线店拜访覆盖率
update t_crm_visit_indicator set is_deleted = 1 WHERE id IN (120, 121, 122, 124, 125, 126, 127, 128, 129, 130, 131);

--删除线上所有可见性矩阵
update t_crm_visit_indicator_visible_v2 set is_deleted = 1 WHERE is_deleted = 0 AND indicator_id IN (120, 121, 122, 124, 125, 126, 127, 128, 129, 130, 131);

--线上的可见性矩阵
INSERT INTO t_crm_visit_indicator_visible_v2(`creator`, `editor`, `visible_type`, `job_id`, `indicator_id`, `visiable_sort`)
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
INSERT INTO t_crm_visit_indicator_visible_v2(`creator`, `editor`, `visible_type`, `job_id`, `indicator_id`, `visiable_sort`)
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





--线上这个最后再跑，等运行稳定之后再说
DELETE FROM t_crm_visit_indicator WHERE id IN (120, 121, 122, 124, 125, 126, 127, 128, 129, 130, 131);

DELETE FROM t_crm_visit_indicator_visible_v2 WHERE indicator_id IN (120, 121, 122, 124, 125, 126, 127, 128, 129, 130, 131);

INSERT INTO t_crm_visit_indicator_visible_v2
SELECT * FROM t_crm_visit_indicator_visible;

