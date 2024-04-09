create table sync_touch_platform_price_brand_d (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  creator varchar(32) NOT NULL COMMENT '创建人',
  editor varchar(32) NOT NULL COMMENT '编辑人',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  is_deleted tinyint(4) DEFAULT '0' COMMENT '是否删除:0-否 1-是',
  dayid varchar(8) NOT NULL COMMENT '数仓表区块标示',
  brand_id bigint(16) COMMENT '品牌id',
  brand_name varchar(128) COMMENT '品牌名',
  brand_cn_name varchar(128) COMMENT '品牌中文名',
  brand_en_name varchar(128) COMMENT '品牌英文名',
  PRIMARY KEY (`id`),
  KEY `idx_brand_id` (`brand_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='触达母婴自动回复品牌回流表';
