------冻结销售团队标识支持多选
update bounty_filter set component_type = 'enum_multi_select' WHERE id = 16;

------新增发放对象BD&大BD
INSERT INTO `bounty_payout_object` (`id`, `name`, `code`)
VALUES (8, '【岗位】BD&大BD', 'BD_BIG_BD');

INSERT INTO `bounty_payout_object_rule` (`payout_object_id`, `bounty_rule_type`)
VALUES (8, 1),
       (8, 2),
       (8, 3),
       (8, 5);