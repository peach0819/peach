--字段扩容
ALTER TABLE bounty_filter MODIFY COLUMN `component_value_config` VARCHAR(200) COMMENT '组件待选值配置';

--新增冻结二级销售团队标识
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (35, '冻结二级销售团队标识', 'freeze_second_sales_team', 'freeze_second_sales_team', 1, 1, 1, 0, 'enum_multi_select', '{"type":"url", "url":"hipac.datacenter.filterContent.queryFilterContentList","code":"second_sale_team"}');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 35),
       (0, 6, 35);

--新增业务组（财务口径）
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (36, '业务组(财务口径)', 'order_group_name', 'order_group_name', 0, 1, 1, 0, 'enum_multi_select', '{"type":"url", "url":"hipac.datacenter.filterContent.queryFilterContentList","code":"order_group_name"}');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 36),
       (0, 6, 36);