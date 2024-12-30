--组织表
CREATE TABLE crm_org_team (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `name` varchar(200) COMMENT '组织名称',
  `parent_id` bigint(20) COMMENT '组织的上级组织id',
  `leader_id` bigint(20) COMMENT '组织的负责人的销售id',
  `child_num` bigint(20) COMMENT '子组织数量',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='组织表';

--区域表
CREATE TABLE crm_base_area (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `name` varchar(200) COMMENT '区域名称',
  `area_level` tinyint(4) NOT NULL COMMENT '区域等级 1省 2市',
  `parent_id` bigint(20) COMMENT '父级区域id',
  PRIMARY KEY (`id`),
  KEY `idx_area_level` (`area_level`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='区域表';

--销售表
CREATE TABLE crm_org_team_bd (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `name` varchar(200) NOT NULL COMMENT '销售姓名',
  `account_id` bigint(20) COMMENT '帐号id',
  `post_id` bigint(20) COMMENT '岗位id',
  `team_id` bigint(20) COMMENT '销售所属组织id',
  `phone_number` varchar(200) COMMENT '销售联系电话',
  `join_time` datetime COMMENT '入职日期',
  `area_id` bigint(20) COMMENT '销售负责区域id',
  PRIMARY KEY (`id`),
  KEY `idx_team_id` (`team_id`),
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='销售表';

--组织辖区表
CREATE TABLE crm_org_team_area (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `team_id` bigint(20) NOT NULL COMMENT '组织id',
  `area_id` bigint(20) NOT NULL COMMENT '区域id',
  PRIMARY KEY (`id`),
  KEY `idx_team_id` (`team_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='组织辖区表';

--账号表
CREATE TABLE crm_base_account (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `name` varchar(200) COMMENT '用户名',
  `password` varchar(200) COMMENT '用户密码',
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='账号表';