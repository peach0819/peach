
--新增品牌标签筛选
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (30, '品牌标签', 'brand_tag', 'brand_tag', 0, 1, 1, 0, 'enum_multi_select', '{"type":"url", "url":"hipac.crm.bountyPlan.listFilterResult","code":"BRAND_TAG"}');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 30),
       (0, 5, 30),
       (0, 6, 30),
       (0, 7, 30);

--奖励计算时间支持多选
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (31, '奖励计算时间', 'calculate_date', 'calculate_date', 1, 1, 1, 0, 'date_multi_range', '');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 31),
       (0, 5, 31),
       (0, 6, 31);

UPDATE bounty_rule_filter SET is_hidden = 1 WHERE bounty_rule_type_id IN (4,5,6) AND bounty_filter_id = 1;

