

---------------------------------------原有组件交互逻辑优化
-- api_multi_select 组件接口替换
UPDATE `bounty_filter` SET component_value_config = '{\"type\":\"url\", \"url\":\"hipac.crm.bountyPlan.listFilterResult\",\"code\":\"TWO_CATEGORY\"}' WHERE id = 7;
UPDATE `bounty_filter` SET component_value_config = '{\"type\":\"url\", \"url\":\"hipac.crm.bountyPlan.listFilterResult\",\"code\":\"BRAND\"}' WHERE id = 8;
UPDATE `bounty_filter` SET component_value_config = '{\"type\":\"url\", \"url\":\"hipac.crm.bountyPlan.listFilterResult\",\"code\":\"ITEM\"}' WHERE id = 9;


---------------------------------------新增销售人员过滤器
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (23, '参与对象', 'filter_user', 'filter_user', 0, 1, 1, 0, 'api_multi_select', '{\"type\":\"url\", \"url\":\"hipac.crm.bountyPlan.listFilterResult\",\"code\":\"USER\"}');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 23),
       (0, 5, 23),
       (0, 6, 23),
       (0, 7, 23);

--------------------------------------新增指定受益人
INSERT INTO `bounty_payout_object` (`id`, `name`, `code`)
VALUES (6, '【唯一】指定受益人', 'GRANT_USER');

INSERT INTO `bounty_payout_object_rule` (`payout_object_id`, `bounty_rule_type`)
VALUES (6, 1),
       (6, 2),
       (6, 3),
       (6, 4);

INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (24, '指定受益人', 'grant_user', 'grant_user', 1, 1, 1, 0, 'api_select', '{\"type\":\"url\", \"url\":\"hipac.crm.bountyPlan.listFilterResult\",\"code\":\"USER\"}');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 24),
       (0, 5, 24),
       (0, 6, 24),
       (0, 7, 24);

--------------------------------------GMV模板新增指标
insert into `bounty_indicator` (`id`, `title`, `bounty_rule_type`, `code`, `sort`, `unit`)
values (23, '提货卡口径GMV(去退款)', 1, 'PICKUP_PAY_GMV_LESS_REFUND', 6, '元'),
       (24, '提货卡口径支付金额(去优惠券去退款)', 1, 'PICKUP_PAY_AMT_LESS_COUPON_REFUND', 7, '元'),
       (25, '提货卡充值GMV(去退款)', 1, 'PICKUP_RECHARGE_GMV_LESS_REFUND', 8, '元'),
       (26, '提货卡充值支付金额(去优惠券去退款)', 1, 'PICKUP_RECHARGE_AMT_LESS_COUPON_REFUND', 9, '元'),
       (27, '人均提货卡口径GMV(去退款)', 1, 'AVG_PICKUP_PAY_GMV_LESS_REFUND', 10, '元/人'),
       (28, '人均提货卡口径支付金额(去优惠券去退款)', 1, 'AVG_PICKUP_PAY_AMT_LESS_COUPON_REFUND', 11, '元/人'),
       (29, '人均提货卡充值GMV(去退款)', 1, 'AVG_PICKUP_RECHARGE_GMV_LESS_REFUND', 12, '元/人'),
       (30, '人均提货卡充值支付金额(去优惠券去退款)', 1, 'AVG_PICKUP_RECHARGE_AMT_LESS_COUPON_REFUND', 13, '元/人');

insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (23, 1, '元', 1, 0),
       (23, 2, '%', 2, 1),
       (23, 3, '', 3, 0),
       (23, 5, '元', 4, 1),
       (24, 1, '元', 1, 0),
       (24, 2, '%', 2, 1),
       (24, 3, '', 3, 0),
       (24, 5, '元', 4, 1),
       (25, 1, '元', 1, 0),
       (25, 2, '%', 2, 1),
       (25, 3, '', 3, 0),
       (25, 5, '元', 4, 1),
       (26, 1, '元', 1, 0),
       (26, 2, '%', 2, 1),
       (26, 3, '', 3, 0),
       (26, 5, '元', 4, 1),
       (27, 1, '元', 1, 0),
       (27, 3, '', 2, 0),
       (27, 4, '元/(元/人)', 3, 1),
       (27, 5, '元', 4, 1),
       (28, 1, '元', 1, 0),
       (28, 3, '', 2, 0),
       (28, 4, '元/(元/人)', 3, 1),
       (28, 5, '元', 4, 1),
       (29, 1, '元', 1, 0),
       (29, 3, '', 2, 0),
       (29, 4, '元/(元/人)', 3, 1),
       (29, 5, '元', 4, 1),
       (30, 1, '元', 1, 0),
       (30, 3, '', 2, 0),
       (30, 4, '元/(元/人)', 3, 0),
       (30, 5, '元', 4, 1);


--------------------------------------新增基本提成指标模板
INSERT INTO bounty_payout_object_rule(payout_object_id, bounty_rule_type)
VALUES (1, 5),
       (2, 5),
       (3, 5),
       (4, 5);

insert into `bounty_indicator` (`id`, `title`, `bounty_rule_type`, `code`, `sort`, `unit`)
values (31, 'B类业绩口径目标完成率(不含零辅食)', 5, 'B_PFM_RATE_NO_C', 1, '%'),
       (32, 'B类实货口径目标完成率(不含零辅食)', 5, 'B_SHIHUO_RATE_NO_C', 2, '%');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 8, 1),
       (0, 8, 12),
       (0, 8, 13),
       (0, 8, 14),
       (0, 8, 23);

insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (31, 1, '元', 1, 0),
       (31, 3, '', 3, 0),
       (31, 5, '元', 5, 1),
       (32, 1, '元', 1, 0),
       (32, 3, '', 3, 0),
       (32, 5, '元', 5, 1);
