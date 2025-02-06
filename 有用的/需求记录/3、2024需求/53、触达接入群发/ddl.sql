ALTER TABLE t_crm_chat_group ADD COLUMN content text COMMENT '群的额外信息，json格式',
                             ADD COLUMN group_members bigint(32) COMMENT '群人数',
                             MODIFY COLUMN `group_id` varchar(200) NOT NULL DEFAULT '' COMMENT '群id',
                             MODIFY COLUMN `owner_qw_user_id` varchar(200) DEFAULT NULL COMMENT '群主id',
                             MODIFY COLUMN `open_user_id` varchar(200) DEFAULT NULL COMMENT '开通群的用户id';