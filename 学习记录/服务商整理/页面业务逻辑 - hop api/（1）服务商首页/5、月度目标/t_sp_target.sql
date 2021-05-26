
CREATE TABLE `t_sp_target` (
  `id` bigint(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键，自动增长',
  `sp_id` bigint(11) unsigned NOT NULL COMMENT '服务商ID',
  `brand_id` bigint(11) unsigned NOT NULL COMMENT '品牌ID',
  `month` varchar(7) NOT NULL DEFAULT '' COMMENT '月份',
  `is_system_copy` tinyint(2) NOT NULL COMMENT '是否是系统复制0：不是，1：是',
  `gmv_total` bigint(11) DEFAULT NULL COMMENT '本月总GMV（-退款）',
  `cur_mon_new_shops` bigint(11) DEFAULT NULL COMMENT '本月新签门店数',
  `cur_mon_pay_shops` bigint(11) DEFAULT NULL COMMENT '本月总下单门店数',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `creator` varchar(32) DEFAULT NULL COMMENT '创建人',
  `editor` varchar(32) DEFAULT NULL COMMENT '编辑人',
  `is_deleted` tinyint(2) NOT NULL DEFAULT '0' COMMENT '是否删除(0:未删除, 1:删除)',
  PRIMARY KEY (`id`),
  KEY `idx_sp_id_brand_id_month` (`sp_id`,`brand_id`,`month`),
  KEY `idx_month` (`month`) USING BTREE COMMENT '月份索引'
) ENGINE=InnoDB AUTO_INCREMENT=273 DEFAULT CHARSET=utf8mb4 COMMENT='服务商月度目标';

