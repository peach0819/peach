
CREATE TABLE IF NOT EXISTS `t_crm_chat_tag_bind` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `bind_id` bigint(32) NOT NULL COMMENT '绑定关系id',
  `chat_tag_id` bigint(20) NOT NULL COMMENT '标签id',
  PRIMARY KEY (`id`),
  KEY `idx_bind_id` (`bind_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='企微客户标签绑定';