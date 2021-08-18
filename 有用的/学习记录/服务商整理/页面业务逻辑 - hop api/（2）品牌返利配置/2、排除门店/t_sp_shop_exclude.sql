
CREATE TABLE `t_sp_shop_exclude` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `shop_id` varchar(40) DEFAULT NULL COMMENT '门店ID',
  `brand_id` bigint(20) DEFAULT NULL COMMENT '品牌ID',
  `group_id` bigint(20) DEFAULT NULL COMMENT '白名单ID',
  `tag` tinyint(1) DEFAULT '0' COMMENT '标签类型，可能会扩展 0无，1授权排除标记',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `creator` varchar(40) DEFAULT NULL COMMENT '创建人',
  `editor` varchar(40) DEFAULT NULL COMMENT '修改人',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除（0：否 1：是）',
  PRIMARY KEY (`id`),
  KEY `idx_brand_id` (`brand_id`) USING BTREE COMMENT '品牌ID索引',
  KEY `idx_shop_id` (`shop_id`) USING BTREE COMMENT '门店ID索引'
) ENGINE=InnoDB AUTO_INCREMENT=83 DEFAULT CHARSET=utf8mb4 COMMENT='门店排除表v2';