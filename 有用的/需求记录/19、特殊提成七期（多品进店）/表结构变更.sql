
update bounty_filter set component_value_config = '{\"type\":\"custom-area\",\"url\": \"hipac.crm.bountyPlan.listSalesArea\",\"code\":\"WAR_AREA\"}' WHERE id = 12;
update bounty_filter set component_value_config = '{\"type\":\"custom-area\",\"url\": \"hipac.crm.bountyPlan.listSalesArea\",\"code\":\"BD_AREA\"}' WHERE id = 13;
update bounty_filter set component_value_config = '{\"type\":\"custom-area\",\"url\": \"hipac.crm.bountyPlan.listSalesArea\",\"code\":\"MANAGE_AREA\"}' WHERE id = 14;

ALTER TABLE bounty_plan ADD COLUMN time_type tinyint(4) NOT NULL default 1 COMMENT '方案时间类型 1.月度方案 2.季度方案';

--新增发放对象->规则模板映射
INSERT INTO bounty_payout_object_rule(payout_object_id, bounty_rule_type)
VALUES (1, 4),
       (2, 4),
       (3, 4),
       (4, 4);

--新增业绩指标
insert into `bounty_indicator` (`id`, `title`, `bounty_rule_type`, `code`, `sort`, `unit`)
values (17, '有效品牌门店数', 4, 'VALID_BRAND_SHOP_COUNT', 1, '家'),
       (18, '多品在店积分', 4, 'BRAND_SHOP_SCORE', 2, '分'),
       (19, '有效品牌门店数变化', 4, 'VALID_BRAND_SHOP_COUNT_CHANGE', 3, '家');

-- 新增过滤条件
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (19, '有效门槛线', 'valid_brand_line', 'valid_brand_line', 1, 0, 1, 0, 'posi_int_input', null),
       (20, '方案计算时间', 'calculate_date_quarter', 'calculate_date_quarter', 1, 1, 1, 0, 'date_range', null),
       (21, '比对时间', 'compare_date', 'compare_date', 1, 1, 1, 0, 'date_range', null);

-- 新增规则模板->过滤条件映射
insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 7, 2),
       (0, 7, 17),
       (0, 7, 18),
       (0, 7, 6),
       (0, 7, 7),
       (0, 7, 8),
       (0, 7, 12),
       (0, 7, 13),
       (0, 7, 14),
       (0, 7, 19),
       (0, 7, 20),
       (0, 7, 21);

-- 新增业绩指标->提成奖励类型映射
insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`,`payout_rule_type_code`,`bounty_unit`,`sort`,`is_upper_limit`,`is_hidden`)
values (17, 1, '元', 1, 0, 0),
       (17, 3, null, 2, 0, 0),
       (17, 4, '元/家', 3, 1, 0),
       (17, 5, '元', 4, 0, 0),
       (18, 1, '元', 1, 0, 0),
       (18, 3, null, 2, 0, 0),
       (18, 4, '元/分', 3, 1, 0),
       (18, 5, '元', 4, 0, 0),
       (19, 1, '元', 1, 0, 0),
       (19, 3, null, 2, 0, 0),
       (19, 4, '元/家', 3, 1, 0),
       (19, 5, '元', 4, 0, 0);