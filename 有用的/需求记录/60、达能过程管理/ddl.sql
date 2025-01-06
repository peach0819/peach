-- ustone库
CREATE TABLE t_shop_danone_employee (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `danone_shop_code` varchar(100) NOT NULL COMMENT '达能门店编码',
  `employee_id` varchar(100) NOT NULL COMMENT '达能店员id',
  `employee_real_name` varchar(100) COMMENT '达能店员真实姓名',
  `employee_nick_name` varchar(100) COMMENT '达能店员昵称',
  `employee_mobile` varchar(100) COMMENT '达能店员手机号',
  `employee_status` tinyint(4) COMMENT '达能店员状态 0:有效 1:无效',
  `employee_role` tinyint(4) COMMENT '达能店员角色 1普通店员 2 SPC',
  PRIMARY KEY (`id`),
  KEY `idx_danone_shop_code` (`danone_shop_code`),
  KEY `idx_employee_id` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='达能门店店员表';

-- crm库
CREATE TABLE t_crm_danone_sync_version (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `version_type` tinyint(4) NOT NULL COMMENT '版本类型 1:SPC打卡数据 2:SPC陈列数据 3:POS库存数据 4:POS订单数据',
  `version_status` tinyint(4) NOT NULL COMMENT '版本状态 0:待同步 1:同步完成',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='达能数据同步版本表';

CREATE TABLE t_crm_danone_sync_version_data (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `version_id` bigint(20) NOT NULL COMMENT '版本id',
  `version_data` text COMMENT '版本数据',
  PRIMARY KEY (`id`),
  KEY `idx_version_id` (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='达能数据同步表';

#crm_report库
CREATE TABLE `sync_ads_crm_danone_shop_notice_d` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `dayid` varchar(8) NOT NULL COMMENT '数仓表区块标示',
  `data_month` varchar(20) NOT NULL COMMENT '数据所属月份',
  `shop_id` varchar(32) COMMENT '门店id',
  `danone_shop_code` varchar(100) COMMENT '达能门店编码',
  `photo_qualified` tinyint(4) COMMENT '陈列是否合格 1合格 0不合格',
  `spc_duty_qualified` tinyint(4) COMMENT 'SPC考勤是否合格 1合格 0不合格',
  `pos_inventory_qualified` tinyint(4) COMMENT 'POS库存是否需要补货 1合格（不需要补货） 0不合格（需要补货）',
  `pos_order_qualified` tinyint(4) COMMENT 'POS未售是否合格 1合格（无未售） 0不合格（有未售）',
  `extra` text COMMENT '额外信息',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_danone_shop_code` (`danone_shop_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='达能数据回流表';




#瑶迦那边的
create table t_crm_danone_item_sku
(
    id                          bigint(11) auto_increment primary key,
    danone_sku_code             varchar(128) default ''                not null comment '达能 skucode',
    danone_sku_id               varchar(32)  default ''                not null comment ' 达能 skuid',
    danone_item_name            varchar(128) default ''                null comment ' 达能商品名称',
    danone_can_size             tinyint(1)   default 0                 not null comment '大小罐,0:小罐,1:大罐',
    danone_brand_series         varchar(128) default ''                not null comment '达能系列',
    danone_brand_property_value tinyint(1)   default 1                 not null comment '达能段数',
    hpc_item_id                 bigint(19)   default 0                 null comment '海拍客商品 id',
    is_deleted                  tinyint(1)   default 0                 null comment '是否删除：1-是；0-否',
    create_time                 datetime     default CURRENT_TIMESTAMP not null comment '创建时间',
    creator                     varchar(32)  default ''                not null comment '创建人',
    edit_time                   datetime     default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '修改时间',
    editor                      varchar(32)  default ''                not null comment '修改人',
    KEY `idx_danone_brand_series` (`danone_brand_series`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4 comment '达能商品映射表';

#crm
create table t_crm_warning_check_info
(
    id          bigint(11) auto_increment primary key,
    user_id     varchar(32)  default ''                not null comment '操作人',
    shop_id     varchar(32)  default ''                not null comment '门店 id',
    type        tinyint(1)   default 1                 null comment '操作类型，1:库存预警',
    remark      varchar(512) default ''                not null comment '备注',
    is_deleted  tinyint(1)   default 0                 null comment '是否删除：1-是；0-否',
    create_time datetime     default CURRENT_TIMESTAMP not null comment '创建时间',
    creator     varchar(32)  default ''                not null comment '创建人',
    edit_time   datetime     default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '修改时间',
    editor      varchar(32)  default ''                not null comment '修改人',
    KEY `idx_user_id_shop_id` (`user_id`, `shop_id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4 comment '预警确认信息表';