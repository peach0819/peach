
CREATE TABLE `t_sp_reward` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `sp_id` bigint(20) unsigned DEFAULT NULL COMMENT '服务商ID',
  `brand_id` bigint(20) DEFAULT NULL COMMENT '品牌ID',
  `first_cate_id` bigint(20) DEFAULT NULL COMMENT '1级类目',
  `second_cate_id` bigint(20) DEFAULT NULL COMMENT '2级类目',
  `third_cate_id` bigint(20) DEFAULT NULL COMMENT '3级类目',
  `rebate` double(4,2) DEFAULT NULL COMMENT '返点率，保留两位小数',
  `added` double(4,2) DEFAULT NULL COMMENT '增值率，保留两位小数',
  `is_default` tinyint(1) DEFAULT '0' COMMENT '是否是默认设置，0：不是，1：是',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `creator` varchar(40) DEFAULT NULL COMMENT '创建人',
  `editor` varchar(40) DEFAULT NULL COMMENT '更新人',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除0：不删除，1：删除',
  PRIMARY KEY (`id`),
  KEY `idx_brand_id` (`brand_id`) USING BTREE COMMENT '品牌ID索引'
) ENGINE=InnoDB AUTO_INCREMENT=324 DEFAULT CHARSET=utf8mb4 COMMENT='服务商返点表V2';

