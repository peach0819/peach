------------------------------------------------------    拜访目标    ---------------------------------------------------
--拜访目标表
CREATE TABLE `t_crm_visit_target` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `inuse` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0使用中 1已废弃',
  `service_obj_type` bigint(20) COMMENT '服务对象分类, 美赞臣定制',
  `role_id` bigint(20) COMMENT '角色id, 美赞臣定制',
  `channel_id` bigint(20) COMMENT '渠道id, 美赞臣定制',
  `chain_id` bigint(20) COMMENT '连锁客户id, 美赞臣定制',
  `target_code` varchar(200) NOT NULL COMMENT '唯一元素组合编码',
  `data_month` varchar(100) NOT NULL DEFAULT '0' COMMENT '目标月份',
  `indicator_id` bigint(20) NOT NULL COMMENT '指标id',
  PRIMARY KEY (`id`),
  KEY `idx_service_obj_type` (`service_obj_type`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_channel_id` (`channel_id`),
  KEY `idx_month_target_code_indicator_id` (`data_month`, `target_code`, `indicator_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='拜访目标表';

--拜访目标指标表
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

--请假表
CREATE TABLE `t_crm_vacation` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `user_id` varchar(200) NOT NULL COMMENT '请假用户id',
  `vacation_type` tinyint(20) COMMENT '请假类型 0新增 1编辑 2废弃',
  `vacation_begin_time` datetime COMMENT '请假开始时间',
  `vacation_end_time` datetime COMMENT '请假结束时间',
  `vacation_status` tinyint(20) COMMENT '请假状态 0正常 1已中止 2已废弃',
  PRIMARY KEY (`id`),
  KEY `idx_user_id_status` (`user_id`, `vacation_status`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='请假表';

------------------------------------------------------    目标看板    ---------------------------------------------------
--拜访指标表
CREATE TABLE `t_crm_visit_indicator` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `indicator_code` varchar(200) COMMENT '指标code',
  `indicator_name` varchar(200) COMMENT '指标名',
  `indicator_unit` varchar (50) COMMENT '指标单位',
  `indicator_type` tinyint(20) COMMENT '指标类型, 0原子指标 1派生指标',
  `indicator_display_type` varchar(50) COMMENT '指标展示类型, num数字类型 text文本类型 ratio百分比类型',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_indicator_code` (`indicator_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='拜访指标表';

--拜访指标可见性设定
CREATE TABLE `t_crm_visit_indicator_visible` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `visible_type` tinyint(20) COMMENT '可见性类型 0核心指标 1次要指标',
  `job_id` bigint(20) COMMENT '岗位id（美赞臣角色分类id）',
  `channel_id` bigint(20) COMMENT '人员渠道id',
  `indicator_id` bigint(20) COMMENT '指标id',
  `visiable_sort` bigint(20) NOT NULL DEFAULT '99' COMMENT '可见性排序',
  PRIMARY KEY (`id`),
  KEY `idx_job_id_channel_id` (`job_id`, `channel_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='拜访指标表';

--目标看板回流表
CREATE TABLE `sync_crm_visit_user_indicator_d` (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  creator varchar(32) NOT NULL COMMENT '创建人',
  editor varchar(32) NOT NULL COMMENT '编辑人',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  is_deleted tinyint(4) DEFAULT '0' COMMENT '是否删除:0-否 1-是',
  dayid varchar(8) NOT NULL COMMENT '数仓表区块标示',
  data_month varchar(100) NOT NULL COMMENT '目标月份',
  user_id varchar(200) COMMENT '用户id',
  tab_type tinyint(20) COMMENT '指标类型， 0我自己的 1我团队的 2我下属的',
  biz_value text COMMENT '业务数据json',
  PRIMARY KEY (`id`),
  KEY `idx_data_month_tab_user` (`data_month`, `tab_type`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='目标看板回流表';

------------------------------------------------------    拜访模版    ---------------------------------------------------
--拜访模版表
CREATE TABLE `t_crm_visit_template` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `inuse` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0使用中 1已废弃',
  `template_name` varchar(200) COMMENT '模版名称',
  `template_remark` varchar(1000) COMMENT '模版备注',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='拜访模版表';

--拜访模版对象表
CREATE TABLE `t_crm_visit_template_object` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `inuse` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0使用中 1已废弃',
  `template_id` bigint(1) NOT NULL COMMENT '拜访模版id',
  `service_obj_type` bigint(20) COMMENT '门店分类id, 美赞臣定制',
  `role_id` bigint(20) COMMENT '角色id, 美赞臣定制',
  `channel_id` bigint(20) COMMENT '渠道id, 美赞臣定制',
  `target_code` varchar(200) NOT NULL COMMENT '唯一元素组合编码',
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_service_obj_type` (`service_obj_type`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_channel_id` (`channel_id`),
  KEY `idx_target_code` (`target_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='拜访模版对象表';

--拜访模版内容表
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

--拜访模版变更日志表
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

--企微指标播报数据表
CREATE TABLE `sync_crm_visit_user_notice_d` (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  creator varchar(32) NOT NULL COMMENT '创建人',
  editor varchar(32) NOT NULL COMMENT '编辑人',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  is_deleted tinyint(4) DEFAULT '0' COMMENT '是否删除:0-否 1-是',
  dayid varchar(8) NOT NULL COMMENT '数仓表区块标示',
  user_id varchar(150) COMMENT '用户id',
  user_real_name varchar(200) COMMENT '用户名',
  user_phone varchar(200) COMMENT '用户手机号',
  virtual_group_id bigint(16) COMMENT '虚拟组id',
  virtual_group_name varchar(200) COMMENT '虚拟组名',
  parent_virtual_group_id bigint(16) COMMENT '父级虚拟组id',
  parent_virtual_group_name varchar(200) COMMENT '父级虚拟组名',
  total_cnt bigint(16) COMMENT '总人数',
  visit_qualified_cnt bigint(16) COMMENT '拜访达标人数',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企微指标播报数据表';