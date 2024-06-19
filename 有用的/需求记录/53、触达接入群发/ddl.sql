ALTER TABLE t_crm_chat_group ADD COLUMN content text COMMENT '群的额外信息，json格式';
ALTER TABLE t_crm_chat_group ADD COLUMN group_members bigint(32) COMMENT '群人数';
ALTER TABLE t_crm_chat_group MODIFY COLUMN `group_id` varchar(200) NOT NULL DEFAULT '' COMMENT '群id';
ALTER TABLE t_crm_chat_group MODIFY COLUMN `owner_qw_user_id` varchar(200) DEFAULT NULL COMMENT '群主id';
ALTER TABLE t_crm_chat_group MODIFY COLUMN `open_user_id` varchar(200) DEFAULT NULL COMMENT '开通群的用户id';




