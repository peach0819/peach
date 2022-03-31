ALTER TABLE t_touch_task ADD COLUMN channel_type tinyint(4) NOT NULL DEFAULT '1' COMMENT '发送渠道 1涂色通道 2企微官方通道';
ALTER TABLE t_touch_task_detail ADD COLUMN qw_msg_id varchar(200) COMMENT '企微官方通道消息id';
ALTER TABLE t_touch_task_detail ADD COLUMN qw_msg_time datetime COMMENT '企微官方消息发送时间';

create table sync_touch_shop_fatigue_d (
  id bigint(16) NOT NULL AUTO_INCREMENT,
  shop_id varchar(128) COMMENT '门店ID',
  active_type tinyint(4) COMMENT '活动类型:0-整个通道 1-活动营销类 2-单品推广类 3-商品行情类 4-人设养成类 5-官方通知类 6-主推项目类',
  fatigue_type tinyint(4) COMMENT '疲劳度统计周期:1-1天,2-自然周',
  fatigue_strength bigint(16) COMMENT '触达疲劳度(次数)',
  is_deleted tinyint(4) COMMENT '是否删除:0-否 1-是',
  create_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  edit_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='门店触达疲劳度';