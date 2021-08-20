CREATE TABLE `t_crm_tuse_qw_group_msg` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `callback_id` bigint(20) NOT NULL COMMENT '回调记录id',
  `tuse_send_wx_id` varchar(100) NOT NULL COMMENT '发送者涂色微信id',
  `tuse_group_id` varchar(100) NOT NULL COMMENT '涂色微信群id',
  `tuse_file_id` varchar(100) COMMENT '涂色文件id',
  `tuse_msg_type` int(10) COMMENT '涂色微信消息类型',
  `tuse_msg_id` varchar(100) NOT NULL COMMENT '涂色微信消息id',
  `tuse_msg_content` text NOT NULL COMMENT '涂色微信消息内容',
  `tuse_meta_msg_content` text NOT NULL COMMENT '涂色微信消息原内容',
  `tuse_msg_time` datetime NOT NULL COMMENT '涂色消息时间',
  PRIMARY KEY (`id`),
  KEY `idx_callback_id` (`callback_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='涂色群聊消息';

