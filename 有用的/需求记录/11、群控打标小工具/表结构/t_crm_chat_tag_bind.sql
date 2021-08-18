
CREATE TABLE `t_crm_chat_tag_bind` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `version` bigint(10) NOT NULL COMMENT '数据版本',
  `version_time` datetime NOT NULL COMMENT '版本时间',
  `version_type` tinyint(1) NOT NULL COMMENT '版本类型',
  `shop_id` varchar(100) COMMENT '门店id',
  `linker_id` varchar(100) COMMENT '联系人id',
  `qw_user_id` varchar(100) NOT NULL COMMENT '企微userid',
  `qw_external_user_id` varchar(100) NOT NULL COMMENT '企微外部userid，企微上给微信的标识id，通过此参数进行接口调用',
  `group_name` varchar(64) NOT NULL COMMENT '企微标签分组名',
  `tag_id` varchar(64) NOT NULL COMMENT '企微标签id',
  `tag_name` varchar(64) NOT NULL COMMENT '企微标签名',
  PRIMARY KEY (`id`),
  KEY `idx_version` (`version`),
  KEY `idx_qw_external_user_id` (`qw_external_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='企微客户标签绑定';











