


ALTER TABLE t_touch_task ADD COLUMN channel_type tinyint(4) NOT NULL DEFAULT '0' COMMENT '发送渠道 0涂色通道 1企微官方通道';
ALTER TABLE t_touch_task_detail ADD COLUMN qw_msg_id varchar(200) COMMENT '企微官方通道消息id';
ALTER TABLE t_touch_task_detail ADD COLUMN qw_msg_time datetime COMMENT '企微官方消息发送时间';
