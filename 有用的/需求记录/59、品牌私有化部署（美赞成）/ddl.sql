CREATE TABLE `t_crm_visit_target` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `inuse` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0使用中 1已废弃',
  `shop_type_id` bigint(20) COMMENT '门店分类id, 美赞臣定制',
  `role_id` bigint(20) COMMENT '角色id, 美赞臣定制',
  `channel_id` bigint(20) COMMENT '渠道id, 美赞臣定制',
  `target_code` varchar(200) NOT NULL COMMENT '唯一元素组合编码',
  `indicator_id` bigint(20) NOT NULL COMMENT '指标id',
  PRIMARY KEY (`id`),
  KEY `idx_shop_type_id` (`shop_type_id`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_channel_id` (`channel_id`),
  KEY `idx_target_code_indicator_id` (`target_code`, `indicator_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='拜访目标表';

CREATE TABLE `t_crm_visit_target_content` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `target_id` bigint(20) NOT NULL COMMENT '目标id',
  `indicator_value` varchar (200) NOT NULL COMMENT '目标值',
  PRIMARY KEY (`id`),
  KEY `idx_target_id` (`target_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='拜访目标指标表';

CREATE TABLE `t_crm_visit_template` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `inuse` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0使用中 1已废弃',
  `shop_type_id` bigint(20) COMMENT '门店分类id, 美赞臣定制',
  `role_id` bigint(20) COMMENT '角色id, 美赞臣定制',
  `channel_id` bigint(20) COMMENT '渠道id, 美赞臣定制',
  `target_code` varchar(200) NOT NULL COMMENT '唯一元素组合编码',
  `template_name` varchar(200) COMMENT '模版名称',
  `template_remark` varchar(1000) COMMENT '模版备注',
  PRIMARY KEY (`id`),
  KEY `idx_shop_type_id` (`shop_type_id`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_channel_id` (`channel_id`),
  KEY `idx_target_code` (`target_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='拜访模版表';

CREATE TABLE `t_crm_visit_template_content` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `template_id` bigint(1) NOT NULL COMMENT '拜访模版id',
  `content` text COMMENT '拜访模版内容',
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='拜访模版内容表';

CREATE TABLE `t_crm_visit_template_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `template_id` bigint(1) NOT NULL COMMENT '拜访模版id',
  `log_type` tinyint(20) COMMENT '变更类型 0新增 1编辑 2废弃',
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='拜访模版变更日志表';