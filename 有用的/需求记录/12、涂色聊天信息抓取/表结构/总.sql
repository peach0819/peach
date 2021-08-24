CREATE TABLE `t_crm_tuse_callback_msg` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `msg_type` bigint(10) NULL COMMENT '回调消息类型',
  `type_desc` varchar(100) COMMENT '回调消息类型描述',
  `is_processed` tinyint(4) DEFAULT '0' COMMENT '已处理',
  `biz_id` varchar(100) COMMENT '回调消息业务id',
  `content` text COMMENT '消息内容',
  PRIMARY KEY (`id`),
  KEY `idx_biz_id` (`biz_id`),
  KEY `idx_msg_type_is_processed` (`msg_type`, `is_processed`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='涂色回调消息';

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
  `from_chat_id` bigint(10) COMMENT '消息发送者crm系统chat_id',
  `group_member` text COMMENT '群成员chat_id列表',
  PRIMARY KEY (`id`),
  KEY `idx_callback_id` (`callback_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='涂色群聊消息';

CREATE TABLE `t_crm_tuse_qw_personal_msg` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `callback_id` bigint(20) NOT NULL COMMENT '回调记录id',
  `tuse_send_wx_id` varchar(100) NOT NULL COMMENT '发送者涂色微信id',
  `tuse_receiver_wx_id` varchar(100) NOT NULL COMMENT '接收者涂色微信id',
  `tuse_file_id` varchar(100) COMMENT '涂色文件id',
  `tuse_msg_type` int(10) COMMENT '涂色微信消息类型',
  `tuse_msg_id` varchar(100) NOT NULL COMMENT '涂色微信消息id',
  `tuse_msg_content` text NOT NULL COMMENT '涂色微信消息内容',
  `tuse_meta_msg_content` text NOT NULL COMMENT '涂色微信消息原内容',
  `tuse_msg_time` datetime NOT NULL COMMENT '涂色消息时间',
  `from_chat_id` bigint(10) COMMENT '消息发送者crm系统chat_id',
  `to_chat_id` bigint(10) COMMENT '消息接收者crm系统chat_id',
  PRIMARY KEY (`id`),
  KEY `idx_callback_id` (`callback_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='涂色私聊消息';

ALTER TABLE t_crm_chat_bind ADD COLUMN tuse_id varchar(100) COMMENT '涂色企微帐号id';
ALTER TABLE t_crm_chat_bind ADD COLUMN tuse_fre_id varchar(100) COMMENT '涂色小二帐号id';
ALTER TABLE t_crm_chat_bind ADD KEY `idx_tuse_id` (`tuse_id`);
ALTER TABLE t_crm_chat_bind ADD KEY `idx_tuse_fre_id` (`tuse_fre_id`);