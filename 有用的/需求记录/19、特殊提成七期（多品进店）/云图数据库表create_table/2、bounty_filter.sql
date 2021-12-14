CREATE TABLE `bounty_filter` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(10) COLLATE utf8mb4_bin NOT NULL COMMENT '字段中文名称',
  `key` varchar(40) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '字段标识',
  `field_sql` varchar(30) COLLATE utf8mb4_bin NOT NULL COMMENT '字段对应SQL',
  `required` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否必填，1为是，0为否',
  `global` tinyint(4) NOT NULL COMMENT '是否指标计算/全局过滤，1为全局过滤，0为指标过滤',
  `global_type` tinyint(4) DEFAULT NULL COMMENT '全局过滤类型：1为通用位置，2指定位置',
  `plan_date_sign` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否“方案日期”字段：1为是，0为否',
  `component_type` varchar(30) COLLATE utf8mb4_bin NOT NULL COMMENT '组件类型',
  `component_value_config` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组件待选值配置',
  `is_deleted` tinyint(1) unsigned DEFAULT '0',
  `creator` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL,
  `editor` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin