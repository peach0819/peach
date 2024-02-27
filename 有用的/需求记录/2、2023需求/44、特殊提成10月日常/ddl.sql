
-- AB类改成非必填
UPDATE bounty_filter set required = 0 WHERE `key` = 'item_style';

-- 增加品牌分类筛选
INSERT INTO `bounty_filter` (`id`, `title`, `key`, `field_sql`, `required`, `global`, `global_type`, `plan_date_sign`, `component_type`, `component_value_config`)
VALUES (32, '品牌分类', 'brand_type', 'brand_type', 0, 1, 1, 0, 'enum_radio', '{"type":"fixed","data":[{"label":"大包","value":"大包"},{"label":"小包","value":"小包"}]}');

insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 32),
       (0, 5, 32),
       (0, 6, 32),
       (0, 7, 32);

-- 基本提成新增 大包完成率指标
insert into `bounty_indicator` (`id`, `title`, `bounty_rule_type`, `code`, `sort`, `unit`)
values (42, '大包完成率', 5, 'BIG_PACK_RATE', 3, '%');

insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (42, 1, '元', 1, 0),
       (42, 3, '', 3, 0),
       (42, 5, '元', 5, 1);

-- 存量GMV指标新增 人均实货下单门店数指标
insert into `bounty_indicator` (`id`, `title`, `bounty_rule_type`, `code`, `sort`, `unit`)
values (43, '人均实货下单门店数', 1, 'AVG_GMV_SHIHUO_SHOP_COUNT', 19, '家/人');

insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (43, 1, '元', 1, 0),
       (43, 3, '', 3, 0),
       (43, 5, '元', 5, 1);