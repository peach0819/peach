

ALTER TABLE t_crm_chat ADD COLUMN `tuse_id` varchar(100) COMMENT '涂色id';
ALTER TABLE t_crm_chat ADD KEY `idx_tuse_id` (`tuse_id`);

ALTER TABLE t_crm_chat_tag_bind ADD COLUMN `admin_chat_id` bigint(32) COMMENT '小二微信id';
ALTER TABLE t_crm_chat_tag_bind ADD COLUMN `shop_chat_id` bigint(32) COMMENT '门店微信id';

ALTER TABLE t_crm_chat_group ADD COLUMN `group_type` tinyint(4) NOT NULL default '0' COMMENT '群类型 0企微群 1个微群';
ALTER TABLE t_crm_chat_group_member ADD COLUMN `group_user_name` varchar(100) COMMENT '用户群内昵称';

CREATE TABLE `t_crm_tuse_wx_moments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `callback_id` bigint(20) NOT NULL COMMENT '回调记录id',
  `tuse_time_line_id` varchar(100) COMMENT '朋友圈时间线id',
  `tuse_send_wx_id` varchar(100) NOT NULL COMMENT '发送者涂色微信编号',
  `tuse_robot_wx_id` varchar(100) NOT NULL COMMENT '观测者涂色微信编号',
  `tuse_moments_type` int(10) COMMENT '朋友圈类型',
  `tuse_msg_content` text COMMENT '朋友圈内容',
  `tuse_meta_msg_content` mediumtext COMMENT '朋友圈内容原数据',
  `tuse_moments_time` datetime COMMENT '朋友圈时间',
  `tuse_msg_list` text COMMENT '朋友圈评论',
  `tuse_media_list` text COMMENT '媒体文件信息（图片、视频）',
  `tuse_like_list` text COMMENT '点赞信息',
  `send_chat_id` bigint(10) COMMENT '发消息的系统chat_id',
  `robot_chat_id` bigint(10) COMMENT '观测者的系统chat_id',
  PRIMARY KEY (`id`),
  KEY `idx_callback_id` (`callback_id`),
  KEY `idx_tuse_time_line_id` (`tuse_time_line_id`),
  KEY `idx_send_chat_id_robot_chat_id` (`send_chat_id`,`robot_chat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='涂色个微朋友圈';



