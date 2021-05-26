
CREATE TABLE `t_sp_brand` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键递增ID',



  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除，0：不删除，1：删除',
  PRIMARY KEY (`id`),
  KEY `idx_sp_id_brand_id` (`sp_id`,`brand_id`) USING BTREE COMMENT '服务商ID，品牌ID索引',
  KEY `idx_brand_id` (`brand_id`) USING BTREE COMMENT '品牌ID索引'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='服务商和品牌关系表';


  is_pickup_recharge_order        int             comment '是否为充值提货hi卡订单 1 是 0 否',
  is_spec_brand                  tinyint         COMMENT '是否特殊提点品牌,1是0否',
  `` COMMENT '',
  `` COMMENT '',
  `` COMMENT '',
  `` COMMENT '',
  `` COMMENT '',
  `` COMMENT '',
  `` COMMENT '',
  `` COMMENT '',