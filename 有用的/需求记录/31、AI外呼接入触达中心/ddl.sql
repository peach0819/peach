CREATE TABLE `t_touch_task_detail_call` (
  `id` bigint(32) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `creator` varchar(32) NOT NULL COMMENT '创建人',
  `editor` varchar(32) NOT NULL COMMENT '辑人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除 (0.未删除 1.删除)',

  `task_instance_id` bigint(32) NOT NULL COMMENT '触达实例id',
  `task_detail_id` bigint(32) NOT NULL COMMENT '明细id',
  `call_phone` varchar(1000) COMMENT '主叫号码',
  `shop_phone` varchar(1000) NOT NULL COMMENT '门店号码（被叫号码）',
  `aiccs_call_id` varchar(100) COMMENT '智能联络中心呼叫id，标记唯一一次通话',
  `aiccs_robot_id` bigint(32) COMMENT '智能联络中心机器人id',
  `aiccs_call_param` varchar(2000) COMMENT '智能联络中心外呼参数',
  `aiccs_call_code` bigint(32) COMMENT '智能联络中心呼叫返回码（早媒体识别）',
  `aiccs_call_data` mediumtext COMMENT '智能联络中心呼叫回执',
  `aiccs_err_code` varchar(100) COMMENT '智能联络中心异常信息code（未能成功呼叫）',
  `aiccs_err_msg` text COMMENT '智能联络中心异常信息描述（未能成功呼叫）',

  `duration` bigint(32) COMMENT '通话时长',
  `ring_time` datetime COMMENT '响铃时间',
  `answer_time` datetime COMMENT '应答时间',
  `start_time` datetime COMMENT '通话开始时间',
  `end_time` datetime COMMENT '通话结束时间',
  `direction` varchar(10) COMMENT '挂机方向 0机器人挂机 1客户挂机',
  `slot_num` bigint(10) COMMENT '节点数',
  PRIMARY KEY (`id`),
  KEY `idx_task_instance_id` (`task_instance_id`),
  KEY `idx_task_detail_id` (`task_detail_id`),
  KEY `idx_aiccs_call_id` (`aiccs_call_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='触达任务明细（外呼）';

ALTER TABLE t_touch_task ADD COLUMN `channel_config` text COMMENT '渠道配置信息';
ALTER TABLE t_touch_task_instance ADD COLUMN `channel_config` text COMMENT '渠道配置信息';
ALTER TABLE t_touch_task_detail ADD COLUMN `retry_num` bigint(32) NOT NULL default '0' COMMENT '已重试次数';