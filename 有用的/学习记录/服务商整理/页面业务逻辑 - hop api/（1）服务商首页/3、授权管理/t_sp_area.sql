
CREATE TABLE `t_sp_area` (
  `id` bigint(10) NOT NULL AUTO_INCREMENT,
  `sp_id` bigint(10) NOT NULL COMMENT '服务商id,关联t_sp_info',
  `area_id` varchar(45) NOT NULL COMMENT '授权区域id 可能是省市区任何一级',
  `status` tinyint(2) NOT NULL DEFAULT '1' COMMENT '授权状态 1 启用 0 停用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `creator` varchar(45) DEFAULT NULL,
  `editor` varchar(45) DEFAULT NULL,
  `is_deleted` tinyint(2) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_sp_id` (`sp_id`)
) ENGINE=InnoDB AUTO_INCREMENT=83989 DEFAULT CHARSET=utf8mb4 COMMENT='服务商区域授权表';

