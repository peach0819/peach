
--原子指标
INSERT INTO t_crm_visit_indicator(`id`, `creator`, `editor`, `indicator_code`, `indicator_name`, `indicator_unit`, `indicator_type`, `indicator_display_type`)
VALUES (1, 'system', 'system', 'month_visit_valid_shop_cnt', '当月有效拜访门店数', '', 0, 'num'),
       (2, 'system', 'system', 'month_visit_shop_cnt', '当月目标拜访店次', '%', 0, 'num'),
       (3, 'system', 'system', 'month_visit_hsp_cnt', '当月服务商拜访数', '%', 0, 'num'),
       (4, 'system', 'system', 'month_visit_big_shop_cnt', '当月重点门店目标拜访店次', '%', 0, 'num');

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
       (111, 'system', 'system', 'month_visit_hsp_cover_rate', '当季服务商拜访覆盖率', '%', 1, 'ratio');

