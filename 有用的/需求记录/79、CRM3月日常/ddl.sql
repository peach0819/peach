--121小程序下单拦截
INSERT INTO t_shop_control_rule_scene_relation(creator, editor, scene_code, scene_name, rule_code)
VALUES('1290387026', '1290387026', 'ORDER_121_INTERCEPT', '121小程序下单拦截', 'SHOP_DISCARD'),
      ('1290387026', '1290387026', 'ORDER_121_INTERCEPT', '121小程序下单拦截', 'SHOP_FREEZE'),
      ('1290387026', '1290387026', 'ORDER_121_INTERCEPT', '121小程序下单拦截', 'SHOP_ORDER_QUALIFICATION'),
      ('1290387026', '1290387026', 'ORDER_121_INTERCEPT', '121小程序下单拦截', 'SHOP_PROHIBIT'),
      ('1290387026', '1290387026', 'ORDER_121_INTERCEPT', '121小程序下单拦截', 'SHOP_PROHIBIT_STORE_TYPE'),
      ('1290387026', '1290387026', 'ORDER_121_INTERCEPT', '121小程序下单拦截', 'SUPERVISE_PROHIBIT_ALL_BRAND'),
      ('1290387026', '1290387026', 'ORDER_121_INTERCEPT', '121小程序下单拦截', 'SUPERVISE_PROHIBIT_SPECIAL_BRAND');

--新增网维门店可开B类设置规则
INSERT INTO t_shop_control_rule_item (`rule_code`,`rule_name`,`rule_class`,`creator`,`editor`)
VALUES('SUPERVISE_PROHIBIT_LIMIT_BRAND', '网维门店可开B类设置', 0, '1290387026', '1290387026');

--网维门店可开B类设置 生效场景配置
INSERT INTO t_shop_control_rule_scene_relation(creator, editor, scene_code, scene_name, rule_code)
VALUES('1290387026', '1290387026', 'MALL_AUTO_JOIN', 'mall自主加盟', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'ICM_B_COOPERATION_SHOP', '品牌管理合作门店', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'CRM_COOPERATION_B_HSP', 'hsp合作B类', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'CRM_COOPERATION_B', '合作B类', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'B_JOIN_WORK_ON', 'B类加盟工单', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'SPECIAL_B_JOIN_WORK_ON_PASS', 'B类特殊加盟工单通过', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'SPECIAL_B_JOIN_WORK_ON_APPLY', 'B类特殊加盟工单申请', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'B_JOIN_WORK_ON_HSP', '服务商B类加盟工单', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'BRAND_CONFIG_INIT', '品牌配置初始化', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'MALL_SHOW_MODEL', 'mall加盟页展示', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'BRAND_CONFIG_EDIT', '品牌配置编辑', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'ORDER_BATCH_INTERCEPT', '下单总分店批量拦截', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'ORDER_INTERCEPT', '下单门店拦截', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'A_BRAND_INIT', 'A类品牌初始化', 'SUPERVISE_PROHIBIT_LIMIT_BRAND'),
      ('1290387026', '1290387026', 'ORDER_121_INTERCEPT', '121小程序下单拦截', 'SUPERVISE_PROHIBIT_LIMIT_BRAND');

--新建门店可开B类设置表
CREATE TABLE t_shop_brand_limit (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `shop_id` varchar(32) NOT NULL COMMENT '门店id',
  `brand_ids` text COMMENT '品牌id列表，逗号分割',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='门店可开B类设置表';

--新建通话记录识别信息表
CREATE TABLE t_conversation_record_asr (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `conversation_record_id` bigint(11) NOT NULL COMMENT '通话记录id',
  `conversation_code` varchar(64) NOT NULL COMMENT '通话记录code',
  `time_length` int(11) COMMENT '通话时长',
  `record_url` varchar(256) COMMENT '通道方通道记录',
  `asr_status` tinyint(4) COMMENT '识别状态：1识别中、2识别成功、3识别失败、4识别超时',
  `asr_url` varchar(256) COMMENT '识别结果url',
  `asr_result` text COMMENT '识别结果',
  PRIMARY KEY (`id`),
  KEY `idx_conversation_record_id` (`conversation_record_id`),
  KEY `idx_conversation_code` (`conversation_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='通话记录识别信息表';


--跟 SUPERVISE_PROHIBIT_SPECIAL_BRAND 和 SUPERVISE_PROHIBIT_ALL_BRAND 一样就行
INSERT INTO t_shop_control_rule_attribute (`rule_code`, `biz_id`, `biz_type`, `creator`,`editor`)
SELECT 'SUPERVISE_PROHIBIT_LIMIT_BRAND', biz_id, 1, 'e5171096ad2d46fda17b51dd734ca57a', 'e5171096ad2d46fda17b51dd734ca57a'
FROM t_shop_control_rule_attribute
WHERE is_deleted = 0
AND rule_code = 'SUPERVISE_PROHIBIT_SPECIAL_BRAND';
