
CREATE TABLE IF NOT EXISTS `t_crm_chat_tag` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `group_id` varchar(64) NOT NULL COMMENT '企微标签分组id',
  `group_name` varchar(64) NOT NULL COMMENT '企微标签分组名',
  `tag_id` varchar(64) NOT NULL COMMENT '企微标签id',
  `tag_name` varchar(64) NOT NULL COMMENT '企微标签名',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tag_id` (`tag_id`),
  KEY `idx_group_name_tag_name` (`group_name`,`tag_name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='企微标签';