--crm
CREATE TABLE t_crm_photo_wyeth (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `creator` varchar(255) COMMENT '提交人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `editor` varchar(255) COMMENT '修改人',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已删除',
  `shop_id` varchar(150) COMMENT '门店id',
  `biz_id` varchar(150) COMMENT '业务id',
  `photo_type` tinyint(4) NOT NULL COMMENT '图片类型 1小记识别 2后台录入',
  `photo_status` tinyint(4) NOT NULL COMMENT '识别状态 1识别成功 2识别失败',
  `photo_result` text COMMENT '识别结果',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_biz_id` (`biz_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='惠氏溯源码识别表';

--yt_hop库 测试环境
insert into t_open_api (`creator`, `editor`, `hop_api_id`, `category_id`, `name`, `return_example`)
values('system', 'system', 55932699, 7, '惠氏注册门店审核状态回传接口', '{"code":200,"message":"成功","data":true,"success":true}'),
      ('system', 'system', 55932536, 7, '惠氏拜访结果回传接口', '{"code":200,"message":"成功","data":true,"success":true}');

--yt_hop库 正式环境
insert into t_open_api (`creator`, `editor`, `hop_api_id`, `category_id`, `name`, `return_example`)
values('system', 'system', 23815, 7, '惠氏注册门店审核状态回传接口', '{"code":200,"message":"成功","data":true,"success":true}'),
      ('system', 'system', 23814, 7, '惠氏拜访结果回传接口', '{"code":200,"message":"成功","data":true,"success":true}');