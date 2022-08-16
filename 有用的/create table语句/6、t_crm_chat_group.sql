CREATE TABLE `t_crm_chat_group` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `creator` varchar(32) NOT NULL COMMENT '创建者',
  `editor` varchar(32) NOT NULL COMMENT '修改者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除 1是0否',

  `group_type` tinyint(4) NOT NULL default '0' COMMENT '群类型 0企微群 1个微群',
  `group_id` varchar(50) NOT NULL DEFAULT '' COMMENT '群id',
  `group_name` varchar(100) DEFAULT '' COMMENT '群名称',
  `owner_qw_user_id` varchar(50) NOT NULL DEFAULT '' COMMENT '群主id',
  `owner_chat_id` bigint(32) DEFAULT NULL COMMENT '群主聊天实体id（t_crm_chat主键）',

  `open_user_id` varchar(50) COMMENT '开通群的用户id',
  `open_chat_id` bigint(32) COMMENT '开通群的用户chatId',
  `belong_user_id` varchar(2000) COMMENT '所属用户id jsonarray',
  `belong_chat_id` varchar(2000) COMMENT '所属用户chatId jsonarray',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_group_id` (`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=862 DEFAULT CHARSET=utf8mb4 COMMENT='群聊'