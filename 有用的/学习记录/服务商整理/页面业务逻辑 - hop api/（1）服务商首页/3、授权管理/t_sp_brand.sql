CREATE TABLE `t_sp_brand` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键递增ID',
  `sp_id` bigint(20) DEFAULT NULL COMMENT '服务商ID',
  `brand_id` bigint(20) DEFAULT NULL COMMENT '品牌ID',
  `area_cnt` int(11) DEFAULT '0' COMMENT '关联的区域数量',
  `rebate_type` tinyint(1) DEFAULT '1' COMMENT '服务商品牌返点类型1：默认返点，2：特殊返点',
  `status` tinyint(1) DEFAULT '1' COMMENT '授权状态，1：启用，0：停用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `creator` varchar(64) DEFAULT NULL COMMENT '创建人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `editor` varchar(64) DEFAULT NULL COMMENT '编辑人',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除，0：不删除，1：删除',
  PRIMARY KEY (`id`),
  KEY `idx_sp_id_brand_id` (`sp_id`,`brand_id`) USING BTREE COMMENT '服务商ID，品牌ID索引',
  KEY `idx_brand_id` (`brand_id`) USING BTREE COMMENT '品牌ID索引'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='服务商和品牌关系表';