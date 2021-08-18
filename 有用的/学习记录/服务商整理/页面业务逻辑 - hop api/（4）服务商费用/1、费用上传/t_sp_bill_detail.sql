
CREATE TABLE `t_sp_bill_detail` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `sp_id` bigint(20) DEFAULT NULL COMMENT '服务商编号',
  `sp_name` varchar(30) DEFAULT NULL COMMENT '服务商名称',
  `month` char(7) DEFAULT NULL COMMENT '结算月份',
  `attach_no` tinyint(1) DEFAULT NULL COMMENT '附件编号，1：附件1，2：附件2，3：附件3',
  `content` varchar(2000) DEFAULT NULL COMMENT '内容，为json格式的数据',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `creator` varchar(45) DEFAULT NULL COMMENT '创建人',
  `editor` varchar(45) DEFAULT NULL COMMENT '修改人',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除，1：删除，0：未删除',
  PRIMARY KEY (`id`),
  KEY `idx_month_attach_no` (`month`,`attach_no`) USING BTREE COMMENT '月份和附件编号索引',
  KEY `idx_sp_id` (`sp_id`) USING BTREE COMMENT '服务商ID索引'
) ENGINE=InnoDB AUTO_INCREMENT=510 DEFAULT CHARSET=utf8mb4 COMMENT='对帐单详情表';

