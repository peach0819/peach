create table t_touch_task_item (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  creator varchar(32) NOT NULL COMMENT '创建人',
  editor varchar(32) NOT NULL COMMENT '编辑人',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  is_deleted tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否删除:0-否 1-是',
  task_id bigint(32) NOT NULL COMMENT '触达任务id',
  task_content_id bigint(32) NOT NULL COMMENT '触达内容id',
  item_id bigint(32) NOT NULL COMMENT '商品id',
  PRIMARY KEY (`id`),
  KEY `idx_task_id` (`task_id`),
  KEY `idx_item_id` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='触达任务关联商品表';