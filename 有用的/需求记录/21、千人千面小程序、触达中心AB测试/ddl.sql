
--素材库
CREATE TABLE t_touch_miniprogram_material (
`id` bigint(20) NOT NULL AUTO_INCREMENT,
`creator` varchar(255) DEFAULT NULL COMMENT '提交人',
`create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
`editor` varchar(255) DEFAULT NULL COMMENT '修改人',
`edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
`is_deleted` tinyint(4) DEFAULT '0' COMMENT '已删除',
`material_type` tinyint(4) NULL COMMENT '素材类型 1商品主图 2用户自定义',
`biz_id` varchar(100) COMMENT '业务id，商品主图为商品id，用户自定义为触达任务id',
`material_url` TEXT COMMENT '素材资源，原始url',
`process` tinyint(4) DEFAULT '0' COMMENT '是否已处理 0未处理 1已处理',
`material_content` MEDIUMTEXT COMMENT '素材内容，用于发送企微小程序的素材内容',
PRIMARY KEY (`id`),
KEY `idx_type_biz_id_process` (`material_type`, `biz_id`, `process`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='小程序素材';