--crm
CREATE TABLE t_crm_sales_brand (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `user_id` varchar(32) COMMENT '销售id',
  `brand_id` bigint(20) COMMENT '品牌id',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='销售订单查看品牌限制表';