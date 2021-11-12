CREATE TABLE `t_crm_chat_relation_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `qw_chat_id` bigint(32) NOT NULL COMMENT '电销企业微信chat中主键id',
  `shop_chat_id` bigint(32) NOT NULL COMMENT '门店微信chat中主键id',
  `log_type` tinyint(4) NOT NULL COMMENT '记录类型',
  `content` text COMMENT '记录内容',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='企微好友关系变更记录';

