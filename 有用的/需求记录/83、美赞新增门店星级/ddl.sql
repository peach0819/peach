CREATE TABLE `sync_ads_service_obj_extra_d` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) NOT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  `dayid` varchar(8) NOT NULL COMMENT '数仓表区块标示',
  `service_obj_id` varchar(50) NOT NULL COMMENT '服务对象ID',
  `extra` text COMMENT '服务对象扩展信息',
  PRIMARY KEY (`id`),
  KEY `idx_service_obj_id` (`service_obj_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='美赞门店额外属性回流表';