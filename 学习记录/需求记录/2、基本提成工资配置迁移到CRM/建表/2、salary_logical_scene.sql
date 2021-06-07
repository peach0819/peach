
CREATE TABLE IF NOT EXISTS `t_salary_logical_scene` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `data_month` varchar(10) NOT NULL COMMENT '月份',
  `is_split` varchar(200) NOT NULL COMMENT '是否拆分',
  `service_feature_names` varchar(500) NOT NULL COMMENT '快照职能集合',
  `service_feature_name` varchar(200) NOT NULL COMMENT '快照职能',
  `coefficient_logical` varchar(200) NOT NULL COMMENT '系数逻辑',
  `commission_logical` varchar(200) NOT NULL COMMENT '提成逻辑',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='逻辑场景表表';