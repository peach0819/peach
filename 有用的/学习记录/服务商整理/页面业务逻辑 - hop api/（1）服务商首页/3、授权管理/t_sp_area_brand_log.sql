
CREATE TABLE `t_sp_area_brand_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `sp_id` bigint(20) DEFAULT NULL COMMENT '服务商ID',
  `brand_id` bigint(20) DEFAULT NULL COMMENT '品牌ID',
  `content` varchar(1500) DEFAULT NULL COMMENT '操作内容',
  `creator` varchar(40) DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(40) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除，0：不删除，1：删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=702 DEFAULT CHARSET=utf8mb4 COMMENT='服务商，品牌，区域授权日志表';

