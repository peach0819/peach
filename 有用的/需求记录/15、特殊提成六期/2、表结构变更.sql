---------------------------存量gmv 新增两个指标
--指标表 新增
insert into `bounty_indicator` (`id`, `title`, `bounty_rule_type`, `code`, `sort`, `unit`)
values (15, '人均实货支付金额(去优惠券去退款)', 1, 'STOCK_GMV_AVG_GOODS_PAY_AMT_MINUS_COUNPONS_MINUS_REF', 1, '元/人');
insert into `bounty_indicator` (`id`, `title`, `bounty_rule_type`, `code`, `sort`, `unit`)
values (16, '人均实货GMV(去退款)', 1, 'STOCK_GMV_AVG_GOODS_GMV_MINUS_REFUND', 2, '元/人');

--指标奖励映射表 新增
insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (15, 1, '元', 1, 0);
insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (15, 3, null, 2, 0);
insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (15, 5, '元', 3, 0);

insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (16, 1, '元', 1, 0);
insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (16, 3, null, 2, 0);
insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (16, 5, '元', 3, 0);


---------------------------------------人均指标 新增奖励类型 累计阶梯单价返点
insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (12, 4, '元/(家/人)', 4, 1);
insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (13, 4, '元/(元/人)', 4, 1);
insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (14, 4, '元/(元/人)', 4, 1);
insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (15, 4, '元/(元/人)', 4, 1);
insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (16, 4, '元/(元/人)', 4, 1);


---------------------------------------新增门店分组过滤器
-- bounty_filter表加数据
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (18, '门店分组', 'shop_group', 'shop_group', 0, 1, 1, 0, 'api_select', '{\"type\":\"url\", \"url\":\"hipac.crm.bountyplan.listShopGroup\",\"code\":\"\"}');

-- bounty_rule_filter表添加数据
insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 18),
       (0, 5, 18),
       (0, 6, 18);

