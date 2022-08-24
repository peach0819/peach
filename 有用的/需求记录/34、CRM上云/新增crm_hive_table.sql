
 CREATE TABLE `crm_hive_table` (
  `id` bigint(32) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除 (0.未删除 1.删除)',
  `name` VARCHAR(500),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='企微/微信 实体'


INSERT INTO crm_hive_table(name) VALUES('table');