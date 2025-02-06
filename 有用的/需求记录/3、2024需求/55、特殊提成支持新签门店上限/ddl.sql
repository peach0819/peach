--新增过滤条件
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (33, '新签门店数上限', 'sign_shop_limit', 'sign_shop_limit', 0, 1, 1, 0, 'posi_int_input', '');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 6, 33);