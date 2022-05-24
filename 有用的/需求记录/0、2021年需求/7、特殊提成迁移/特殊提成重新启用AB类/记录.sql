select *
from bounty_filter
where title = 'AB类型'  -- id=2
or title like '%销售团队标识%' -- =17，冻结=16，


 -- BountyRuleType 枚举：1~3 已废弃
SELECT *
from bounty_rule_filter
where bounty_filter_id in (2,16,17)

-- insert bounty_rule_filter
-- set bounty_rule_type_id=4,bounty_filter_id=2
-- set bounty_rule_type_id=5,bounty_filter_id=2
-- set bounty_rule_type_id=6,bounty_filter_id=2;


--订正SQL:
insert into `bounty_rule_filter` (`bounty_rule_type`,`bounty_rule_type_id`,`bounty_filter_id`)
values (0, 4, 2),
(0, 5, 2),
(0, 6, 2);