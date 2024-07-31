create table sync_touch_price_off_d (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  creator varchar(32) NOT NULL COMMENT '创建人',
  editor varchar(32) NOT NULL COMMENT '编辑人',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  is_deleted tinyint(4) DEFAULT '0' COMMENT '是否删除:0-否 1-是',
  dayid varchar(8) NOT NULL COMMENT '数仓表区块标示',
  item_key varchar(128) COMMENT '疲劳度商品key',
  PRIMARY KEY (`id`),
  KEY `idx_item_key` (`item_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='触达降价通知疲劳度回流表';