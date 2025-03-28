CREATE TABLE `t_crm_tuse_callback_msg` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `msg_type` bigint(10) NULL COMMENT '回调消息类型',
  `type_desc` varchar(100) COMMENT '回调消息类型描述',
  `is_processed` tinyint(4) DEFAULT '0' COMMENT '已处理',
  `biz_id` varchar(100) COMMENT '回调消息业务id',
  `content` text COMMENT '消息内容',
  PRIMARY KEY (`id`),
  KEY `idx_biz_id` (`biz_id`),
  KEY `idx_msg_type_is_processed` (`msg_type`, `is_processed`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='涂色回调消息';