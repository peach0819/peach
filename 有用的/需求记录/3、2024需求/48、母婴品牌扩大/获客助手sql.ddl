create table t_crm_customer_acquisition (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  creator varchar(32) NOT NULL COMMENT '创建人',
  editor varchar(32) NOT NULL COMMENT '编辑人',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  is_deleted tinyint(4) DEFAULT '0' COMMENT '是否删除:0-否 1-是',
  qw_user_id varchar(100) NOT NULL COMMENT '企微userid',
  link_id varchar(100) NOT NULL COMMENT '链接id',
  link_name varchar(200) COMMENT '链接名',
  link_create_time datetime COMMENT '链接创建时间',
  url varchar(200) COMMENT '链接url',
  PRIMARY KEY (`id`),
  KEY `idx_qw_user_id` (`qw_user_id`),
  KEY `idx_link_id` (`link_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='获客助手链接';

create table t_crm_customer_acquisition_log (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  creator varchar(32) NOT NULL COMMENT '创建人',
  editor varchar(32) NOT NULL COMMENT '编辑人',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  is_deleted tinyint(4) DEFAULT '0' COMMENT '是否删除:0-否 1-是',
  link_id varchar(100) NOT NULL COMMENT '链接id',
  qw_user_id varchar(100) COMMENT '企微userid',
  qw_external_user_id varchar(100) COMMENT '客户外部联系人id',
  state varchar(100) COMMENT '添加途径',
  next_cursor varchar(100) COMMENT '当前记录来源的页的next_cursor',
  PRIMARY KEY (`id`),
  KEY `idx_link_id` (`link_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='获客助手日志';


weixin://biz/ww/profile/https%3A%2F%2Fwork.weixin.qq.com%2Fca%2Fcawcded0112929cbf5%3Fcustomer_channel%3DCHANNEL_TEST

https://work.weixin.qq.com/ca/cawcded0112929cbf5?customer_channel=CHANNEL_TEST



