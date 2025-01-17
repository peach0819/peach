CREATE TABLE `t_crm_chat_msg_qw` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `msg_id` varchar(64) NOT NULL DEFAULT '' COMMENT '消息id，消息的唯一标识，企业可以使用此字段进行消息去重。String类型。msgid以_external结尾的消息，表明该消息是一条外部消息。',
  `seq` bigint(32) NOT NULL COMMENT '本次请求获取消息记录开始的seq值。首次访问填写0，非首次使用上次企业微信返回的最大seq。允许从任意seq重入拉取。Uint64类型，范围0-pow(2,64)-1',
  `qw_action` varchar(10) NOT NULL DEFAULT '' COMMENT '消息动作，目前有1:send(发送消息)/2:recall(撤回消息)/3:switch(切换企业日志)三种类型',
  `admin_chat_id` bigint(32) DEFAULT NULL COMMENT '小二聊天实体id，t_crm_chat表主键id',
  `shop_chat_id` bigint(32) DEFAULT NULL COMMENT '门店聊天实体id，t_crm_chat表主键id',
  `direction` tinyint(4) DEFAULT NULL COMMENT '主动行为方，1：admin_chat_id操作;2:shop_chat_id操作',
  `room_id` varchar(32) DEFAULT NULL COMMENT '群聊群id',
  `msg_time` datetime NOT NULL COMMENT '消息发送时间',
  `msg_type` varchar(20) NOT NULL DEFAULT '' COMMENT '消息类型',
  `content` text COMMENT '消息内容',
  `extend` varchar(512) DEFAULT '' COMMENT '扩展字段，json',
  `meta_data` mediumtext NOT NULL COMMENT '原始数据，未结构化json',
  `creator` varchar(32) NOT NULL COMMENT '创建者',
  `editor` varchar(32) NOT NULL COMMENT '修改者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除 1是0否',
  PRIMARY KEY (`id`),
  KEY `idx_msg_id` (`msg_id`),
  KEY `idx_admin_chat_id_shop_chat_id` (`admin_chat_id`,`shop_chat_id`),
  KEY `idx_msg_type_msg_time` (`msg_type`,`msg_time`)
) ENGINE=InnoDB AUTO_INCREMENT=37811127 DEFAULT CHARSET=utf8mb4 COMMENT='企业微信聊天记录表'