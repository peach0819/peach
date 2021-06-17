



CREATE TABLE IF NOT EXISTS `t_crm_order_channel` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(32) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(32) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '已删除',
  `trade_id` varchar(50) NOT NULL COMMENT '订单id',
  `channel_result` VARCHAR(128) NOT NULL COMMENT '订单各渠道处理结果，json',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_trade_id` (`trade_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='订单渠道处理情况表';