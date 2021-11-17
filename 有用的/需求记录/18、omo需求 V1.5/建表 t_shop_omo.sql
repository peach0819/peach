CREATE TABLE `t_shop_omo` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `shop_id` varchar(32) NOT NULL DEFAULT '' COMMENT '关联海拍客门店id',
  `nick_name` varchar(100) DEFAULT NULL COMMENT '商城名称',
  `shop_face_pic` varchar(128) DEFAULT NULL COMMENT '商城头像',
  `customer_phone` varchar(32) DEFAULT NULL COMMENT '客服电话',
  `omo_status` tinyint(1) DEFAULT NULL COMMENT '商城状态',
  `manager_commission_percentage` int(10) DEFAULT NULL COMMENT '店长佣金比例',
  `guide_commission_percentage` int(10) DEFAULT NULL COMMENT '导购佣金比例',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否有效 1无效 0有效',
  `creator` varchar(32) DEFAULT '' COMMENT '创建人id',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) DEFAULT '' COMMENT '修改人id',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `extra_json` varchar(256) NOT NULL DEFAULT '' COMMENT '扩展字段:json',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=188 DEFAULT CHARSET=utf8mb4 COMMENT='omo门店';

ALTER TABLE t_shop_omo ADD COLUMN remark text COMMENT '备注';