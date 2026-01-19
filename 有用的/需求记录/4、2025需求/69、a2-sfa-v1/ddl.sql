--a2_core
CREATE TABLE `sync_ads_crm_shop_stats_d` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `dayid` varchar(8) NOT NULL COMMENT '数仓表区块标示',
  `shop_id` varchar(150) COMMENT '门店id',
  `publicity_count` bigint(20) COMMENT '品宣次数',
  `display_count` bigint(20) COMMENT '陈列次数',
  `has_duty` tinyint(4) COMMENT '是否有打卡 1:有 0:无',
  `extra` text COMMENT '额外信息',
  `order_spec_count` bigint(20) COMMENT '下单罐数',
   PRIMARY KEY (`id`),
   KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='门店统计信息表';