
--新增过滤条件
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (34, '品牌系列名称', 'brand_key', 'brand_key', 0, 1, 1, 0, 'brand_series_select', '{"type":"url", "url":"hipac.crm.bountyPlan.treeFilterResult","code":"BRAND_SERIES"}');

--新增模版展示过滤条件
insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 34),
       (0, 6, 34);


update bounty_rule_filter SET is_hidden = 1 WHERE bounty_rule_type_id IN (4,6) AND bounty_filter_id = 8;