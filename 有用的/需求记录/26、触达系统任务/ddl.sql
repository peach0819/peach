CREATE TABLE `t_touch_task_instance` (
  `id` bigint(32) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `editor` varchar(32) NOT NULL COMMENT '辑人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除 (0.未删除 1.删除)',
  `biz_type` tinyint(4) NOT NULL COMMENT '业务场景 1、触达中心人工创建任务 2、触达中心系统任务',
  `biz_id` varchar(32) NOT NULL COMMENT '业务id, 触达中心场景为task_id',
  `instance_level` tinyint(4) COMMENT '实例等级 1、紧急；2、一般；3、不紧急',
  `instance_type` tinyint(4) COMMENT '实例内容类型 1活动营销类 2单品推广类 3奶粉行情类 4人设养成类 5官方通知类 6主推项目类',
  `instance_status` tinyint(4) NOT NULL COMMENT '实例状态 1、待发送，2、正在发送，3、发送完成，4、发送暂停，5、发送取消，6、二次推送',
  `use_ab_test` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否开启AB测试 0不开启 1开启',
  `channel_type` tinyint(4) NOT NULL DEFAULT '1' COMMENT '发送渠道 1涂色通道 2企微官方通道',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  PRIMARY KEY (`id`),
  KEY `idx_biz_type_biz_id` (`biz_type`, `biz_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='触达任务实例';

ALTER TABLE t_touch_task_detail ADD COLUMN task_instance_id bigint(32) NOT NULL COMMENT '触达实例id';
UPDATE t_touch_task_detail SET task_instance_id = task_id WHERE task_instance_id = 0;
ALTER TABLE t_touch_task_detail ADD KEY `idx_instance_id_admin_chat_id` (`task_instance_id`, `admin_chat_id`);
ALTER TABLE t_touch_task_detail ADD KEY `idx_instance_id_detail_status_second_push` (`task_instance_id`, `detail_status`, `second_push`);
ALTER TABLE t_touch_task_detail DROP KEY `idx_task_id_admin_chat_id`;
ALTER TABLE t_touch_task_detail DROP KEY `idx_task_id_detail_status_second_push`;