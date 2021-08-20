CREATE TABLE `t_crm_chat_group_msg` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `from_type` tinyint(4) NOT NULL COMMENT '数据来源类型',
  `from_id` bigint(10) NOT NULL COMMENT '数据来源表id',
  `from_chat_id` bigint(10) COMMENT '消息发送者crm系统chat_id',
  `group_member` text COMMENT '群成员chat_id列表',
  `msg_content` text NOT NULL COMMENT '消息内容',
  `msg_time` datetime NOT NULL COMMENT '消息时间',
  PRIMARY KEY (`id`),
  KEY `idx_from_id` (`from_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='微信群聊消息';
