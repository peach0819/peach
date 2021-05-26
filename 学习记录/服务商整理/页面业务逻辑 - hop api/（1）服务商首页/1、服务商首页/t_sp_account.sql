
CREATE TABLE `t_sp_account` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `sp_id` bigint(20) NOT NULL COMMENT '服务商ID',
  `account_type` tinyint(1) DEFAULT '3' COMMENT '账户类型，默认为3，钱坤',
  `account` varchar(30) DEFAULT NULL COMMENT '收款账户',
  `account_no` varchar(40) DEFAULT NULL COMMENT '收款账号',
  `id_card` varchar(30) DEFAULT NULL COMMENT '身份证',
  `bank_phone` varchar(20) DEFAULT NULL COMMENT '银行预留手机号',
  `is_use` tinyint(1) DEFAULT '1' COMMENT '是否使用中，默认1：使用中，0：不使用',
  `creator` varchar(40) DEFAULT NULL COMMENT '创建人',
  `editor` varchar(40) DEFAULT NULL COMMENT '更新人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除，0：不删除，1：删除',
  PRIMARY KEY (`id`),
  KEY `idx_sp_id` (`sp_id`) COMMENT '服务商ID索引 '
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COMMENT='服务商账户表';