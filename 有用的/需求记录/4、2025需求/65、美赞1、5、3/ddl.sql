--指标明细回流表
CREATE TABLE `sync_crm_visit_user_indicator_detail_d` (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  creator varchar(32) NOT NULL COMMENT '创建人',
  editor varchar(32) NOT NULL COMMENT '编辑人',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  is_deleted tinyint(4) DEFAULT '0' COMMENT '是否删除:0-否 1-是',
  dayid varchar(8) NOT NULL COMMENT '数仓表区块标示',
  data_month varchar(30) NOT NULL COMMENT '目标月份',
  user_id varchar(60) COMMENT '用户id',
  indicator_code varchar(80) COMMENT '指标code',
  service_obj_id varchar(200) COMMENT '拜访对象id',
  service_obj_name varchar(200) COMMENT '拜访对象名称',
  biz_value text COMMENT '业务数据json',
  PRIMARY KEY (`id`),
  KEY `idx_data_month_indicator_code_user_id` (`data_month`, `indicator_code`, `user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='目标看板明细回流表';

--拜访指标可见性设定v2
CREATE TABLE `t_crm_visit_indicator_visible_v2` (
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
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='拜访指标可见性表v2';

--目标看板回流表v2
CREATE TABLE `sync_crm_visit_user_indicator_v2_d` (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  creator varchar(32) NOT NULL COMMENT '创建人',
  editor varchar(32) NOT NULL COMMENT '编辑人',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  is_deleted tinyint(4) DEFAULT '0' COMMENT '是否删除:0-否 1-是',
  dayid varchar(8) NOT NULL COMMENT '数仓表区块标示',
  data_month varchar(30) NOT NULL COMMENT '目标月份',
  user_id varchar(60) COMMENT '用户id',
  tab_type tinyint(20) COMMENT '指标类型， 0我自己的 1我团队的 2我下属的',
  biz_value text COMMENT '业务数据json',
  PRIMARY KEY (`id`),
  KEY `idx_data_month_tab_type_user_id` (`data_month`, `tab_type`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='目标看板回流表v2';

