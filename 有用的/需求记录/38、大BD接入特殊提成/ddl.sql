
--新增指标人均新签gmv
insert into `bounty_indicator` (`id`, `title`, `bounty_rule_type`, `code`, `sort`, `unit`)
values (37, '人均新签GMV', 2, 'NEW_SIGNING_ITEM_AVG_NEW_SING_GMV', 10, '元/人'),
       (38, '人均新签商品门店数', 2, 'NEW_SIGNING_ITEM_AVG_NEW_SING_SHOPS', 9, '家/人');

insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`,`payout_rule_type_code`,`bounty_unit`,`sort`,`is_upper_limit`)
values (37, 1, '元', 1, 0),
       (37, 3, '', 2, 0),
       (37, 5, '元', 3, 1),
       (37, 4, '元/(元/人)', 4, 1),
       (38, 1, '元', 1, 0),
       (38, 3, '', 2, 0),
       (38, 5, '元', 3, 1),
       (38, 4, '元/(家/人)', 4, 1);

---新增过滤条件  部门
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (27, '部门', 'dept', 'dept', 0, 1, 1, 0, 'api_multi_select', '{\"type\":\"url\", \"url\":\"hipac.crm.bountyPlan.listFilterResult\",\"code\":\"DEPT\"}');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 27),
       (0, 5, 27),
       (0, 6, 27),
       (0, 8, 27);

--新增大BD省区经理
INSERT INTO `bounty_payout_object` (`id`, `name`, `code`)
VALUES (7, '【岗位】大BD省区经理', 'BIG_BD_AREA_MANAGER');

INSERT INTO `bounty_payout_object_rule` (`payout_object_id`, `bounty_rule_type`)
VALUES (7, 1),
       (7, 2),
       (7, 3);
