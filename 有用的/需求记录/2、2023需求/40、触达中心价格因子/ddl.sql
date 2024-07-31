create table t_touch_task_price (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  creator varchar(32) NOT NULL COMMENT '创建人',
  editor varchar(32) NOT NULL COMMENT '编辑人',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  is_deleted tinyint(4) COMMENT '是否删除:0-否 1-是',
  task_id bigint(32) NOT NULL COMMENT '触达任务id',
  task_instance_id bigint(32) NOT NULL COMMENT '触达实例id',
  shop_id varchar(128) COMMENT '门店ID',
  biz_status tinyint(4) NOT NULL COMMENT '处理状态 0待处理 1处理成功 2处理失败',
  biz_id text COMMENT '业务id列表',
  biz_value mediumtext COMMENT '店品价格信息',
  PRIMARY KEY (`id`),
  KEY `idx_task_id` (`task_id`),
  KEY `idx_task_instance_id_biz_status_shop_id` (`task_instance_id`, `biz_status`, `shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='触达店品价格信息表';