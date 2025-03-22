create table sync_crm_shop_order_hidden_d (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  creator varchar(32) NOT NULL COMMENT '创建人',
  editor varchar(32) NOT NULL COMMENT '编辑人',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  is_deleted tinyint(4) DEFAULT '0' COMMENT '是否删除:0-否 1-是',
  dayid varchar(8) NOT NULL COMMENT '数仓表区块标示',
  biz_value varchar(128) COMMENT '隐藏业务键',
  PRIMARY KEY (`id`),
  KEY `idx_biz_value` (`biz_value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='crm订单隐藏回流表';
