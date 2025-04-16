CREATE TABLE `sync_crm_visit_user_indicator_detail_d` (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  creator varchar(32) NOT NULL COMMENT '创建人',
  editor varchar(32) NOT NULL COMMENT '编辑人',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  is_deleted tinyint(4) DEFAULT '0' COMMENT '是否删除:0-否 1-是',
  dayid varchar(8) NOT NULL COMMENT '数仓表区块标示',
  data_month varchar(100) NOT NULL COMMENT '目标月份',
  user_id varchar(200) COMMENT '用户id',
  indicator_code varchar(200) COMMENT '指标code',
  service_obj_id varchar(200) COMMENT '拜访对象id',
  service_obj_name varchar(200) COMMENT '拜访对象名称',
  biz_value text COMMENT '业务数据json',
  PRIMARY KEY (`id`),
  KEY `idx_data_month_code_user` (`data_month`, `indicator_code`, `user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='目标看板明细回流表';