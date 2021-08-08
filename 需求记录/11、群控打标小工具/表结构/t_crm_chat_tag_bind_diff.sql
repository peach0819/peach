
CREATE TABLE IF NOT EXISTS `t_crm_chat_tag_bind_diff` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `diff_date` datetime NOT NULL COMMENT '差异日期',
  `diff_reason` tinyint(2) DEFAULT '0' COMMENT '差异原因',
  `diff_type` tinyint(2) DEFAULT '0' COMMENT '差异类型',
  `group_name` varchar(64) NOT NULL COMMENT '企微标签分组名',
  `before_tag_list` text COMMENT '变更前的标签',
  `after_tag_list` text COMMENT '变更后的标签',
  PRIMARY KEY (`id`),
  KEY `idx_diff_date` (`diff_date`),
  KEY `idx_group_name` (`group_name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='企微客户标签差异';