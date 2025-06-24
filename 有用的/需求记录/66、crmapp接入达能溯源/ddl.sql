--crm
CREATE TABLE t_crm_photo_danone (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `shop_id` varchar(150) COMMENT '门店id',
  `biz_id` varchar(150) COMMENT '业务id',
  `photo_type` tinyint(4) NOT NULL COMMENT '图片类型 1小记识别 2后台录入',
  `photo_status` tinyint(4) NOT NULL COMMENT '识别状态 1识别成功 2识别失败',
  `photo_result` text COMMENT '识别结果',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_biz_id` (`biz_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='达能溯源码识别表';

--crm_report
CREATE TABLE `sync_ads_crm_shop_brand_index_d` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `dayid` varchar(8) NOT NULL COMMENT '数仓表区块标示',
  `shop_id` varchar(150) COMMENT '门店id',
  `index_value` text COMMENT '指标值json',
   PRIMARY KEY (`id`),
   KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='品牌维度指标回流表';