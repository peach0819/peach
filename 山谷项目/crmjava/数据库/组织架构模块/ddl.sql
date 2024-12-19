--组织表
CREATE TABLE crm_org (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `creator` bigint(20) NOT NULL COMMENT '创建人',
  `editor` bigint(20) NOT NULL COMMENT '修改人',
  `org_name` varchar(200) COMMENT '组织名称',
  `parent_id` bigint(20) COMMENT '组织的上级组织id',
  `root_key` varchar(500) COMMENT '组织的全链路',
  `leader_id` bigint(20) COMMENT '组织的负责人的销售id',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='组织表';

--岗位表
CREATE TABLE crm_job (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `job_name` varchar(200) COMMENT '岗位名称',
  `job_code` varchar(200) COMMENT '岗位编码',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='岗位表';

--销售表
CREATE TABLE crm_sales (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `creator` bigint(20) NOT NULL COMMENT '创建人',
  `editor` bigint(20) NOT NULL COMMENT '修改人',
  `sales_name` varchar(200) NOT NULL COMMENT '销售姓名',
  `sales_phone` varchar(200) COMMENT '销售联系电话',
  `job_id` bigint(20) COMMENT '销售岗位id',
  `org_id` bigint(20) COMMENT '销售所属组织id',
  `join_time` datetime COMMENT '入职日期',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='销售表';

--区域表
CREATE TABLE crm_area (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `area_name` varchar(200) NOT NULL COMMENT '区域名称',
  `area_level` tinyint(4) NOT NULL COMMENT '区域等级',
  `parent_id` bigint(20) COMMENT '父级区域id',
  PRIMARY KEY (`id`),
  KEY `idx_area_level` (`area_level`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='区域表';

--组织辖区表
CREATE TABLE crm_org_area (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `creator` bigint(20) NOT NULL COMMENT '创建人',
  `editor` bigint(20) NOT NULL COMMENT '修改人',
  `org_id` bigint(20) NOT NULL COMMENT '组织id',
  `area_id` bigint(20) NOT NULL COMMENT '区域id',
  PRIMARY KEY (`id`),
  KEY `idx_org_id` (`org_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='组织辖区表';

--销售辖区表
CREATE TABLE crm_sales_area (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `creator` bigint(20) NOT NULL COMMENT '创建人',
  `editor` bigint(20) NOT NULL COMMENT '修改人',
  `sales_id` bigint(20) NOT NULL COMMENT '销售id',
  `area_id` bigint(20) NOT NULL COMMENT '区域id',
  PRIMARY KEY (`id`),
  KEY `idx_sales_id` (`sales_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='销售辖区表';

--用户表
CREATE TABLE crm_user (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `user_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0系统用户 1销售',
  `user_account` varchar(200) NOT NULL COMMENT '帐号',
  `user_password` varchar(200) NOT NULL COMMENT '用户密码',
  `user_name` varchar(200) COMMENT '用户昵称',
  `user_phone` varchar(200) COMMENT '用户手机号',
  PRIMARY KEY (`id`),
  KEY `idx_user_account` (`user_account`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='用户表';

--角色表
CREATE TABLE crm_role (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `role_name` varchar(200) NOT NULL COMMENT '角色名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='角色表';

--用户角色表
CREATE TABLE crm_user_role (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `user_id` bigint(20) NOT NULL COMMENT '用户id',
  `role_id` bigint(20) NOT NULL COMMENT '角色id',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='用户角色表';

--权限表
CREATE TABLE crm_permission (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `permission_name` varchar(200) NOT NULL COMMENT '权限名',
  `permission_code` varchar(200) NOT NULL COMMENT '权限code',
  PRIMARY KEY (`id`),
  UNIQUE KEY `udx_permission_code` (`permission_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='权限表';

--用户权限表
CREATE TABLE crm_user_permission (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `user_id` bigint(20) NOT NULL COMMENT '用户id',
  `permission_code` varchar(200) NOT NULL COMMENT '权限code',
  PRIMARY KEY (`id`),
  KEY `idx_user_id_permission_code` (`user_id`, `permission_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='用户权限表';

--角色权限表
CREATE TABLE crm_role_permission (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `role_id` bigint(20) NOT NULL COMMENT '角色id',
  `permission_code` varchar(200) NOT NULL COMMENT '权限code',
  PRIMARY KEY (`id`),
  KEY `idx_role_id_permission_code` (`role_id`, `permission_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='角色权限表';

--菜单表
CREATE TABLE crm_menu (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `menu_name` varchar(200) NOT NULL COMMENT '菜单名',
  `menu_type` tinyint(4) NOT NULL COMMENT '菜单类型 1目录 2菜单',
  `menu_sort` bigint(20) NOT NULL DEFAULT '0' COMMENT '菜单顺序',
  `menu_path` varchar(500) COMMENT '菜单路径',
  `permission_code` varchar(200) COMMENT '权限code',
  `parent_id` bigint(20) COMMENT '父级菜单id',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='菜单表';