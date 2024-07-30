--yt_ustone库
CREATE TABLE t_shop_danone (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `shop_id` varchar(32) NOT NULL COMMENT '门店id',
  `shop_num` varchar(180) COMMENT '门店编号',
  `shop_license_code` varchar(128) COMMENT '门店营业执照编码(统一社会信用代码)',
  `danone_shop_code` varchar(200) COMMENT '达能门店编码',
  `danone_shop_name` varchar(200) COMMENT '达能门店名称',
  `danone_shop_linker_name` varchar(200) COMMENT '达能门店联系人',
  `danone_shop_linker_phone` varchar(200) COMMENT '达能门店联系人手机号',
  `danone_shop_account` varchar(200) COMMENT '达能登录帐号',
  `danone_shop_password` varchar(200) COMMENT '达能登录密码',
  `has_spc` tinyint(4)  COMMENT 'SPC是否存在 0存在 1不存在',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_shop_num` (`shop_num`),
  KEY `idx_shop_license_code` (`shop_license_code`),
  KEY `idx_danone_shop_code` (`danone_shop_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='达能门店信息表';

--crm库
CREATE TABLE t_crm_shop_danone_log (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) DEFAULT NULL COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) DEFAULT NULL COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
  `shop_sync_type` tinyint(4) NOT NULL COMMENT '业务场景 1、达能门店新增 2、达能门店属性变更',
  `biz_id` varchar(200) NOT NULL COMMENT '达能门店变更记录id',
  `biz_value` text COMMENT '达能门店变更记录内容',
  PRIMARY KEY (`id`),
  KEY `idx_biz_id_biz_type` (`biz_id`, `biz_type`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='达能门店变更记录表';

--yt_hop库 测试环境
insert into t_open_api (`creator`, `editor`, `hop_api_id`, `category_id`, `name`, `return_example`)
values('system', 'system', 52510610, 7, '达能门店数据回传接口', '{"code":200,"message":"成功","data":{"syncSuccess":true,"message":""},"success":true}');