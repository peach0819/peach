create table sync_ads_crm_transfer_chat_msg_d (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  creator varchar(32) NOT NULL COMMENT '创建人',
  editor varchar(32) NOT NULL COMMENT '编辑人',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  is_deleted tinyint(4) DEFAULT '0' COMMENT '是否删除:0-否 1-是',
  dayid varchar(8) NOT NULL COMMENT '数仓表区块标示',
  msg_id bigint(20) NOT NULL COMMENT '消息id',
  qw_chat_id bigint(32) NOT NULL COMMENT '企微实体id',
  shop_chat_id bigint(32) NOT NULL COMMENT '门店个微实体id',
  direction tinyint(4) COMMENT '1:qw_chat_id操作 2:shop_chat_id操作',
  msg_time datetime NOT NULL COMMENT '消息时间',
  msg_type varchar(20) NOT NULL COMMENT '消息类型',
  content text COMMENT '消息内容',
  PRIMARY KEY (`id`),
  KEY `idx_qw_chat_id_shop_chat_id_msg_time_msg_id` (`qw_chat_id`, `shop_chat_id`, `msg_time`, `msg_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='侧边栏聊天记录表';