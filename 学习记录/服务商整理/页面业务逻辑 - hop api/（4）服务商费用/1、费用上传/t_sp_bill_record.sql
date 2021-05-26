
CREATE TABLE `t_sp_bill_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `title` varchar(30) DEFAULT NULL COMMENT '费用总表标题',
  `oss_path` varchar(100) DEFAULT NULL COMMENT '费用总表oss地址',
  `is_publish` tinyint(1) DEFAULT '0' COMMENT '是否已发布，1：发布，0：未发布',
  `month` char(7) DEFAULT NULL COMMENT '定长，月份字段，格式2019_01',
  `attach1_title` varchar(30) DEFAULT NULL COMMENT '附件1标题',
  `attach1_oss_path` varchar(100) DEFAULT NULL COMMENT '附件1 oss地址',
  `attach2_title` varchar(30) DEFAULT NULL COMMENT '附件2标题',
  `attach2_oss_path` varchar(100) DEFAULT NULL COMMENT '附件2 oss地址',
  `attach3_title` varchar(30) DEFAULT NULL COMMENT '附件3标题',
  `attach3_oss_path` varchar(100) DEFAULT NULL COMMENT '附件3 oss地址',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `creator` varchar(45) DEFAULT NULL COMMENT '创建人',
  `editor` varchar(45) DEFAULT NULL COMMENT '修改人',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除，1：删除，0：不删除',
  PRIMARY KEY (`id`),
  KEY `idx_month` (`month`) USING BTREE COMMENT '月份索引'
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COMMENT='服务商对帐单总记录表';

