
CREATE TABLE `t_sp_bill` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `sp_id` bigint(20) DEFAULT NULL COMMENT '服务商编号',
  `sp_name` varchar(30) DEFAULT NULL COMMENT '服务商名称',
  `sp_manager` varchar(40) DEFAULT NULL COMMENT '服务商经理',
  `month` char(7) DEFAULT NULL COMMENT '结算月份',
  `month_order_fee` decimal(10,2) DEFAULT '0.00' COMMENT '当月订单服务费',
  `reserve_order_fee` decimal(10,2) DEFAULT '0.00' COMMENT '预留10%订单服务费',
  `extra_inspire_fee` decimal(10,2) DEFAULT '0.00' COMMENT '额外激励费用',
  `adjust_service_fee` decimal(10,2) DEFAULT '0.00' COMMENT '调整服务费',
  `adjust_desc` varchar(50) DEFAULT NULL COMMENT '调整说明',
  `month_real_service_fee` decimal(10,2) DEFAULT '0.00' COMMENT '当月实际到账服务费',
  `total_reserve_service_fee` decimal(10,2) DEFAULT '0.00' COMMENT '累计预留未发放服务费',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `creator` varchar(45) DEFAULT NULL COMMENT '创建人',
  `editor` varchar(45) DEFAULT NULL COMMENT '修改人',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除，0：未删除，1：删除',
  PRIMARY KEY (`id`),
  KEY `idx_sp_id` (`sp_id`) COMMENT '服务商ID索引',
  KEY `idx_month` (`month`) USING BTREE COMMENT '月份索引'
) ENGINE=InnoDB AUTO_INCREMENT=692 DEFAULT CHARSET=utf8mb4 COMMENT='服务商对账单费用总表';

