--a2拜访任务表
CREATE TABLE `t_visit_task` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `chance_task_id` bigint(20) COMMENT '关联机会任务id',
  `task_name` varchar(255) NOT NULL COMMENT '拜访任务名',
  `task_type` tinyint(1) NOT NULL COMMENT '任务类型 1门店 2商机',
  `task_status` tinyint(1) NOT NULL COMMENT '任务状态 1待生效 2生效中 3已失效 4已废弃',
  `begin_date` datetime COMMENT '开始时间',
  `end_date` datetime COMMENT '结束时间',
  `version` bigint(20) COMMENT '任务版本号',
  `shop_cnt` bigint(20) COMMENT '门店数',
  PRIMARY KEY (`id`),
  KEY `idx_chance_task_id` (`chance_task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='a2拜访任务表';

--a2拜访任务门店表
CREATE TABLE `t_visit_task_shop` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `task_id` bigint(20) NOT NULL COMMENT '关联拜访任务id',
  `version` bigint(20) COMMENT '门店任务版本号',
  `shop_num` varchar(255) COMMENT '门店关联门店外部编码，商机关联商机编码',
  `shop_id` varchar(255) COMMENT '门店id',
  PRIMARY KEY (`id`),
  KEY `idx_task_id_version` (`task_id`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='a2拜访任务门店表';

--a2门店关联拜访任务索引表
CREATE TABLE `t_visit_task_shop_index` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `shop_id` varchar(100) NOT NULL COMMENT '门店id',
  `chance_task_ids` text COMMENT '关联机会任务id，逗号分割',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='a2门店关联拜访任务索引表';