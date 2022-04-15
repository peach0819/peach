
-- 排名返现类型 新增门槛
UPDATE bounty_indicator_payout_rule_type SET is_upper_limit = 1 WHERE payout_rule_type_code = 5;

-- 指标表 新增
insert into `bounty_indicator` (`id`, `title`, `bounty_rule_type`, `code`, `sort`, `unit`)
values (20, '人均有效品牌门店数', 4, 'AVG_VALID_BRAND_SHOP_COUNT', 4, '家/人'),
       (21, '人均多品在店积分', 4, 'AVG_BRAND_SHOP_SCORE', 5, '分/人'),
       (22, '人均有效品牌门店数变化', 4, 'AVG_VALID_BRAND_SHOP_COUNT_CHANGE', 6, '家/人');

--指标奖励映射表 新增
insert into `bounty_indicator_payout_rule_type` (`bounty_indicator_id`, `payout_rule_type_code`, `bounty_unit`, `sort`, `is_upper_limit`)
values (20, 1, '元', 1, 0),
       (20, 3, '', 2, 0),
       (20, 4, '元/(家/人)', 3, 0),
       (20, 5, '元', 4, 1),
       (21, 1, '元', 1, 0),
       (21, 3, '', 2, 0),
       (21, 4, '元/(分/人)', 3, 0),
       (21, 5, '元', 4, 1),
       (22, 1, '元', 1, 0),
       (22, 3, '', 2, 0),
       (22, 4, '元/(家/人)', 3, 0),
       (22, 5, '元', 4, 1);