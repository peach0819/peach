##crm库
CREATE TABLE c (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `task_name` varchar(100) COMMENT '任务名',
  `task_desc` varchar(2000) COMMENT '任务描述',
  `task_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '任务状态 0生效中 1已废弃',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='进店动作任务';

CREATE TABLE t_crm_visit_action_task_content (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `content_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '内容状态 0生效中 1已废弃',
  `task_id` bigint(20) NOT NULL COMMENT '任务id',
  `task_type` tinyint(4) COMMENT '进店任务类型 0卖进前 1卖进后',
  `team_type` tinyint(4) COMMENT '执行团队 0BD',
  `job_id` varchar(500) COMMENT '执行岗位id多选',
  `content_type` tinyint(4) NOT NULL COMMENT '设定模式 0人工设定 1系统策略',
  `dmp_id` varchar(500) COMMENT '圈选id多选, 人工设定时使用',
  `strategy_id` bigint(20) COMMENT '策略id, 系统策略时使用',
  `brand_id` bigint(20) COMMENT '品牌id',
  `brand_series_id` bigint(20) COMMENT '品牌系列id',
  `action_config` text COMMENT '动作配置',
  PRIMARY KEY (`id`),
  KEY `idx_task_id` (`task_id`),
  KEY `idx_brand_id_brand_series_id` (`brand_id`, `brand_series_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='进店动作任务内容';

##crm_report库
CREATE TABLE `sync_ads_crm_visit_action_d` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `dayid` varchar(8) NOT NULL COMMENT '数仓表区块标示',
  `shop_id` varchar(32) COMMENT '门店id',
  `job_id` bigint(20) COMMENT '岗位id',
  `action_id` bigint(20) COMMENT '动作id',
  `brand_id` bigint(20) COMMENT '品牌id',
  `brand_series_id` bigint(20) COMMENT '品牌系列id',
  `brand_category` varchar(200) COMMENT '品牌类目',
  `faq_doc_id` varchar(1000) COMMENT '知识库id',
  `content_id` varchar(1000) COMMENT '关联内容id',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id_job_id` (`shop_id`, `job_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='拜访动作回流表';

CREATE TABLE `sync_ads_crm_visit_action_brand_d` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `dayid` varchar(8) NOT NULL COMMENT '数仓表区块标示',
  `brand_id` bigint(20) COMMENT '品牌id',
  `brand_name` varchar(200) COMMENT '品牌名',
  `brand_category` varchar(200) COMMENT '品牌类目',
  PRIMARY KEY (`id`),
  KEY `idx_brand_category` (`brand_category`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='拜访动作品牌回流表';