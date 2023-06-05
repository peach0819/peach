
--新增过滤条件 gmv门槛线 三级类目
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (28, '单门店门槛线', 'valid_gmv_line', 'valid_gmv_line', 0, 1, 1, 0, 'posi_int_input', '');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 28);


INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (29, '三级类目', 'category_third', 'category_third', 0, 1, 1, 0, 'api_multi_select', '{"type":"url", "url":"hipac.crm.bountyPlan.listFilterResult","code":"THREE_CATEGORY"}');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 29),
       (0, 5, 29),
       (0, 6, 29),
       (0, 7, 29);

---新增指标  gmv指标
insert into `bounty_indicator` (`id`, `title`, `bounty_rule_type`, `code`, `sort`, `unit`)
values (39, '实货完成率', 1, 'GMV_SHIHUO_RATE', 16, '%'),
       (40, '实货下单门店数', 1, 'GMV_SHIHUO_SHOP_COUNT', 17, '家'),
       (41, '控区HI卡下单门店数', 1, 'GMV_HI_SHOP_COUNT', 18, '家');

insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (39, 1, '元', 1, 0),
       (39, 3, '', 3, 0),
       (39, 5, '元', 5, 1),
       (40, 1, '元', 1, 0),
       (40, 3, '', 3, 0),
       (40, 4, '元/家', 4, 1),
       (40, 5, '元', 5, 1),
       (41, 1, '元', 1, 0),
       (41, 3, '', 3, 0),
       (41, 4, '元/家', 4, 1),
       (41, 5, '元', 5, 1);
