

---新增指标  新签GMV占比全月完成率
insert into `bounty_indicator` (`id`, `title`, `bounty_rule_type`, `code`, `sort`, `unit`)
values (33, '新签GMV占比全月完成率', 2, 'SIGN_ITEM_GMV_RATE', 8, '%'),
       (34, '新签GMV占比全月完成率', 3, 'SIGN_BRAND_GMV_RATE', 8, '%');

insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (33, 1, '元', 1, 0),
       (33, 3, '', 3, 0),
       (33, 5, '元', 5, 1),
       (34, 1, '元', 1, 0),
       (34, 3, '', 3, 0),
       (34, 5, '元', 5, 1);

---新增指标  控区HI卡充值指标
insert into `bounty_indicator` (`id`, `title`, `bounty_rule_type`, `code`, `sort`, `unit`)
values (35, '提货卡充值GMV(去退款)', 1, 'HI_RECHARGE_GMV_LESS_REFUND', 14, '元'),
       (36, '人均提货卡充值GMV(去退款)', 1, 'AVG_HI_RECHARGE_GMV_LESS_REFUND', 15, '元/人');

insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (35, 1, '元', 1, 0),
       (35, 2, '%', 2, 1),
       (35, 3, '', 3, 0),
       (35, 5, '元', 4, 1),
       (36, 1, '元', 1, 0),
       (36, 3, '', 2, 0),
       (36, 4, '元/(元/人)', 3, 1),
       (36, 5, '元', 4, 1);


---新增过滤条件  不追回品牌
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (25, '不追回品牌', 'unback_brand', 'unback_brand', 0, 1, 1, 0, 'api_multi_select', '{\"type\":\"url\", \"url\":\"hipac.crm.bountyPlan.listFilterResult\",\"code\":\"BRAND\"}');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 25),
       (0, 5, 25),
       (0, 6, 25),
       (0, 7, 25);


---新签模板新增门店维度计算筛选
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (26, '多品牌是否合并', 'merge_brand', 'merge_brand', 1, 1, 1, 0, 'enum_radio', '{"type":"fixed","data":[{"label":"是","value":"是"},{"label":"否","value":"否"}]}');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 6, 26);
