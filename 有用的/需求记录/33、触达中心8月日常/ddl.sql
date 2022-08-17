

ALTER TABLE t_crm_chat_group ADD COLUMN `open_user_id` varchar(50) COMMENT '开通群的用户id',
                             ADD COLUMN `open_chat_id` bigint(32) COMMENT '开通群的用户chatId',
                             ADD COLUMN `belong_user_id` text COMMENT '所属用户id jsonarray',
                             ADD COLUMN `belong_chat_id` text COMMENT '所属用户chatId jsonarray';

ALTER TABLE t_crm_chat_group DROP COLUMN `open_user_id`,
                             DROP COLUMN `open_chat_id`,
                             DROP COLUMN `belong_user_id`,
                             DROP COLUMN `belong_chat_id`;

ALTER TABLE t_crm_chat_group ADD COLUMN `open_user_id` varchar(50) COMMENT '开通群的用户id';
ALTER TABLE t_crm_chat_group ADD COLUMN `open_chat_id` bigint(32) COMMENT '开通群的用户chatId';
ALTER TABLE t_crm_chat_group ADD COLUMN `belong_user_id` text COMMENT '所属用户id jsonarray';
ALTER TABLE t_crm_chat_group ADD COLUMN `belong_chat_id` text COMMENT '所属用户chatId jsonarray';